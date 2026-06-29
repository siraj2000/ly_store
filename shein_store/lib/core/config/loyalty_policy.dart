class LoyaltyPolicy {
  const LoyaltyPolicy._();

  static const String currency = 'LYD';
  static const int pointsPerCurrencyUnit = 1;
  static const int pointsPerDiscountUnit = 100;
  static const double discountUnitValue = 1;
  static const int minimumRedeemPoints = 100;
  static const double maxPointsDiscountRate = 0.20;
  static const bool bonusForMultiItemOrdersEnabled = true;
  static const int multiItemOrderBonusPoints = 10;

  static int pointsEarned({
    required double eligibleSubtotal,
    required int totalQuantity,
  }) {
    final basePoints = eligibleSubtotal.floor() * pointsPerCurrencyUnit;
    final bonus = bonusForMultiItemOrdersEnabled && totalQuantity >= 2
        ? multiItemOrderBonusPoints
        : 0;
    return basePoints + bonus;
  }

  static int maxRedeemablePoints({
    required int availablePoints,
    required double eligibleSubtotal,
  }) {
    if (availablePoints < minimumRedeemPoints || eligibleSubtotal <= 0) {
      return 0;
    }
    final usableByBalance =
        (availablePoints ~/ pointsPerDiscountUnit) * pointsPerDiscountUnit;
    final maxDiscount = eligibleSubtotal * maxPointsDiscountRate;
    final usableByOrder =
        (maxDiscount / discountUnitValue).floor() * pointsPerDiscountUnit;
    final value = usableByBalance < usableByOrder
        ? usableByBalance
        : usableByOrder;
    return value >= minimumRedeemPoints ? value : 0;
  }

  static double discountForPoints(int points) {
    if (points < minimumRedeemPoints) {
      return 0;
    }
    final redeemableUnits = points ~/ pointsPerDiscountUnit;
    return redeemableUnits * discountUnitValue;
  }
}
