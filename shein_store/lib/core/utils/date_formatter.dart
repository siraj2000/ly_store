String formatShortDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}

String formatRelativeDelivery(DateTime date) {
  final days = date.difference(DateTime.now()).inDays;
  if (days <= 0) return 'Arriving soon';
  return 'Arrives in $days day${days == 1 ? '' : 's'}';
}
