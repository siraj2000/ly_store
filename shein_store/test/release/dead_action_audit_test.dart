import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Iterable<File> dartFilesUnderLib() sync* {
    final libDirectory = Directory('lib');
    for (final entity in libDirectory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        yield entity;
      }
    }
  }

  test('no empty user-facing tap or press callbacks remain in lib', () {
    final offenders = <String>[];
    final emptyCallbackPattern = RegExp(r'(onTap|onPressed):\s*\(\)\s*\{\s*\}');

    for (final file in dartFilesUnderLib()) {
      final source = file.readAsStringSync();
      if (emptyCallbackPattern.hasMatch(source)) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test('no core Placeholder widgets remain in lib', () {
    final offenders = <String>[];
    final placeholderWidgetPattern = RegExp(r'\bPlaceholder\s*\(');

    for (final file in dartFilesUnderLib()) {
      final source = file.readAsStringSync();
      if (placeholderWidgetPattern.hasMatch(source)) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });
}
