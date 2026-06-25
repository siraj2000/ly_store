String formatCurrency(double value, {String currency = '\$'}) {
  return '$currency${value.toStringAsFixed(2)}';
}
