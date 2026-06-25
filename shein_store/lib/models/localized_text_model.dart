import 'package:flutter/widgets.dart';

class LocalizedTextModel {
  const LocalizedTextModel({required this.en, required this.ar});

  final String en;
  final String ar;

  String valueFor(Locale locale) {
    if (locale.languageCode == 'ar' && ar.trim().isNotEmpty) {
      return ar;
    }
    if (en.trim().isNotEmpty) {
      return en;
    }
    return ar;
  }

  factory LocalizedTextModel.fromJson(Map<String, dynamic> json) {
    return LocalizedTextModel(
      en: json['en'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};
}
