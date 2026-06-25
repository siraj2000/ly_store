import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(
  BuildContext context,
  double amount, {
  String currencyCode = 'USD',
}) {
  return NumberFormat.currency(
    locale: Localizations.localeOf(context).toLanguageTag(),
    name: currencyCode,
  ).format(amount);
}

String formatShortDate(BuildContext context, DateTime date) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}
