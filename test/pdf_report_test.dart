import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/pdf_report_service.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

Future<void> _loadUnicodePdfTestFont() async {
  final fontFile = File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
  if (!await fontFile.exists()) {
    throw StateError('PDF test Unicode fontu bulunamadı: ${fontFile.path}');
  }
  final bytes = await fontFile.readAsBytes();
  final loader = FontLoader('Roboto');
  loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Future<void> _writePdfToTemporaryFile(String fileName, List<int> bytes) async {
  final outputDirectory = await Directory.systemTemp.createTemp(
    'mizan-pdf-test-',
  );
  addTearDown(() async {
    if (await outputDirectory.exists()) {
      await outputDirectory.delete(recursive: true);
    }
  });
  await File(
    '${outputDirectory.path}/$fileName',
  ).writeAsBytes(bytes, flush: true);
}

Future<List<int>> _buildPremiumPdf(MizanReport report) {
  return PdfReportService(
    premiumAccessResolver: (_) async => true,
  ).build(report);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('PDF raporu geçerli PDF üretir ve ayrıntılarda taşmaz', () async {
    await _loadUnicodePdfTestFont();
    final now = DateTime(2026, 7, 19, 12);
    final report = const MizanReportService().build(
      state: comprehensiveState(reference: now),
      filter: ReportFilter(period: ReportPeriod.allTime, anchorDate: now),
      now: now,
    );

    final bytes = await _buildPremiumPdf(report);
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    await _writePdfToTemporaryFile(
      'MIZAN-TUM-ZAMANLAR-RAPOR-ORNEGI.pdf',
      bytes,
    );
  });

  test(
    'İngilizce profil rapor ve PDF üretim yolunu tamamen İngilizce kurar',
    () async {
      await _loadUnicodePdfTestFont();
      final now = DateTime(2026, 7, 31, 12);
      final state = comprehensiveState(
        reference: now,
      ).copyWith(appLanguageTag: 'en', defaultCurrencyCode: 'USD');
      MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );

      expect(report.languageTag, 'en');
      expect(report.currencyCode, 'USD');
      expect(report.filter.period.label, 'Monthly');
      expect(report.range.label, 'July 2026');
      expect(MizanI18n.text('MİZAN Aylık Raporu'), 'MİZAN Monthly Report');
      expect(MizanI18n.text('Rapor özeti'), 'Report summary');
      expect(MizanI18n.text('Kişi kapsamı'), 'People included');
      expect(
        MizanI18n.text('Oluşturulma: Jul 31, 2026 · 12:00'),
        'Generated: Jul 31, 2026 · 12:00',
      );
      expect(MizanI18n.text('Sayfa'), 'Page');

      final bytes = await _buildPremiumPdf(report);
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      await _writePdfToTemporaryFile(
        'MIZAN-ENGLISH-MONTHLY-REPORT-SAMPLE.pdf',
        bytes,
      );
    },
  );

  test(
    'İspanyolca profil rapor ve PDF üretim yolunu tamamen İspanyolca kurar',
    () async {
      await _loadUnicodePdfTestFont();
      final now = DateTime(2026, 7, 31, 12);
      final state = comprehensiveState(
        reference: now,
      ).copyWith(appLanguageTag: 'es', defaultCurrencyCode: 'EUR');
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');

      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );

      expect(report.languageTag, 'es');
      expect(report.currencyCode, 'EUR');
      expect(report.filter.period.label, 'Mensual');
      expect(report.range.label, 'julio de 2026');
      expect(MizanI18n.text('MİZAN Aylık Raporu'), 'Informe mensual de MİZAN');
      expect(MizanI18n.text('Rapor özeti'), 'Resumen del informe');
      expect(MizanI18n.text('Kişi kapsamı'), 'Personas incluidas');
      expect(
        MizanI18n.text('Oluşturulma: 31 jul 2026 · 12:00'),
        'Generado: 31 jul 2026 · 12:00',
      );
      expect(MizanI18n.text('Sayfa'), 'Página');

      final bytes = await _buildPremiumPdf(report);
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    },
  );

  test('uzun gider ve ödeme raporu çok sayfalı ve geçerli üretilir', () async {
    await _loadUnicodePdfTestFont();
    final now = DateTime(2026, 7, 25, 12);
    final base = comprehensiveState(reference: now);
    final expanded = base.copyWith(
      expenses: [
        ...base.expenses,
        for (var index = 0; index < 140; index++)
          ExpenseItem(
            id: 'pdf-expense-$index',
            categoryId: base.expenseCategories.first.id,
            name: 'Uzun rapor gideri $index açıklama metni',
            quantity: 1.0 + (index % 3),
            unitPrice: 125.0 + index,
            spentAt: DateTime(2026, 7, 1 + (index % 25)),
            note:
                'Günlük harcama ile ödeme kayıtlarının birbirine karışmadığını doğrulayan test notu $index.',
          ),
      ],
    );
    final report = const MizanReportService().build(
      state: expanded,
      filter: ReportFilter(period: ReportPeriod.allTime, anchorDate: now),
      now: now,
    );

    final bytes = await _buildPremiumPdf(report);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(10000));
    final content = String.fromCharCodes(bytes);
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(content).length,
      greaterThan(1),
    );
  });
}
