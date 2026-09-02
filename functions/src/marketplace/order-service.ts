import { createHash } from "node:crypto";
import {
  DocumentData,
  DocumentReference,
  DocumentSnapshot,
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import {
  calculateCommissionCents,
  NEW_SELLER_RATE_BPS,
  periodKeyInSaoPaulo,
  previousPeriodKey,
  rateBpsForPreviousMonthVolume,
} from "./commission";

export interface CheckoutItemInput {
  productId: string;
  size: string;
  quantity: number;
}

export interface CreateCheckoutInput {
  companyId: string;
  clientRequestId: string;
  items: CheckoutItemInput[];
  couponCode?: string;
}

export interface PreparedCheckout {
  orderId: string;
  companyId: string;
  requestDocumentId: string;
  payerEmail?: string;
  productSubtotalCents: number;
  discountCents: number;
  deliveryCents: number;
  totalCents: number;
  eligibleAmountCents: number;
  marketplaceFeeCents: number;
  commissionRateBps: number;
  commissionPeriod: string;
  expiresAt: Date;
}

interface ProductState {
  id: string;
  data: DocumentData;
  sizes: Array<Record<string, unknown>>;
}

const MAX_CHECKOUT_ITEMS = 50;
const MAX_ITEM_QUANTITY = 100;
const RESERVATION_MINUTES = 30;

function moneyToCents(value: unknown): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed < 0) {
    throw new HttpsError("failed-precondition", "Valor monetario invalido");
  }
  return Math.round(parsed * 100);
}

function normalizeItems(items: unknown): CheckoutItemInput[] {
  if (!Array.isArray(items) || items.length === 0 || items.length > MAX_CHECKOUT_ITEMS) {
    throw new HttpsError("invalid-argument", "Carrinho invalido");
  }

  const aggregated = new Map<string, CheckoutItemInput>();
  for (const raw of items) {
    if (!raw || typeof raw !== "object") {
      throw new HttpsError("invalid-argument", "Item de carrinho invalido");
    }
    const value = raw as Record<string, unknown>;
    const productId = String(value.productId ?? "").trim();
    const size = String(value.size ?? "").trim();
    const quantity = Number(value.quantity);
    if (
      !productId ||
      !size ||
      !Number.isInteger(quantity) ||
      quantity < 1 ||
      quantity > MAX_ITEM_QUANTITY
    ) {
      throw new HttpsError("invalid-argument", "Produto, variacao ou quantidade invalida");
    }
    const key = `${productId}\u0000${size}`;
    const existing = aggregated.get(key);
    const newQuantity = (existing?.quantity ?? 0) + quantity;
    if (newQuantity > MAX_ITEM_QUANTITY) {
      throw new HttpsError("invalid-argument", "Quantidade maxima excedida");
    }
    aggregated.set(key, { productId, size, quantity: newQuantity });
  }
  return [...aggregated.values()];
}

export function checkoutRequestDocumentId(
  uid: string,
  clientRequestId: string,
): string {
  if (!/^[a-zA-Z0-9_-]{16,80}$/.test(clientRequestId)) {
    throw new HttpsError("invalid-argument", "clientRequestId invalido");
  }
  return createHash("sha256").update(`${uid}:${clientRequestId}`).digest("hex");
}

function selectedAddress(user: DocumentData): Record<string, unknown> {
  const addresses: unknown[] = Array.isArray(user.address) ? user.address : [];
  const address = addresses.find(
    (candidate) =>
      candidate !== null &&
      typeof candidate === "object" &&
      (candidate as Record<string, unknown>).checked === true,
  );
  if (!address) {
    throw new HttpsError("failed-precondition", "Selecione um endereco de entrega");
  }
  return address as Record<string, unknown>;
}

function numberField(value: unknown, fieldName: string): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new HttpsError("failed-precondition", `${fieldName} nao configurado`);
  }
  return parsed;
}

