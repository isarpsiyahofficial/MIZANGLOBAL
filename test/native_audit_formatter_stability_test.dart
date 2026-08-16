import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native-copy audit map parsers accept Dart formatter line wrapping', () {
    const auditFiles = <String>[
      'tools/audit_chinese_native_copy.py',
      'tools/audit_filipino_native_copy.py',
      'tools/audit_indonesian_native_copy.py',
      'tools/audit_japanese_native_copy.py',
      'tools/audit_korean_native_copy.py',
      'tools/audit_urdu_native_copy.py',
      'tools/audit_vietnamese_native_copy.py',
    ];

    for (final path in auditFiles) {
      final source = File(path).readAsStringSync();
      expect(
        source,
        isNot(contains(r"^\s*'")),
        reason:
            '$path must not require map keys and values on one source line.',
      );
      expect(
        source,
        contains(r"\s*:\s*"),
        reason: '$path must accept whitespace/newlines around the map colon.',
      );
    }
  });
}
