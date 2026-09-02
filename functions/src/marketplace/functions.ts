import { createHash } from "node:crypto";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { defineBoolean } from "firebase-functions/params";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { HttpsError, onCall, onRequest } from "firebase-functions/v2/https";
import {
  createCheckoutPreference,
  exchangeAuthorizationCode,
  getPayment,
  refundPayment,
} from "./mercado-pago-client";
import {
  getSellerCredentials,
  saveSellerCredentials,
} from "./integration-service";
import {
  checkoutRequestDocumentId,
  CreateCheckoutInput,
  prepareCheckout,
  releaseStockReservation,
} from "./order-service";
import { applyPaymentUpdate } from "./payment-service";
import {
  createOAuthState,
  MP_APP_RETURN_URL,
  MP_CLIENT_ID,
  MP_CLIENT_SECRET,
  MP_ENVIRONMENT,
  MP_OAUTH_STATE_SECRET,
  MP_REDIRECT_URI,
  MP_TOKEN_ENCRYPTION_KEY,
  MP_WEBHOOK_SECRET,
  MP_WEBHOOK_URL,
  requireCompanyAdmin,
  validateWebhookSignature,
  verifyOAuthState,
} from "./security";

const REGION = "southamerica-east1";
const MP_ENFORCE_APP_CHECK = defineBoolean(
  "MERCADO_PAGO_ENFORCE_APP_CHECK",
  { default: false },
);

function db() {
  return getFirestore();
}

function requiredString(value: unknown, label: string): string {
  const result = typeof value === "string" ? value.trim() : "";
  if (!result) throw new HttpsError("invalid-argument", `${label} obrigatorio`);
  return result;
}

function queryString(value: unknown): string {
  if (Array.isArray(value)) return String(value[0] ?? "");
  return typeof value === "string" ? value : "";
}

function appendQuery(urlValue: string, values: Record<string, string>): string {
  const url = new URL(urlValue);
  for (const [key, value] of Object.entries(values)) {
    url.searchParams.set(key, value);
  }
  return url.toString();
}

function callableFailure(error: unknown): never {
  if (error instanceof HttpsError) throw error;
  logger.error("Marketplace operation failed", {
    errorName: error instanceof Error ? error.name : "UnknownError",
    errorMessage: error instanceof Error ? error.message : "Unknown error",
  });
  throw new HttpsError(
    "internal",
    "Nao foi possivel concluir a operacao de pagamento",
  );
}

export const beginMercadoPagoConnection = onCall(
  {
    region: REGION,
    timeoutSeconds: 30,
    memory: "128MiB",
    enforceAppCheck: MP_ENFORCE_APP_CHECK,
    secrets: [MP_OAUTH_STATE_SECRET],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Entre para conectar o Mercado Pago");
    }
    try {
      const companyId = requiredString(request.data?.companyId, "Petshop");
      await requireCompanyAdmin(db(), request.auth.uid, companyId);
      const state = createOAuthState(request.auth.uid, companyId);
      const authorizationUrl = appendQuery(
        "https://auth.mercadopago.com.br/authorization",
        {
          client_id: MP_CLIENT_ID.value(),
          response_type: "code",
          platform_id: "mp",
          state,
          redirect_uri: MP_REDIRECT_URI.value(),
        },
      );
      return { authorizationUrl };
    } catch (error) {
      return callableFailure(error);
    }
  },
);

export const mercadoPagoOAuthCallback = onRequest(
  {
    region: REGION,
    timeoutSeconds: 60,
    memory: "128MiB",
    secrets: [
      MP_CLIENT_SECRET,
      MP_OAUTH_STATE_SECRET,
      MP_TOKEN_ENCRYPTION_KEY,
    ],
  },
  async (request, response) => {
    const code = queryString(request.query.code);
    const state = queryString(request.query.state);
    const returnUrl = MP_APP_RETURN_URL.value();
    if (!code || !state) {
      response.redirect(303, appendQuery(returnUrl, { mercadoPago: "invalid" }));
      return;
    }

    try {
      const payload = verifyOAuthState(state);
      await requireCompanyAdmin(db(), payload.uid, payload.companyId);
      const replayId = createHash("sha256")
        .update(`${payload.companyId}:${payload.nonce}`)
        .digest("hex");
      await db().collection("oauth_state_uses").doc(replayId).create({
        provider: "MERCADO_PAGO",
        companyId: payload.companyId,
        uid: payload.uid,
        expiresAt: Timestamp.fromMillis(payload.expiresAt),
        usedAt: FieldValue.serverTimestamp(),
      });
      const credentials = await exchangeAuthorizationCode({
        clientId: MP_CLIENT_ID.value(),
        clientSecret: MP_CLIENT_SECRET.value(),
        code,
        redirectUri: MP_REDIRECT_URI.value(),
      });
      await saveSellerCredentials(db(), payload.companyId, credentials);
      response.redirect(
        303,
        appendQuery(returnUrl, {
          mercadoPago: "connected",
          companyId: payload.companyId,
        }),
      );
    } catch (error) {
      logger.error("Mercado Pago OAuth callback failed", {
        errorName: error instanceof Error ? error.name : "UnknownError",
        errorMessage: error instanceof Error ? error.message : "Unknown error",
      });
      response.redirect(303, appendQuery(returnUrl, { mercadoPago: "failed" }));
    }
  },
);