function distanceKm(
  fromLat: number,
  fromLong: number,
  toLat: number,
  toLong: number,
): number {
  const radians = (value: number) => (value * Math.PI) / 180;
  const earthRadiusKm = 6371;
  const latDistance = radians(toLat - fromLat);
  const longDistance = radians(toLong - fromLong);
  const a =
    Math.sin(latDistance / 2) ** 2 +
    Math.cos(radians(fromLat)) *
      Math.cos(radians(toLat)) *
      Math.sin(longDistance / 2) ** 2;
  return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function calculateDeliveryCents(
  company: DocumentData,
  address: Record<string, unknown>,
): number {
  if (company.delivery === false) return 0;
  const companyAddress = company.address as Record<string, unknown> | undefined;
  if (!companyAddress) {
    throw new HttpsError("failed-precondition", "Endereco do petshop nao configurado");
  }

  const distance = distanceKm(
    numberField(companyAddress.lat, "Latitude do petshop"),
    numberField(companyAddress.long, "Longitude do petshop"),
    numberField(address.lat, "Latitude do cliente"),
    numberField(address.long, "Longitude do cliente"),
  );
  const maximumKm = numberField(company.maxkm ?? 0, "Raio maximo");
  if (maximumKm > 0 && distance > maximumKm) {
    throw new HttpsError("failed-precondition", "Endereco fora do raio de entrega");
  }
  const freeDistanceKm = Number(company.minkm ?? 0);
  if (distance <= freeDistanceKm) return 0;

  const baseCents = moneyToCents(company.base ?? 0);
  const pricePerKmCents = moneyToCents(company.km ?? 0);
  return Math.max(0, Math.round(baseCents + distance * pricePerKmCents));
}

function couponDiscountCents(input: {
  coupon?: DocumentData;
  subtotalCents: number;
  uid: string;
  couponAlreadyUsed: boolean;
  now: Date;
}): number {
  const coupon = input.coupon;
  if (!coupon) return 0;
  if (coupon.isActive !== true || input.couponAlreadyUsed) {
    throw new HttpsError("failed-precondition", "Cupom indisponivel");
  }
  const expiration = coupon.expirationDate;
  if (expiration instanceof Timestamp && expiration.toDate() <= input.now) {
    throw new HttpsError("failed-precondition", "Cupom expirado");
  }
  if (input.subtotalCents < moneyToCents(coupon.minimumValue ?? 0)) {
    throw new HttpsError("failed-precondition", "Valor minimo do cupom nao atingido");
  }
  const usageCount = Number(coupon.usageCount ?? 0);
  const maximumUses = coupon.maxUses == null ? null : Number(coupon.maxUses);
  if (maximumUses !== null && usageCount >= maximumUses) {
    throw new HttpsError("failed-precondition", "Cupom esgotado");
  }
  const usedBy = Array.isArray(coupon.usedBy) ? coupon.usedBy : [];
  if (usedBy.includes(input.uid)) {
    throw new HttpsError("failed-precondition", "Cupom ja utilizado por este usuario");
  }

  let discountCents: number;
  if (coupon.discountType === "percentage") {
    const percentage = Number(coupon.discountValue ?? 0);
    discountCents = Math.round((input.subtotalCents * percentage) / 100);
  } else {
    discountCents = moneyToCents(coupon.discountValue ?? 0);
  }
  if (coupon.maxDiscount != null) {
    discountCents = Math.min(discountCents, moneyToCents(coupon.maxDiscount));
  }
  return Math.max(0, Math.min(input.subtotalCents, discountCents));
}

export async function prepareCheckout(
  db: Firestore,
  uid: string,
  rawInput: CreateCheckoutInput,
  now = new Date(),
): Promise<PreparedCheckout> {
  const companyId = String(rawInput.companyId ?? "").trim();
  if (!companyId) throw new HttpsError("invalid-argument", "Petshop obrigatorio");
  const items = normalizeItems(rawInput.items);
  const requestId = checkoutRequestDocumentId(
    uid,
    String(rawInput.clientRequestId ?? ""),
  );
  const couponCode = String(rawInput.couponCode ?? "").trim().toUpperCase();
  const couponQuery = couponCode
    ? await db.collection("couponcode").where("code", "==", couponCode).limit(1).get()
    : null;
  if (couponCode && couponQuery?.empty) {
    throw new HttpsError("not-found", "Cupom nao encontrado");
  }
  const couponRef = couponQuery?.docs[0]?.ref;

  const productIds = [...new Set(items.map((item) => item.productId))];
  const currentPeriod = periodKeyInSaoPaulo(now);
  const previousPeriod = previousPeriodKey(currentPeriod);
  const expiresAt = new Date(now.getTime() + RESERVATION_MINUTES * 60 * 1000);

  return db.runTransaction(async (transaction) => {
    const userRef = db.collection("users").doc(uid);
    const companyRef = db.collection("companys").doc(companyId);
    const integrationRef = companyRef.collection("private_integrations").doc("mercado_pago");
    const counterRef = db.doc("aux/ordercounter");
    const requestRef = db.collection("checkout_requests").doc(requestId);
    const currentPeriodRef = companyRef.collection("commission_periods").doc(currentPeriod);
    const previousPeriodRef = companyRef.collection("commission_periods").doc(previousPeriod);
    const productRefs = productIds.map((id) => db.collection("products").doc(id));

    const baseSnapshots = await Promise.all([
      transaction.get(userRef),
      transaction.get(companyRef),
      transaction.get(integrationRef),
      transaction.get(counterRef),
      transaction.get(requestRef),
      transaction.get(currentPeriodRef),
      transaction.get(previousPeriodRef),
      ...productRefs.map((ref) => transaction.get(ref)),
    ]);
    const [
      userSnapshot,
      companySnapshot,
      integrationSnapshot,
      counterSnapshot,
      existingRequestSnapshot,
      currentPeriodSnapshot,
      previousPeriodSnapshot,
      ...productSnapshots
    ] = baseSnapshots;

    if (!userSnapshot.exists) throw new HttpsError("not-found", "Usuario nao encontrado");
    if (!companySnapshot.exists) throw new HttpsError("not-found", "Petshop nao encontrado");
    if (!integrationSnapshot.exists) {
      throw new HttpsError("failed-precondition", "Petshop ainda nao conectou o Mercado Pago");
    }
    if (existingRequestSnapshot.exists) {
      const existingRequest = existingRequestSnapshot.data()!;
      if (
        existingRequest.uid !== uid ||
        existingRequest.companyId !== companyId
      ) {
        throw new HttpsError("permission-denied", "Checkout pertence a outro usuario");
      }
      const existingOrderId = String(existingRequest.orderId ?? "");
      const existingOrderSnapshot = await transaction.get(
        db.collection("orders").doc(existingOrderId),
      );
      if (!existingOrderSnapshot.exists) {
        throw new HttpsError("failed-precondition", "Pedido idempotente nao encontrado");
      }
      const existingOrder = existingOrderSnapshot.data()!;
      const existingExpiry = existingOrder.stockReservationExpiresAt;
      if (!(existingExpiry instanceof Timestamp)) {
        throw new HttpsError("failed-precondition", "Reserva do pedido invalida");
      }
      return {
        orderId: existingOrderId,
        companyId,
        requestDocumentId: requestId,
        payerEmail: userSnapshot.data()?.email
          ? String(userSnapshot.data()?.email)
          : undefined,
        productSubtotalCents: Number(existingOrder.productsSubtotalCents ?? 0),
        discountCents: Number(existingOrder.discountCents ?? 0),
        deliveryCents: Number(existingOrder.deliveryCents ?? 0),
        totalCents: Number(existingOrder.totalPaidCents ?? 0),
        eligibleAmountCents: Number(
          existingOrder.commissionEligibleAmountCents ?? 0,
        ),
        marketplaceFeeCents: Number(existingOrder.marketplaceFeeCents ?? 0),
        commissionRateBps: Number(existingOrder.commissionRateBps ?? 0),
        commissionPeriod: String(existingOrder.commissionPeriod ?? ""),
        expiresAt: existingExpiry.toDate(),
      };
    }
    if (!counterSnapshot.exists) {
      throw new HttpsError("failed-precondition", "Contador de pedidos nao configurado");
    }

    const user = userSnapshot.data()!;
    const company = companySnapshot.data()!;
    if (company.active !== true) {
      throw new HttpsError("failed-precondition", "Petshop inativo");
    }
    const address = selectedAddress(user);

    const productStates = new Map<string, ProductState>();
    productSnapshots.forEach((snapshot, index) => {
      if (!snapshot.exists) throw new HttpsError("not-found", "Produto nao encontrado");
      const data = snapshot.data()!;
      productStates.set(productIds[index], {
        id: productIds[index],
        data,
        sizes: Array.isArray(data.sizes)
          ? data.sizes.map((size: Record<string, unknown>) => ({ ...size }))
          : [],
      });
    });

    let productSubtotalCents = 0;
    const orderItems: Array<Record<string, unknown>> = [];
    for (const item of items) {
      const product = productStates.get(item.productId)!;
      if (product.data.companyID !== companyId || product.data.deleted === true) {
        throw new HttpsError("failed-precondition", "Produto indisponivel para este petshop");
      }
      const size = product.sizes.find((candidate) => candidate.name === item.size);
      if (!size) throw new HttpsError("failed-precondition", "Variacao nao encontrada");
      const availableStock = Number(size.stock ?? 0);
      if (!Number.isInteger(availableStock) || availableStock < item.quantity) {
        throw new HttpsError("failed-precondition", "Produto sem estoque suficiente");
      }
      const unitPriceCents = moneyToCents(size.price);
      size.stock = availableStock - item.quantity;
      productSubtotalCents += unitPriceCents * item.quantity;
      orderItems.push({
        pid: item.productId,
        quantity: item.quantity,
        sizes: item.size,
        companyID: companyId,
        fixedPrice: unitPriceCents / 100,
        fixedPriceCents: unitPriceCents,
        productName: String(product.data.name ?? "Produto"),
      });
    }

    let couponSnapshot: DocumentSnapshot<DocumentData> | undefined;
    let couponUsageSnapshot: DocumentSnapshot<DocumentData> | undefined;
    let couponUsageRef: DocumentReference<DocumentData> | undefined;
    if (couponRef) {
      couponUsageRef = db.collection("coupon_usage").doc(`${couponRef.id}_${uid}`);
      [couponSnapshot, couponUsageSnapshot] = await Promise.all([
        transaction.get(couponRef),
        transaction.get(couponUsageRef),
      ]);
    }
    const discountCents = couponDiscountCents({
      coupon: couponSnapshot?.data(),
      subtotalCents: productSubtotalCents,
      uid,
      couponAlreadyUsed: couponUsageSnapshot?.exists === true,
      now,
    });
    const eligibleAmountCents = productSubtotalCents - discountCents;
    const deliveryCents = calculateDeliveryCents(company, address);
    const totalCents = eligibleAmountCents + deliveryCents;
    if (totalCents <= 0) {
      throw new HttpsError("failed-precondition", "Total do pedido deve ser maior que zero");
    }

    const previousEligibleVolumeCents = Number(
      previousPeriodSnapshot.data()?.eligibleNetCents ?? 0,
    );
    const frozenRate = Number(currentPeriodSnapshot.data()?.rateBps);
    const commissionRateBps = Number.isInteger(frozenRate)
      ? frozenRate
      : previousPeriodSnapshot.exists
        ? rateBpsForPreviousMonthVolume(Math.max(0, previousEligibleVolumeCents))
        : NEW_SELLER_RATE_BPS;
    const marketplaceFeeCents = calculateCommissionCents(
      eligibleAmountCents,
      commissionRateBps,
    );

    const currentOrderNumber = Number(counterSnapshot.get("current"));
    if (!Number.isSafeInteger(currentOrderNumber) || currentOrderNumber < 1) {
      throw new HttpsError("failed-precondition", "Contador de pedidos invalido");
    }
    const orderId = String(currentOrderNumber);
    const orderRef = db.collection("orders").doc(orderId);

    for (const product of productStates.values()) {
      transaction.update(db.collection("products").doc(product.id), {
        sizes: product.sizes,
      });
    }
    transaction.update(counterRef, { current: currentOrderNumber + 1 });
    if (!currentPeriodSnapshot.exists) {
      transaction.set(currentPeriodRef, {
        period: currentPeriod,
        rateBps: commissionRateBps,
        rateSourcePeriod: previousPeriod,
        sourceEligibleNetCents: previousEligibleVolumeCents,
        eligibleNetCents: 0,
        grossPaidCents: 0,
        deliveryPaidCents: 0,
        eligibleRefundCents: 0,
        eligibleChargebackCents: 0,
        grossRefundedCents: 0,
        grossChargebackCents: 0,
        marketplaceFeeCents: 0,
        orderCount: 0,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    transaction.create(orderRef, {
      items: orderItems,
      price: (productSubtotalCents + deliveryCents) / 100,
      totalPaid: totalCents / 100,
      totalPaidCents: totalCents,
      productsSubtotalCents: productSubtotalCents,
      frete: deliveryCents / 100,
      deliveryCents,
      discount: discountCents / 100,
      discountCents,
      commissionEligibleAmountCents: eligibleAmountCents,
      commissionRateBps,
      marketplaceFeeCents,
      commissionPeriod: currentPeriod,
      user: uid,
      address,
      status: 1,
      date: FieldValue.serverTimestamp(),
      payId: "Mercado Pago",
      companyID: companyId,
      trocopara: 0,
      couponCode: couponCode || null,
      couponId: couponRef?.id ?? null,
      paymentStatus: "PAYMENT_PENDING",
      paymentProvider: "MERCADO_PAGO",
      stockReservationStatus: "RESERVED",
      stockReservationExpiresAt: Timestamp.fromDate(expiresAt),
      checkoutRequestId: requestId,
      payment: {
        provider: "MERCADO_PAGO",
        status: "PAYMENT_PENDING",
      },
    });
    transaction.create(requestRef, {
      uid,
      companyId,
      orderId,
      status: "PROCESSING",
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromDate(expiresAt),
    });

    return {
      orderId,
      companyId,
      requestDocumentId: requestId,
      payerEmail: user.email ? String(user.email) : undefined,
      productSubtotalCents,
      discountCents,
      deliveryCents,
      totalCents,
      eligibleAmountCents,
      marketplaceFeeCents,
      commissionRateBps,
      commissionPeriod: currentPeriod,
      expiresAt,
    };
  });
}

export async function releaseStockReservation(
  db: Firestore,
  orderId: string,
  reason: string,
): Promise<boolean> {
  return db.runTransaction(async (transaction) => {
    const orderRef = db.collection("orders").doc(orderId);
    const orderSnapshot = await transaction.get(orderRef);
    if (!orderSnapshot.exists) return false;
    const order = orderSnapshot.data()!;
    if (order.stockReservationStatus !== "RESERVED") return false;

    const items: unknown[] = Array.isArray(order.items) ? order.items : [];
    const productIds = [
      ...new Set(
        items.map((item) =>
          String((item as Record<string, unknown>).pid),
        ),
      ),
    ];
    const productRefs = productIds.map((id) => db.collection("products").doc(id));
    const productSnapshots = await Promise.all(
      productRefs.map((ref) => transaction.get(ref)),
    );
    const states = new Map<string, Array<Record<string, unknown>>>();
    productSnapshots.forEach((snapshot, index) => {
      if (!snapshot.exists) return;
      const sizes = snapshot.data()?.sizes;
      states.set(
        productIds[index],
        Array.isArray(sizes)
          ? sizes.map((size: Record<string, unknown>) => ({ ...size }))
          : [],
      );
    });

    for (const rawItem of items) {
      const item = rawItem as Record<string, unknown>;
      const productId = String(item.pid);
      const sizes = states.get(productId);
      const size = sizes?.find((candidate) => candidate.name === item.sizes);
      if (size) size.stock = Number(size.stock ?? 0) + Number(item.quantity ?? 0);
    }
    for (const [productId, sizes] of states) {
      transaction.update(db.collection("products").doc(productId), { sizes });
    }
    transaction.update(orderRef, {
      stockReservationStatus: "RELEASED",
      stockReservationReleaseReason: reason,
      stockReservationReleasedAt: FieldValue.serverTimestamp(),
      paymentStatus:
        order.paymentStatus === "PAYMENT_PENDING"
          ? "PAYMENT_EXPIRED"
          : order.paymentStatus,
      "payment.status":
        order.paymentStatus === "PAYMENT_PENDING"
          ? "PAYMENT_EXPIRED"
          : order.paymentStatus,
    });
    return true;
  });
}
