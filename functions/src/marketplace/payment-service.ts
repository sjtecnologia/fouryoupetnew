import {
  FieldValue,
  Firestore,
} from "firebase-admin/firestore";
import { MercadoPagoPayment } from "./mercado-pago-client";
import { releaseStockReservation } from "./order-service";

function internalPaymentStatus(status: string, refundedCents: number): string {
  if (status === "approved" && refundedCents > 0) {
    return "PAYMENT_PARTIALLY_REFUNDED";
  }
  const statuses: Record<string, string> = {
    approved: "PAYMENT_APPROVED",
    pending: "PAYMENT_PENDING",
    in_process: "PAYMENT_IN_PROCESS",
    rejected: "PAYMENT_REJECTED",
    cancelled: "PAYMENT_CANCELLED",
    refunded: "PAYMENT_REFUNDED",
    charged_back: "PAYMENT_CHARGED_BACK",
  };
  return statuses[status] ?? "PAYMENT_UNKNOWN";
}

function loyaltyMultiplier(tier: unknown): number {
  const multipliers: Record<string, number> = {
    bronze: 1,
    silver: 1.2,
    gold: 1.5,
    platinum: 2,
  };
  return multipliers[String(tier ?? "bronze")] ?? 1;
}

function loyaltyTier(points: number): string {
  if (points >= 10_000) return "platinum";
  if (points >= 5_000) return "gold";
  if (points >= 2_000) return "silver";
  return "bronze";
}

