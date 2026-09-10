import axios from "axios";

const API_BASE_URL = "https://api.mercadopago.com";

export interface MercadoPagoOAuthCredentials {
  accessToken: string;
  refreshToken: string;
  publicKey?: string;
  sellerId: string;
  expiresAt: number;
  liveMode: boolean;
  scope?: string;
}

export interface MercadoPagoPreferenceInput {
  orderId: string;
  title: string;
  totalCents: number;
  marketplaceFeeCents: number;
  payerEmail?: string;
  notificationUrl: string;
  returnUrl: string;
  expiresAt: Date;
}

export interface MercadoPagoPreferenceResult {
  id: string;
  initPoint: string;
  sandboxInitPoint?: string;
}

export interface MercadoPagoPayment {
  id: string;
  status: string;
  statusDetail?: string;
  externalReference?: string;
  transactionAmountCents: number;
  refundedAmountCents: number;
  collectorId?: string;
  dateApproved?: string;
  paymentMethodId?: string;
  paymentTypeId?: string;
}

function formBody(values: Record<string, string>): URLSearchParams {
  const body = new URLSearchParams();
  for (const [key, value] of Object.entries(values)) body.set(key, value);
  return body;
}

function parseOAuthCredentials(data: Record<string, unknown>): MercadoPagoOAuthCredentials {
  const accessToken = String(data.access_token ?? "");
  const refreshToken = String(data.refresh_token ?? "");
  const sellerId = String(data.user_id ?? "");
  const expiresIn = Number(data.expires_in ?? 0);
  if (!accessToken || !refreshToken || !sellerId || !Number.isFinite(expiresIn)) {
    throw new Error("Mercado Pago returned incomplete OAuth credentials");
  }
  return {
    accessToken,
    refreshToken,
    publicKey: data.public_key ? String(data.public_key) : undefined,
    sellerId,
    expiresAt: Date.now() + expiresIn * 1000,
    liveMode: data.live_mode === true,
    scope: data.scope ? String(data.scope) : undefined,
  };
}

export async function exchangeAuthorizationCode(input: {
  clientId: string;
  clientSecret: string;
  code: string;
  redirectUri: string;
  state: string;
}): Promise<MercadoPagoOAuthCredentials> {
  const response = await axios.post(
    `${API_BASE_URL}/oauth/token`,
    formBody({
      client_id: input.clientId,
      client_secret: input.clientSecret,
      grant_type: "authorization_code",
      code: input.code,
      redirect_uri: input.redirectUri,
      state: input.state,
    }),
    {
      headers: {
        accept: "application/json",
        "content-type": "application/x-www-form-urlencoded",
      },
      timeout: 20_000,
    },
  );
  return parseOAuthCredentials(response.data as Record<string, unknown>);
}

export async function refreshOAuthCredentials(input: {
  clientId: string;
  clientSecret: string;
  refreshToken: string;
}): Promise<MercadoPagoOAuthCredentials> {
  const response = await axios.post(
    `${API_BASE_URL}/oauth/token`,
    formBody({
      client_id: input.clientId,
      client_secret: input.clientSecret,
      grant_type: "refresh_token",
      refresh_token: input.refreshToken,
    }),
    {
      headers: {
        accept: "application/json",
        "content-type": "application/x-www-form-urlencoded",
      },
      timeout: 20_000,
    },
  );
  return parseOAuthCredentials(response.data as Record<string, unknown>);
}

export async function createCheckoutPreference(
  accessToken: string,
  input: MercadoPagoPreferenceInput,
  idempotencyKey: string,
): Promise<MercadoPagoPreferenceResult> {
  const response = await axios.post(
    `${API_BASE_URL}/checkout/preferences`,
    {
      items: [
        {
          id: input.orderId,
          title: input.title,
          currency_id: "BRL",
          quantity: 1,
          unit_price: input.totalCents / 100,
        },
      ],
      payer: input.payerEmail ? { email: input.payerEmail } : undefined,
      external_reference: input.orderId,
      marketplace_fee: input.marketplaceFeeCents / 100,
      notification_url: input.notificationUrl,
      back_urls: {
        success: `${input.returnUrl}?orderId=${encodeURIComponent(input.orderId)}&status=success`,
        pending: `${input.returnUrl}?orderId=${encodeURIComponent(input.orderId)}&status=pending`,
        failure: `${input.returnUrl}?orderId=${encodeURIComponent(input.orderId)}&status=failure`,
      },
      auto_return: "approved",
      expires: true,
      expiration_date_to: input.expiresAt.toISOString(),
      statement_descriptor: "4YOUPET",
    },
    {
      headers: {
        accept: "application/json",
        "content-type": "application/json",
        authorization: `Bearer ${accessToken}`,
        "x-idempotency-key": idempotencyKey,
      },
      timeout: 20_000,
    },
  );
  const data = response.data as Record<string, unknown>;
  const id = String(data.id ?? "");
  const initPoint = String(data.init_point ?? "");
  if (!id || !initPoint) {
    throw new Error("Mercado Pago returned an incomplete preference");
  }
  return {
    id,
    initPoint,
    sandboxInitPoint: data.sandbox_init_point
      ? String(data.sandbox_init_point)
      : undefined,
  };
}

export async function getPayment(
  accessToken: string,
  paymentId: string,
): Promise<MercadoPagoPayment> {
  const response = await axios.get(
    `${API_BASE_URL}/v1/payments/${encodeURIComponent(paymentId)}`,
    {
      headers: {
        accept: "application/json",
        authorization: `Bearer ${accessToken}`,
      },
      timeout: 20_000,
    },
  );
  const data = response.data as Record<string, unknown>;
  return {
    id: String(data.id ?? paymentId),
    status: String(data.status ?? "unknown"),
    statusDetail: data.status_detail ? String(data.status_detail) : undefined,
    externalReference: data.external_reference
      ? String(data.external_reference)
      : undefined,
    transactionAmountCents: Math.round(Number(data.transaction_amount ?? 0) * 100),
    refundedAmountCents: Math.round(Number(data.transaction_amount_refunded ?? 0) * 100),
    collectorId: data.collector_id ? String(data.collector_id) : undefined,
    dateApproved: data.date_approved ? String(data.date_approved) : undefined,
    paymentMethodId: data.payment_method_id
      ? String(data.payment_method_id)
      : undefined,
    paymentTypeId: data.payment_type_id ? String(data.payment_type_id) : undefined,
  };
}

export async function refundPayment(
  accessToken: string,
  paymentId: string,
  idempotencyKey: string,
): Promise<void> {
  await axios.post(
    `${API_BASE_URL}/v1/payments/${encodeURIComponent(paymentId)}/refunds`,
    {},
    {
      headers: {
        accept: "application/json",
        "content-type": "application/json",
        authorization: `Bearer ${accessToken}`,
        "x-idempotency-key": idempotencyKey,
      },
      timeout: 20_000,
    },
  );
}
