import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Urdu quality contract binds the complete product scope', () {
    final contract = File(
      'docs/localization/urdu-quality-contract.md',
    ).readAsStringSync();
    for (final marker in const [
      '791/791',
      '`ur`, `ur-PK` ve `ur-IN`',
      'RTL',
      'PKR',
      'INR',
      '29 dil, 161 ülke ve 154 para birimi',
      'Universal release APK',
      'ARM64, ARMv7 ve x86_64',
    ]) {
      expect(contract, contains(marker), reason: marker);
    }
  });

  test('Urdu audit protects native copy and catalogs', () {
    final audit = File('tools/audit_urdu_native_copy.py').readAsStringSync();
    for (final marker in const [
      'len(keys) == 791',
      "'languages_v1.json': 29",
      "'countries_v1.json': 161",
      "'currencies_v1.json': 154",
      'FORBIDDEN_COPY',
      'FORBIDDEN_CONTROLS',
      "for code in ('PKR', 'INR')",
      r"\bcode\s*==\s*'{code}'",
    ]) {
      expect(audit, contains(marker), reason: marker);
    }
  });
}
