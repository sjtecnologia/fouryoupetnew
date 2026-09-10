export interface CommissionBracket {
  maxEligibleVolumeCents: number | null;
  rateBps: number;
}

/**
 * Contract schedule expressed in basis points.
 * 500 bps = 5.00%, 40 bps = 0.40%.
 */
export const COMMISSION_BRACKETS: readonly CommissionBracket[] = [
  { maxEligibleVolumeCents: 300_000, rateBps: 500 },
  { maxEligibleVolumeCents: 600_000, rateBps: 450 },
  { maxEligibleVolumeCents: 1_000_000, rateBps: 400 },
  { maxEligibleVolumeCents: 1_500_000, rateBps: 350 },
  { maxEligibleVolumeCents: 2_200_000, rateBps: 300 },
  { maxEligibleVolumeCents: 3_200_000, rateBps: 250 },
  { maxEligibleVolumeCents: 4_500_000, rateBps: 200 },
  { maxEligibleVolumeCents: 6_000_000, rateBps: 180 },
  { maxEligibleVolumeCents: 8_000_000, rateBps: 160 },
  { maxEligibleVolumeCents: 10_000_000, rateBps: 140 },
  { maxEligibleVolumeCents: 12_000_000, rateBps: 120 },
  { maxEligibleVolumeCents: 14_000_000, rateBps: 100 },
  { maxEligibleVolumeCents: 16_000_000, rateBps: 80 },
  { maxEligibleVolumeCents: 18_000_000, rateBps: 60 },
  { maxEligibleVolumeCents: 20_000_000, rateBps: 50 },
  { maxEligibleVolumeCents: null, rateBps: 40 },
] as const;

export const NEW_SELLER_RATE_BPS = 500;

export function rateBpsForPreviousMonthVolume(
  eligibleVolumeCents: number,
): number {
  if (!Number.isSafeInteger(eligibleVolumeCents) || eligibleVolumeCents < 0) {
    throw new Error("eligibleVolumeCents must be a non-negative integer");
  }

  return COMMISSION_BRACKETS.find(
    (bracket) =>
      bracket.maxEligibleVolumeCents === null ||
      eligibleVolumeCents <= bracket.maxEligibleVolumeCents,
  )!.rateBps;
}

export function calculateCommissionCents(
  eligibleAmountCents: number,
  rateBps: number,
): number {
  if (!Number.isSafeInteger(eligibleAmountCents) || eligibleAmountCents < 0) {
    throw new Error("eligibleAmountCents must be a non-negative integer");
  }
  if (!Number.isInteger(rateBps) || rateBps < 0 || rateBps > 10_000) {
    throw new Error("rateBps must be an integer between 0 and 10000");
  }

  return Math.round((eligibleAmountCents * rateBps) / 10_000);
}

export function periodKeyInSaoPaulo(date: Date): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Sao_Paulo",
    year: "numeric",
    month: "2-digit",
  }).formatToParts(date);
  const year = parts.find((part) => part.type === "year")?.value;
  const month = parts.find((part) => part.type === "month")?.value;
  if (!year || !month) throw new Error("Unable to calculate billing period");
  return `${year}-${month}`;
}

export function previousPeriodKey(periodKey: string): string {
  const match = /^(\d{4})-(\d{2})$/.exec(periodKey);
  if (!match) throw new Error("periodKey must use YYYY-MM");

  const year = Number(match[1]);
  const month = Number(match[2]);
  if (month < 1 || month > 12) throw new Error("Invalid month");

  const previousMonth = month === 1 ? 12 : month - 1;
  const previousYear = month === 1 ? year - 1 : year;
  return `${previousYear}-${String(previousMonth).padStart(2, "0")}`;
}
