import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bengali localization starts from the verified Hindi product head', () {
    final contract = File(
      'docs/localization/bengali-quality-contract.md',
    ).readAsStringSync();

    for (final marker in const [
      '64b6a7d71170fe933905165f67235a506c2d6e5b',
      '791/791',
      '`bn`, `bn-BD` ve `bn-IN`',
      'বাংলা',
      'Bangladeş ve Hindistan',
      '29 dil, 161 ülke ve 154 para birimi',
      'Universal release APK',
      'ARM64, ARMv7 ve x86_64',
    ]) {
      expect(contract, contains(marker), reason: marker);
    }
  });

  test('Bengali terminology keeps financial states distinct', () {
    final terminology = File(
      'tools/bengali_terminology.py',
    ).readAsStringSync();

    for (final marker in const [
      "'Borç': 'ঋণ'",
      "'Ödeme': 'পরিশোধ'",
      "'Gider': 'খরচ'",
      "'Gelir': 'আয়'",
      "'Kalan ödeme yükü': 'অবশিষ্ট পরিশোধের দায়'",
      "'Gecikmiş ödeme yükü': 'মেয়াদোত্তীর্ণ পরিশোধের দায়'",
      "'Yaklaşan ödeme yükü': 'আসন্ন পরিশোধের দায়'",
      "'Bildirim izni': 'বিজ্ঞপ্তির অনুমতি'",
      "'Yedekleri birleştir': 'ব্যাকআপ একত্র করুন'",
      "'ONAYLIYORUM': 'আমি নিশ্চিত করছি'",
    ]) {
      expect(terminology, contains(marker), reason: marker);
    }

    expect(terminology, contains('BENGALI_FORBIDDEN_COPY'));
    expect(terminology, contains("'বাকি পরিশোধের দায়'"));
    expect(terminology, contains('BENGALI_FORBIDDEN_INVISIBLE'));
  });
}
