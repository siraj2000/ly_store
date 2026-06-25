import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic ARB files contain identical non-empty keys', () {
    final en = _readArb('lib/l10n/app_en.arb');
    final ar = _readArb('lib/l10n/app_ar.arb');

    final enKeys = en.keys.where((key) => !key.startsWith('@')).toSet();
    final arKeys = ar.keys.where((key) => !key.startsWith('@')).toSet();

    expect(arKeys, equals(enKeys));

    for (final key in enKeys) {
      expect((en[key] as String).trim().isNotEmpty, isTrue, reason: key);
      expect((ar[key] as String).trim().isNotEmpty, isTrue, reason: key);

      final enMeta = en['@$key'];
      final arMeta = ar['@$key'];
      if (enMeta is Map<String, dynamic> || arMeta is Map<String, dynamic>) {
        final enPlaceholders =
            (enMeta?['placeholders'] as Map<String, dynamic>? ?? const {}).keys
                .toSet();
        final arPlaceholders =
            (arMeta?['placeholders'] as Map<String, dynamic>? ?? const {}).keys
                .toSet();
        expect(
          arPlaceholders,
          equals(enPlaceholders),
          reason: 'Placeholder mismatch for $key',
        );
      }
    }
  });
}

Map<String, dynamic> _readArb(String path) {
  final file = File(path);
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json;
}