export const createMarketplaceCheckout = onCall(
  {
    region: REGION,
    timeoutSeconds: 60,
    memory: "256MiB",
    enforceAppCheck: MP_ENFORCE_APP_CHECK,
    secrets: [MP_CLIENT_SECRET, MP_TOKEN_ENCRYPTION_KEY],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Entre para finalizar a compra");
    }
    const uid = request.auth.uid;
    const rawInput = request.data as CreateCheckoutInput;
    const companyId = requiredString(rawInput?.companyId, "Petshop");
    const clientRequestId = requiredString(
      rawInput?.clientRequestId,
      "Identificador da tentativa",
    );
    const requestId = checkoutRequestDocumentId(uid, clientRequestId);
    const requestRef = db().collection("checkout_requests").doc(requestId);

    try {
      const prepared = await prepareCheckout(db(), uid, rawInput);
      const [requestSnapshot, orderSnapshot] = await Promise.all([
        requestRef.get(),
        db().collection("orders").doc(prepared.orderId).get(),
      ]);
      const existingRequest = requestSnapshot.data();
      if (existingRequest?.checkoutUrl) {
        return {
          orderId: prepared.orderId,
          checkoutUrl: String(existingRequest.checkoutUrl),
          expiresAt: prepared.expiresAt.toISOString(),
        };
      }
      if (orderSnapshot.data()?.stockReservationStatus !== "RESERVED") {
        throw new HttpsError(
          "failed-precondition",
          "A reserva deste checkout expirou; tente novamente",
        );
      }

      const credentials = await getSellerCredentials(db(), companyId);
      const notificationUrl = appendQuery(MP_WEBHOOK_URL.value(), { companyId });
      const preference = await createCheckoutPreference(
        credentials.accessToken,
        {
          orderId: prepared.orderId,
          title: `Pedido 4YouPet #${prepared.orderId}`,
          totalCents: prepared.totalCents,
          marketplaceFeeCents: prepared.marketplaceFeeCents,
          payerEmail: prepared.payerEmail,
          notificationUrl,
          returnUrl: MP_APP_RETURN_URL.value(),
          expiresAt: prepared.expiresAt,
        },
        requestId,
      );
      const checkoutUrl =
        MP_ENVIRONMENT.value() === "production"
          ? preference.initPoint
          : preference.sandboxInitPoint ?? preference.initPoint;

      await db().runTransaction(async (transaction) => {
        const latest = await transaction.get(requestRef);
        if (!latest.exists || latest.data()?.uid !== uid) {
          throw new Error("Checkout request ownership changed");
        }
        transaction.update(requestRef, {
          status: "READY",
          providerPreferenceId: preference.id,
          checkoutUrl,
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.update(db().collection("orders").doc(prepared.orderId), {
          "payment.preferenceId": preference.id,
          checkoutReadyAt: FieldValue.serverTimestamp(),
        });
      });
      return {
        orderId: prepared.orderId,
        checkoutUrl,
        expiresAt: prepared.expiresAt.toISOString(),
      };
    } catch (error) {
      await requestRef.set(
        {
          status: "RETRYABLE_ERROR",
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ).catch(() => undefined);
      return callableFailure(error);
    }
  },
);

export const mercadoPagoPaymentWebhook = onRequest(
  {
    region: REGION,
    timeoutSeconds: 60,
    memory: "256MiB",
    secrets: [
      MP_CLIENT_SECRET,
      MP_TOKEN_ENCRYPTION_KEY,
      MP_WEBHOOK_SECRET,
    ],
  },
  async (request, response) => {
    const notificationType = String(
      request.body?.type ?? request.query.type ?? request.query.topic ?? "",
    );
    if (notificationType && notificationType !== "payment") {
      response.status(200).send("ignored");
      return;
    }
    const paymentId = String(
      request.body?.data?.id ??
      request.query["data.id"] ??
      request.query.id ??
      "",
    ).toLowerCase();
    const companyId = queryString(request.query.companyId);
    const signatureHeader = request.get("x-signature") ?? "";
    const requestId = request.get("x-request-id") ?? "";
    if (
      !paymentId ||
      !companyId ||
      !requestId ||
      !validateWebhookSignature({
        dataId: paymentId,
        requestId,
        signatureHeader,
      })
    ) {
      response.status(401).send("invalid signature");
      return;
    }

    try {
      const credentials = await getSellerCredentials(db(), companyId);
      const payment = await getPayment(credentials.accessToken, paymentId);
      await applyPaymentUpdate({
        db: db(),
        companyId,
        expectedSellerId: credentials.sellerId,
        payment,
      });
      response.status(200).send("ok");
    } catch (error) {
      logger.error("Mercado Pago webhook processing failed", {
        companyId,
        paymentId,
        errorName: error instanceof Error ? error.name : "UnknownError",
        errorMessage: error instanceof Error ? error.message : "Unknown error",
      });
      response.status(500).send("retry");
    }
  },
);

export const refundMarketplaceOrder = onCall(
  {
    region: REGION,
    timeoutSeconds: 60,
    memory: "128MiB",
    enforceAppCheck: MP_ENFORCE_APP_CHECK,
    secrets: [MP_CLIENT_SECRET, MP_TOKEN_ENCRYPTION_KEY],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Entre para estornar o pedido");
    }
    try {
      const orderId = requiredString(request.data?.orderId, "Pedido");
      const orderSnapshot = await db().collection("orders").doc(orderId).get();
      if (!orderSnapshot.exists) {
        throw new HttpsError("not-found", "Pedido nao encontrado");
      }
      const order = orderSnapshot.data()!;
      const companyId = requiredString(order.companyID, "Petshop do pedido");
      await requireCompanyAdmin(db(), request.auth.uid, companyId);
      if (order.financialPosted !== true) {
        throw new HttpsError("failed-precondition", "Pedido ainda nao foi pago");
      }
      const paymentId = requiredString(
        order.payment?.providerPaymentId,
        "Pagamento do pedido",
      );
      const credentials = await getSellerCredentials(db(), companyId);
      const idempotencyKey = createHash("sha256")
        .update(`full-refund:${companyId}:${orderId}:${paymentId}`)
        .digest("hex");
      await refundPayment(credentials.accessToken, paymentId, idempotencyKey);
      await orderSnapshot.ref.update({
        refundRequestedAt: FieldValue.serverTimestamp(),
        refundRequestedBy: request.auth.uid,
      });
      return { accepted: true, orderId };
    } catch (error) {
      return callableFailure(error);
    }
  },
);

export const releaseExpiredMarketplaceReservations = onSchedule(
  {
    region: REGION,
    schedule: "every 5 minutes",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const snapshot = await db()
      .collection("orders")
      .where("stockReservationStatus", "==", "RESERVED")
      .where("stockReservationExpiresAt", "<=", Timestamp.now())
      .limit(100)
      .get();
    for (const order of snapshot.docs) {
      await releaseStockReservation(db(), order.id, "CHECKOUT_EXPIRED");
    }
    logger.info("Expired marketplace reservations released", {
      count: snapshot.size,
    });
  },
);

export const notifyApprovedMarketplaceOrder = onDocumentUpdated(
  {
    region: REGION,
    document: "orders/{orderId}",
    timeoutSeconds: 60,
    memory: "128MiB",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (
      !after ||
      after.paymentProvider !== "MERCADO_PAGO" ||
      before?.paymentStatus === "PAYMENT_APPROVED" ||
      after.paymentStatus !== "PAYMENT_APPROVED"
    ) {
      return;
    }

    const orderId = event.params.orderId;
    const companyId = String(after.companyID ?? "");
    const userId = String(after.user ?? "");
    const adminSnapshot = await db()
      .collection("admins")
      .where("companyID", "==", companyId)
      .get();
    const recipientIds = [
      ...new Set([
        userId,
        ...adminSnapshot.docs.map((document) => document.id),
      ].filter(Boolean)),
    ];
    const tokenSnapshots = await Promise.all(
      recipientIds.map((uid) =>
        db().collection("users").doc(uid).collection("tokens").get(),
      ),
    );
    const tokens = [
      ...new Set(
        tokenSnapshots.flatMap((snapshot) =>
          snapshot.docs.map((document) =>
            String(document.data().token ?? document.id),
          ),
        ),
      ),
    ].filter(Boolean);
    if (tokens.length === 0) return;

    for (let offset = 0; offset < tokens.length; offset += 500) {
      await getMessaging().sendEachForMulticast({
        tokens: tokens.slice(offset, offset + 500),
        notification: {
          title: "Pagamento aprovado",
          body: `Pedido #${orderId} confirmado no Mercado Pago`,
        },
        data: {
          type: "marketplace_order_paid",
          orderId,
          companyId,
        },
      });
    }
  },
);
