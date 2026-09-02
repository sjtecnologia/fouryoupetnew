import assert from "node:assert/strict";
import test from "node:test";
import {
  calculateCommissionCents,
  periodKeyInSaoPaulo,
  previousPeriodKey,
  rateBpsForPreviousMonthVolume,
} from "./commission";

test("uses every contract boundary without gaps", () => {
  const boundaries = [
    [300_000, 500, 450],
    [600_000, 450, 400],
    [1_000_000, 400, 350],
    [1_500_000, 350, 300],
    [2_200_000, 300, 250],
    [3_200_000, 250, 200],
    [4_500_000, 200, 180],
    [6_000_000, 180, 160],
    [8_000_000, 160, 140],
    [10_000_000, 140, 120],
    [12_000_000, 120, 100],
    [14_000_000, 100, 80],
    [16_000_000, 80, 60],
    [18_000_000, 60, 50],
    [20_000_000, 50, 40],
  ] as const;
  assert.equal(rateBpsForPreviousMonthVolume(0), 500);
  for (const [boundary, atBoundary, immediatelyAbove] of boundaries) {
    assert.equal(rateBpsForPreviousMonthVolume(boundary), atBoundary);
    assert.equal(
      rateBpsForPreviousMonthVolume(boundary + 1),
      immediatelyAbove,
    );
  }
});

test("calculates the marketplace fee in integer cents", () => {
  assert.equal(calculateCommissionCents(10_000, 500), 500);
  assert.equal(calculateCommissionCents(10_001, 450), 450);
  assert.equal(calculateCommissionCents(0, 500), 0);
});

test("calculates Sao Paulo period and previous period", () => {
  assert.equal(periodKeyInSaoPaulo(new Date("2026-01-01T02:30:00Z")), "2025-12");
  assert.equal(previousPeriodKey("2026-01"), "2025-12");
  assert.equal(previousPeriodKey("2026-09"), "2026-08");
});

test("rejects invalid financial inputs", () => {
  assert.throws(() => rateBpsForPreviousMonthVolume(-1));
  assert.throws(() => calculateCommissionCents(1.5, 500));
  assert.throws(() => calculateCommissionCents(100, 10_001));
});