export async function applyPaymentUpdate(input: {
  db: Firestore;
  companyId: string;
  expectedSellerId: string;
  payment: MercadoPagoPayment;
}): Promise<void> {
  const { db, companyId, expectedSellerId, payment } = input;
  const orderId = payment.externalReference;
  if (!orderId) throw new Error("Payment has no external reference");
  const orderRef = db.collection("orders").doc(orderId);
  const initialOrderSnapshot = await orderRef.get();
  if (!initialOrderSnapshot.exists) throw new Error("Order not found");
  const initialOrder = initialOrderSnapshot.data()!;

  if (initialOrder.companyID !== companyId) {
    throw new Error("Webhook company does not match order company");
  }
  if (payment.collectorId && payment.collectorId !== expectedSellerId) {
    throw new Error("Payment collector does not match connected seller");
  }
  if (Number(initialOrder.totalPaidCents) !== payment.transactionAmountCents) {
    throw new Error("Payment amount does not match order total");
  }

  if (payment.status === "rejected" || payment.status === "cancelled") {
    await releaseStockReservation(db, orderId, `MERCADO_PAGO_${payment.status.toUpperCase()}`);
  }

  const status = internalPaymentStatus(payment.status, payment.refundedAmountCents);
  const eventId = `${payment.id}_${payment.status}_${payment.refundedAmountCents}`;
  const eventRef = db.collection("payment_events").doc(eventId);

  await db.runTransaction(async (transaction) => {
    const [orderSnapshot, eventSnapshot] = await Promise.all([
      transaction.get(orderRef),
      transaction.get(eventRef),
    ]);
    if (eventSnapshot.exists) return;
    if (!orderSnapshot.exists) throw new Error("Order disappeared during payment update");
    const order = orderSnapshot.data()!;
    const period = String(order.commissionPeriod ?? "");
    const periodRef = db
      .collection("companys")
      .doc(companyId)
      .collection("commission_periods")
      .doc(period);
    const loyaltyRef = db.collection("loyalty_programs").doc(String(order.user));
    const couponId = order.couponId ? String(order.couponId) : null;
    const couponRef = couponId ? db.collection("couponcode").doc(couponId) : null;
    const couponUsageRef = couponId
      ? db.collection("coupon_usage").doc(`${couponId}_${String(order.user)}`)
      : null;

    const extraSnapshots = await Promise.all([
      transaction.get(periodRef),
      transaction.get(loyaltyRef),
      ...(couponRef ? [transaction.get(couponRef)] : []),
      ...(couponUsageRef ? [transaction.get(couponUsageRef)] : []),
    ]);
    const loyaltySnapshot = extraSnapshots[1];
    const couponSnapshot = couponRef ? extraSnapshots[2] : undefined;
    const couponUsageSnapshot = couponUsageRef
      ? extraSnapshots[couponRef ? 3 : 2]
      : undefined;

    transaction.create(eventRef, {
      provider: "MERCADO_PAGO",
      paymentId: payment.id,
      orderId,
      companyId,
      providerStatus: payment.status,
      statusDetail: payment.statusDetail ?? null,
      refundedAmountCents: payment.refundedAmountCents,
      createdAt: FieldValue.serverTimestamp(),
    });

    const providerMetadataUpdate = {
      "payment.providerPaymentId": payment.id,
      "payment.providerStatus": payment.status,
      "payment.statusDetail": payment.statusDetail ?? null,
      "payment.methodId": payment.paymentMethodId ?? null,
      "payment.typeId": payment.paymentTypeId ?? null,
      paymentUpdatedAt: FieldValue.serverTimestamp(),
    };
    const commonPaymentUpdate = {
      ...providerMetadataUpdate,
      paymentStatus: status,
      "payment.status": status,
    };

    if (
      payment.status === "approved" &&
      payment.refundedAmountCents === 0 &&
      order.financialPosted !== true
    ) {
      if (order.stockReservationStatus !== "RESERVED") {
        transaction.update(orderRef, {
          ...commonPaymentUpdate,
          paymentStatus: "PAYMENT_REVIEW_REQUIRED",
          "payment.status": "PAYMENT_REVIEW_REQUIRED",
          paymentReviewReason: "STOCK_RESERVATION_NOT_AVAILABLE",
        });
        return;
      }

      const eligibleCents = Number(order.commissionEligibleAmountCents ?? 0);
      const marketplaceFeeCents = Number(order.marketplaceFeeCents ?? 0);
      const totalCents = Number(order.totalPaidCents ?? 0);
      const deliveryCents = Number(order.deliveryCents ?? 0);
      transaction.set(
        periodRef,
        {
          eligibleNetCents: FieldValue.increment(eligibleCents),
          grossPaidCents: FieldValue.increment(totalCents),
          deliveryPaidCents: FieldValue.increment(deliveryCents),
          marketplaceFeeCents: FieldValue.increment(marketplaceFeeCents),
          orderCount: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      const loyalty = loyaltySnapshot.data() ?? {};
      const currentPoints = Number(loyalty.currentPoints ?? 0);
      const totalEarned = Number(loyalty.totalPointsEarned ?? 0);
      const points = Math.round((eligibleCents / 100) * loyaltyMultiplier(loyalty.currentTier));
      const newPoints = currentPoints + points;
      const pointsRef = db.collection("points_transactions").doc(`payment_${orderId}`);
      transaction.set(
        loyaltyRef,
        {
          id: loyalty.id ?? loyaltyRef.id,
          userId: order.user,
          currentPoints: newPoints,
          totalPointsEarned: totalEarned + points,
          totalPointsRedeemed: Number(loyalty.totalPointsRedeemed ?? 0),
          currentTier: loyaltyTier(newPoints),
          joinedAt: loyalty.joinedAt ?? FieldValue.serverTimestamp(),
          lastUpdated: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.create(pointsRef, {
        id: pointsRef.id,
        userId: order.user,
        points,
        type: "earned",
        description: `Compra aprovada - Pedido #${orderId}`,
        orderId,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: null,
        isExpired: false,
        metadata: {
          eligibleAmountCents: eligibleCents,
          paymentId: payment.id,
        },
      });

      if (couponRef && couponUsageRef && !couponUsageSnapshot?.exists) {
        transaction.create(couponUsageRef, {
          couponId,
          userId: order.user,
          orderId,
          usedAt: FieldValue.serverTimestamp(),
        });
        if (couponSnapshot?.exists) {
          transaction.update(couponRef, {
            usageCount: FieldValue.increment(1),
            usedBy: FieldValue.arrayUnion(order.user),
          });
        }
      }

      transaction.update(orderRef, {
        ...commonPaymentUpdate,
        financialPosted: true,
        stockReservationStatus: "CONSUMED",
        paidAt: payment.dateApproved
          ? new Date(payment.dateApproved)
          : FieldValue.serverTimestamp(),
        loyaltyPointsAwarded: points,
      });
      return;
    }

    const isReversal =
      payment.status === "refunded" ||
      payment.status === "charged_back" ||
      payment.refundedAmountCents > 0;
    if (isReversal && order.financialPosted === true) {
      const totalCents = Number(order.totalPaidCents ?? 0);
      const eligibleCents = Number(order.commissionEligibleAmountCents ?? 0);
      const feeCents = Number(order.marketplaceFeeCents ?? 0);
      const effectiveRefundCents = payment.status === "charged_back"
        ? totalCents
        : Math.min(totalCents, payment.refundedAmountCents);
      const targetReversedEligible = totalCents > 0
        ? Math.round((eligibleCents * effectiveRefundCents) / totalCents)
        : 0;
      const targetReversedFee = totalCents > 0
        ? Math.round((feeCents * effectiveRefundCents) / totalCents)
        : 0;
      const deliveryCents = Number(order.deliveryCents ?? 0);
      const targetReversedDelivery = totalCents > 0
        ? Math.round((deliveryCents * effectiveRefundCents) / totalCents)
        : 0;
      const oldReversedEligible = Number(order.reversedEligibleAmountCents ?? 0);
      const oldReversedFee = Number(order.reversedMarketplaceFeeCents ?? 0);
      const oldReversedGross = Number(order.reversedGrossAmountCents ?? 0);
      const oldReversedDelivery = Number(order.reversedDeliveryAmountCents ?? 0);
      const eligibleDelta = Math.max(0, targetReversedEligible - oldReversedEligible);
      const feeDelta = Math.max(0, targetReversedFee - oldReversedFee);
      const grossDelta = Math.max(0, effectiveRefundCents - oldReversedGross);
      const deliveryDelta = Math.max(
        0,
        targetReversedDelivery - oldReversedDelivery,
      );

      if (eligibleDelta > 0 || feeDelta > 0 || grossDelta > 0) {
        transaction.set(
          periodRef,
          {
            eligibleNetCents: FieldValue.increment(-eligibleDelta),
            grossPaidCents: FieldValue.increment(-grossDelta),
            deliveryPaidCents: FieldValue.increment(-deliveryDelta),
            eligibleRefundCents: FieldValue.increment(
              payment.status === "charged_back" ? 0 : eligibleDelta,
            ),
            eligibleChargebackCents: FieldValue.increment(
              payment.status === "charged_back" ? eligibleDelta : 0,
            ),
            grossRefundedCents: FieldValue.increment(
              payment.status === "charged_back" ? 0 : grossDelta,
            ),
            grossChargebackCents: FieldValue.increment(
              payment.status === "charged_back" ? grossDelta : 0,
            ),
            marketplaceFeeCents: FieldValue.increment(-feeDelta),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      const originallyAwarded = Number(order.loyaltyPointsAwarded ?? 0);
      const targetPointsReversed = totalCents > 0
        ? Math.round((originallyAwarded * effectiveRefundCents) / totalCents)
        : 0;
      const oldPointsReversed = Number(order.loyaltyPointsReversed ?? 0);
      const pointsDelta = Math.max(0, targetPointsReversed - oldPointsReversed);
      if (pointsDelta > 0 && loyaltySnapshot.exists) {
        const loyalty = loyaltySnapshot.data()!;
        const currentPoints = Number(loyalty.currentPoints ?? 0);
        const newPoints = Math.max(0, currentPoints - pointsDelta);
        transaction.update(loyaltyRef, {
          currentPoints: newPoints,
          currentTier: loyaltyTier(newPoints),
          lastUpdated: FieldValue.serverTimestamp(),
        });
        const reversalRef = db
          .collection("points_transactions")
          .doc(`reversal_${orderId}_${effectiveRefundCents}`);
        transaction.create(reversalRef, {
          id: reversalRef.id,
          userId: order.user,
          points: -pointsDelta,
          type: "expired",
          description: `Estorno - Pedido #${orderId}`,
          orderId,
          createdAt: FieldValue.serverTimestamp(),
          expiresAt: null,
          isExpired: false,
          metadata: { paymentId: payment.id, effectiveRefundCents },
        });
      }

      transaction.update(orderRef, {
        ...commonPaymentUpdate,
        status: effectiveRefundCents >= totalCents ? 0 : order.status,
        reversedEligibleAmountCents: targetReversedEligible,
        reversedMarketplaceFeeCents: targetReversedFee,
        reversedGrossAmountCents: effectiveRefundCents,
        reversedDeliveryAmountCents: targetReversedDelivery,
        loyaltyPointsReversed: targetPointsReversed,
      });
      return;
    }

    transaction.update(
      orderRef,
      order.financialPosted === true
        ? providerMetadataUpdate
        : commonPaymentUpdate,
    );
  });
}
