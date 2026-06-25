import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylehub_store/models/localized_text_model.dart';
import 'package:stylehub_store/models/store_model.dart';

void main() {
  test('store model resolves localized fields', () {
    final store = StoreModel(
      id: 'store_1',
      sellerId: 'seller_1',
      nameText: const LocalizedTextModel(en: 'Northline', ar: 'نورث لاين'),
      descriptionText: const LocalizedTextModel(
        en: 'Daily essentials',
        ar: 'أساسيات يومية',
      ),
      policiesText: const LocalizedTextModel(
        en: '7-day returns',
        ar: 'إرجاع خلال 7 أيام',
      ),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    expect(store.resolvedName(const Locale('en')), 'Northline');
    expect(store.resolvedName(const Locale('ar')), 'نورث لاين');
    expect(store.resolvedPolicies(const Locale('ar')), 'إرجاع خلال 7 أيام');
  });
}
