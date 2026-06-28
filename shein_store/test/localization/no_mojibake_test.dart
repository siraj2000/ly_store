import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visible source files do not contain Arabic mojibake markers', () {
    final markers = <String>[
      String.fromCharCodes([0x00C3, 0x02DC]),
      String.fromCharCodes([0x00C3, 0x2122]),
      String.fromCharCodes([0x00C3, 0x0192]),
      String.fromCharCodes([0x00C3, 0x201A]),
      String.fromCharCode(0x00C3),
      String.fromCharCode(0x00D8),
      String.fromCharCode(0x00D9),
      String.fromCharCodes([0x00EF, 0x00BF, 0x00BD]),
      String.fromCharCode(0xFFFD),
      String.fromCharCodes([0x3F, 0x3F, 0x3F, 0x3F]),
    ];
    final roots = <String>['lib', 'test', 'web', 'android/app/src/main'];
    final failures = <String>[];

    for (final root in roots) {
      final directory = Directory(root);
      if (!directory.existsSync()) {
        continue;
      }
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || _isExcluded(entity.path)) {
          continue;
        }
        final text = entity.readAsStringSync();
        final lines = text.split('\n');
        for (var index = 0; index < lines.length; index++) {
          final line = lines[index];
          if (markers.any(line.contains)) {
            failures.add('${entity.path}:${index + 1}');
          }
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason:
          'Found mojibake/corrupted Arabic markers in visible source files.',
    );
  });
}

bool _isExcluded(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/build/') ||
      normalized.contains('/.dart_tool/') ||
      normalized.endsWith('.lock') ||
      normalized.endsWith('.png') ||
      normalized.endsWith('.jpg') ||
      normalized.endsWith('.jpeg') ||
      normalized.endsWith('.webp') ||
      normalized.endsWith('.gif');
}
