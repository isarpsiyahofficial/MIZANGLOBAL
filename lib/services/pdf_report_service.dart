import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/formatters.dart';
import '../models/mizan_models.dart';
import 'report_service.dart';

class PdfReportService {
  const PdfReportService();

  Future<Uint8List> build(MizanReport report) async {
    final painter = _ReportPagePainter(report);
    final pageImages = await painter.render();
    final document = pw.Document(
      title: 'MİZAN ${report.filter.period.label} Raporu',
      author: 'LEFFERION PRIME - MİZAN',
      creator: 'LEFFERION PRIME - MİZAN',
    );
    for (final imageBytes in pageImages) {
      final image = pw.MemoryImage(imageBytes);
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
    }
    return document.save();
  }
}

class _ReportPagePainter {
  _ReportPagePainter(this.report);

  static const int pageWidth = 1240;
  static const int pageHeight = 1754;
  static const double margin = 72;
  static const double contentWidth = pageWidth - margin * 2;
  static const double bottomLimit = pageHeight - 92;

  final MizanReport report;
  final List<Uint8List> _pages = [];
  late ui.PictureRecorder _recorder;
  late Canvas _canvas;
  double _y = margin;
  int _pageNumber = 0;

  Color _recordColor(RecordType type) => switch (type) {
    RecordType.debt => const Color(0xFF2459B3),
    RecordType.personalDebt => const Color(0xFF7C3AED),
    RecordType.bill => const Color(0xFF0F766E),
    RecordType.subscription => const Color(0xFFB45309),
    RecordType.rent => const Color(0xFFBE123C),
  };

  Color _stableTone(String seed) {
    const tones = <Color>[
      Color(0xFF2459B3),
      Color(0xFF0F766E),
      Color(0xFF7C3AED),
      Color(0xFFB45309),
      Color(0xFFBE123C),
      Color(0xFF0369A1),
      Color(0xFF4D7C0F),
      Color(0xFF9F1239),
    ];
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return tones[hash % tones.length];
  }

  String _bankSeed(String value, {bool includesPerson = false}) {
    final parts = value
        .split('·')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return value;
    if (includesPerson && parts.length > 1) return parts[1];
    return parts.first;
  }

  Color _paymentAccent(ReportPaymentDetail detail) =>
      detail.type == RecordType.debt
      ? _stableTone(_bankSeed(detail.recordSubtitle))
      : _recordColor(detail.type);

  Color _recordAccent(RecordReference record) => record.type == RecordType.debt
      ? _stableTone(_bankSeed(record.subtitle, includesPerson: true))
      : _recordColor(record.type);

  Future<List<Uint8List>> render() async {
    _startPage();
    await _heading();
    await _summary();
    await _incomeSection();
    await _paymentSections();
    await _expenseSections();
    await _remainingSections();
    await _personSections();
    await _finishPage();
    return _pages;
  }

  void _startPage() {
    _pageNumber += 1;
    _recorder = ui.PictureRecorder();
    _canvas = Canvas(_recorder);
    _canvas.drawRect(
      Rect.fromLTWH(0, 0, pageWidth.toDouble(), pageHeight.toDouble()),
      Paint()..color = Colors.white,
    );
    _y = margin;
  }

  Future<void> _finishPage() async {
    _drawFooter();
    final picture = _recorder.endRecording();
    final image = await picture.toImage(pageWidth, pageHeight);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) {
      throw StateError('PDF rapor sayfası görüntüye dönüştürülemedi.');
    }
    _pages.add(data.buffer.asUint8List());
  }

  void _drawFooter() {
    _canvas.drawLine(
      const Offset(margin, pageHeight - 70),
      const Offset(pageWidth - margin, pageHeight - 70),
      Paint()
        ..color = const Color(0xFFDDE3EC)
        ..strokeWidth = 1,
    );
    _paintText(
      'LEFFERION PRIME - MİZAN · Sayfa $_pageNumber',
      x: margin,
      y: pageHeight - 58,
      maxWidth: contentWidth,
      fontSize: 20,
      color: const Color(0xFF667085),
      align: TextAlign.center,
    );
  }

  Future<void> _newPage({String? continuedTitle}) async {
    await _finishPage();
    _startPage();
    if (continuedTitle != null) {
      await _text(
        '$continuedTitle · devam',
        fontSize: 30,
        weight: FontWeight.w800,
        color: const Color(0xFF111827),
        bottomSpace: 14,
      );
    }
  }

  Future<void> _ensure(double required, {String? continuedTitle}) async {
    if (_y + required <= bottomLimit) return;
    await _newPage(continuedTitle: continuedTitle);
  }

  TextPainter _textPainter(
    String text, {
    required double fontSize,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF111827),
    TextAlign align = TextAlign.left,
    double? maxWidth,
    double height = 1.25,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: height,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: null,
    );
    painter.layout(maxWidth: maxWidth ?? contentWidth);
    return painter;
  }

  double _paintText(
    String text, {
    required double x,
    required double y,
    required double maxWidth,
    required double fontSize,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF111827),
    TextAlign align = TextAlign.left,
  }) {
    final painter = _textPainter(
      text,
      fontSize: fontSize,
      weight: weight,
      color: color,
      align: align,
      maxWidth: maxWidth,
    );
    painter.paint(_canvas, Offset(x, y));
    return painter.height;
  }

  Future<void> _text(
    String text, {
    double fontSize = 25,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF111827),
    double bottomSpace = 8,
    String? continuedTitle,
  }) async {
    final painter = _textPainter(
      text,
      fontSize: fontSize,
      weight: weight,
      color: color,
    );
    await _ensure(painter.height + bottomSpace, continuedTitle: continuedTitle);
    painter.paint(_canvas, Offset(margin, _y));
    _y += painter.height + bottomSpace;
  }

  Future<void> _heading() async {
    await _text(
      'LEFFERION PRIME - MİZAN',
      fontSize: 24,
      weight: FontWeight.w800,
      color: const Color(0xFF2459B3),
      bottomSpace: 8,
    );
    await _text(
      '${report.filter.period.label} finans raporu',
      fontSize: 42,
      weight: FontWeight.w900,
      bottomSpace: 10,
    );
    await _text(
      'Dönem: ${report.range.label}',
      fontSize: 24,
      weight: FontWeight.w700,
      bottomSpace: 4,
    );
    await _text(
      report.selectedPersonNames.isEmpty
          ? 'Kişi kapsamı: Kayıtlı kişi yok'
          : 'Kişi kapsamı: ${report.selectedPersonNames.join(', ')}',
      fontSize: 22,
      color: const Color(0xFF475467),
      bottomSpace: 4,
    );
    await _text(
      'Oluşturulma: ${shortDate(report.generatedAt)} · ${timeLabel(report.generatedAt.hour, report.generatedAt.minute)}',
      fontSize: 20,
      color: const Color(0xFF667085),
      bottomSpace: 18,
    );
    _canvas.drawLine(
      Offset(margin, _y),
      Offset(pageWidth - margin, _y),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2,
    );
    _y += 20;
  }

  Future<void> _sectionTitle(String title, String subtitle) async {
    await _ensure(90, continuedTitle: title);
    await _text(
      title,
      fontSize: 30,
      weight: FontWeight.w900,
      color: const Color(0xFF172033),
      bottomSpace: 4,
      continuedTitle: title,
    );
    await _text(
      subtitle,
      fontSize: 19,
      color: const Color(0xFF667085),
      bottomSpace: 12,
      continuedTitle: title,
    );
  }

  Future<void> _keyValue(
    String label,
    String value, {
    bool emphasized = false,
    String? subtitle,
    String? continuedTitle,
    Color? accentColor,
  }) async {
    final inset = accentColor == null ? 0.0 : 24.0;
    final usableWidth = contentWidth - inset;
    final labelWidth = usableWidth * .67;
    final valueWidth = usableWidth * .29;
    final labelPainter = _textPainter(
      label,
      fontSize: emphasized ? 25 : 22,
      weight: emphasized ? FontWeight.w800 : FontWeight.w600,
      maxWidth: labelWidth,
    );
    final valuePainter = _textPainter(
      value,
      fontSize: emphasized ? 27 : 22,
      weight: FontWeight.w900,
      align: TextAlign.right,
      maxWidth: valueWidth,
    );
    final subtitlePainter = subtitle == null
        ? null
        : _textPainter(
            subtitle,
            fontSize: 18,
            color: const Color(0xFF667085),
            maxWidth: usableWidth * .72,
          );
    final topHeight = labelPainter.height > valuePainter.height
        ? labelPainter.height
        : valuePainter.height;
    final contentHeight =
        topHeight + (subtitlePainter == null ? 0 : subtitlePainter.height + 8);
    final cardPadding = accentColor == null ? 0.0 : 14.0;
    final blockHeight = contentHeight + cardPadding * 2;
    await _ensure(blockHeight + 18, continuedTitle: continuedTitle);

    if (accentColor != null) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, _y, contentWidth, blockHeight),
        const Radius.circular(12),
      );
      _canvas.drawRRect(
        rect,
        Paint()..color = accentColor.withValues(alpha: .055),
      );
      _canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = accentColor.withValues(alpha: .18),
      );
      _canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(margin, _y, 7, blockHeight),
          const Radius.circular(7),
        ),
        Paint()..color = accentColor,
      );
    }

    final textX = margin + inset;
    final textY = _y + cardPadding;
    labelPainter.paint(_canvas, Offset(textX, textY));
    valuePainter.paint(
      _canvas,
      Offset(pageWidth - margin - valueWidth - cardPadding, textY),
    );
    if (subtitlePainter != null) {
      subtitlePainter.paint(_canvas, Offset(textX, textY + topHeight + 5));
    }
    _y += blockHeight + 9;
    if (accentColor == null) {
      _canvas.drawLine(
        Offset(margin, _y),
        Offset(pageWidth - margin, _y),
        Paint()
          ..color = const Color(0xFFE7EAF0)
          ..strokeWidth = 1,
      );
      _y += 10;
    }
  }

  Future<void> _dayHeader(
    DateTime day, {
    required int normalCount,
    required int paymentCount,
    required double total,
    String? continuedTitle,
  }) async {
    await _ensure(108, continuedTitle: continuedTitle);
    _y += 8;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, _y, contentWidth, 86),
      const Radius.circular(16),
    );
    _canvas.drawRRect(rect, Paint()..color = const Color(0xFFE8F0FF));
    _canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF2459B3),
    );
    _canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, _y, 9, 86),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF2459B3),
    );
    _paintText(
      'GÜN BAŞLIĞI',
      x: margin + 24,
      y: _y + 9,
      maxWidth: contentWidth * .42,
      fontSize: 13,
      weight: FontWeight.w900,
      color: const Color(0xFF2459B3),
    );
    _paintText(
      '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}',
      x: margin + 24,
      y: _y + 27,
      maxWidth: contentWidth * .44,
      fontSize: 25,
      weight: FontWeight.w900,
      color: const Color(0xFF163E7A),
    );
    _paintText(
      '$normalCount günlük harcama · $paymentCount ödeme',
      x: margin + 24,
      y: _y + 59,
      maxWidth: contentWidth * .62,
      fontSize: 16,
      weight: FontWeight.w700,
      color: const Color(0xFF52627A),
    );
    _paintText(
      money(total),
      x: pageWidth - margin - contentWidth * .31 - 18,
      y: _y + 31,
      maxWidth: contentWidth * .31,
      fontSize: 24,
      weight: FontWeight.w900,
      color: const Color(0xFF163E7A),
      align: TextAlign.right,
    );
    _y += 102;
  }

  Future<void> _subsectionLabel(
    String label,
    Color color, {
    String? continuedTitle,
  }) async {
    await _ensure(42, continuedTitle: continuedTitle);
    _canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, _y, contentWidth, 34),
        const Radius.circular(9),
      ),
      Paint()..color = color.withValues(alpha: .08),
    );
    _paintText(
      label,
      x: margin + 14,
      y: _y + 6,
      maxWidth: contentWidth - 28,
      fontSize: 18,
      weight: FontWeight.w800,
      color: color,
    );
    _y += 42;
  }

  Future<void> _notice(String text, {String? continuedTitle}) async {
    final painter = _textPainter(
      text,
      fontSize: 18,
      weight: FontWeight.w600,
      color: const Color(0xFF7A4B00),
      maxWidth: contentWidth - 40,
    );
    final height = painter.height + 28;
    await _ensure(height + 12, continuedTitle: continuedTitle);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, _y, contentWidth, height),
      const Radius.circular(14),
    );
    _canvas.drawRRect(rect, Paint()..color = const Color(0xFFFFF6DF));
    _canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFE6B84A),
    );
    painter.paint(_canvas, Offset(margin + 20, _y + 14));
    _y += height + 12;
  }

  Future<void> _summary() async {
    await _sectionTitle(
      'Rapor özeti',
      'Ödeme kayıtları ve Giderler bölümü birbirine karıştırılmadan hesaplanır.',
    );
    await _keyValue(
      'Gelir',
      report.incomeSpecified
          ? money(report.totalIncome)
          : 'Gelir bilgisi belirtilmemiş',
      emphasized: true,
      continuedTitle: 'Rapor özeti',
    );
    await _keyValue(
      'Ödemelere yapılan gider',
      money(report.totalPayments),
      emphasized: true,
      continuedTitle: 'Rapor özeti',
    );
    await _keyValue(
      'Normal giderler',
      money(report.totalExpenses),
      emphasized: true,
      continuedTitle: 'Rapor özeti',
    );
    await _keyValue(
      'Toplam gider',
      money(report.realizedGrandTotal),
      emphasized: true,
      continuedTitle: 'Rapor özeti',
    );
    if (report.incomeSpecified) {
      await _keyValue(
        'Ödemeler sonrası kalan gelir',
        money(report.afterPayments),
        continuedTitle: 'Rapor özeti',
      );
      await _keyValue(
        'Toplam gider sonrası net',
        money(report.finalNet),
        emphasized: true,
        continuedTitle: 'Rapor özeti',
      );
    }
    await _keyValue(
      'Seçili dönemde kalan ödeme yükü',
      money(report.remainingLoad),
      continuedTitle: 'Rapor özeti',
    );
    await _keyValue(
      'Gecikmiş ödeme yükü',
      money(report.overdueLoad),
      continuedTitle: 'Rapor özeti',
    );
    await _keyValue(
      'Yaklaşan ödeme yükü',
      money(report.upcomingLoad),
      continuedTitle: 'Rapor özeti',
    );
    _y += 14;
  }

  Future<void> _incomeSection() async {
    await _sectionTitle(
      'Gelir ayrıntıları',
      'Gelir türleri seçili döneme düşen tekrar sayısına göre hesaplanır.',
    );
    if (!report.incomeSpecified) {
      await _text(
        'Gelir bilgisi belirtilmemiş.',
        color: const Color(0xFF667085),
        bottomSpace: 14,
      );
      return;
    }
    if (report.incomeDetails.isEmpty) {
      await _text(
        'Seçili dönemde gelir oluşmuyor.',
        color: const Color(0xFF667085),
        bottomSpace: 14,
      );
      return;
    }
    for (final detail in report.incomeDetails) {
      await _keyValue(
        '${detail.income.title} · ${detail.income.frequency.label}',
        money(detail.amount),
        continuedTitle: 'Gelir ayrıntıları',
      );
    }
    _y += 14;
  }

  Future<void> _paymentSections() async {
    await _sectionTitle(
      'Gerçekleşen harcamaların dağılımı',
      'Seçili dönem ve kişi kapsamındaki ödeme geçmişi kayıt türüne göre ayrılır.',
    );
    for (final entry in report.realizedDistribution) {
      await _keyValue(
        entry.label,
        money(entry.amount),
        continuedTitle: 'Gerçekleşen harcamaların dağılımı',
        accentColor: entry.type == null
            ? const Color(0xFF0F766E)
            : _recordColor(entry.type!),
      );
    }

    await _sectionTitle(
      'Gerçekleşen ödeme ayrıntıları',
      'Her ödeme yalnız bağlı olduğu kişi ve kayıt altında gösterilir.',
    );
    if (report.paymentDetails.isEmpty) {
      await _text(
        'Seçili kapsamda gerçekleşen ödeme bulunmuyor.',
        fontSize: 21,
        color: const Color(0xFF667085),
      );
    } else {
      for (final detail in report.paymentDetails) {
        final method = detail.payment.method.trim().isEmpty
            ? ''
            : ' · ${detail.payment.method.trim()}';
        final note = detail.payment.note.trim().isEmpty
            ? null
            : detail.payment.note.trim();
        await _keyValue(
          '${shortDate(detail.payment.paidAt)} · ${detail.personName}\n${_typeLabel(detail.type)} · ${detail.recordTitle}',
          money(detail.payment.amount),
          subtitle:
              '${detail.payment.entryType.label}$method · ${detail.recordSubtitle}${note == null ? '' : '\nNot: $note'}',
          continuedTitle: 'Gerçekleşen ödeme ayrıntıları',
        );
      }
    }
    _y += 14;
    await _notice(
      'Gecikmiş kayıtlarda gösterilen taksit ve ana para tutarlarına işleyebilecek faizler, gecikme bedelleri ve diğer olası durum etkenleri dahil değildir.',
      continuedTitle: 'Ödeme kayıtları',
    );
  }

  Future<void> _expenseSections() async {
    await _sectionTitle(
      'Gider dağılımı',
      'Normal giderler ve ödeme kayıtları aynı rapor toplamına dahil edilir; kaynakları birbirine karıştırılmadan ayrı renklerle gösterilir.',
    );

    if (report.combinedOutflowDistribution.isEmpty) {
      await _text(
        'Seçili dönemde gider veya ödeme kaydı bulunmuyor.',
        fontSize: 21,
        color: const Color(0xFF667085),
      );
    } else {
      for (final entry in report.combinedOutflowDistribution) {
        await _keyValue(
          entry.label,
          money(entry.amount),
          continuedTitle: 'Gider dağılımı',
          accentColor: entry.type != null
              ? _recordColor(entry.type!)
              : _stableTone('expense-${entry.expenseCategory ?? entry.label}'),
        );
      }
    }

    await _sectionTitle(
      'Gider ayrıntıları',
      'Günler başlık olarak gösterilir; her günün normal harcamaları ve ödemeleri kendi bölümünde, satır taşması olmadan listelenir.',
    );

    final expensesByDay = <int, List<ReportExpenseDetail>>{};
    final paymentsByDay = <int, List<ReportPaymentDetail>>{};
    final days = <int, DateTime>{};
    int dayKey(DateTime value) =>
        value.year * 10000 + value.month * 100 + value.day;

    for (final detail in report.expenseDetails) {
      final day = DateTime(
        detail.expense.spentAt.year,
        detail.expense.spentAt.month,
        detail.expense.spentAt.day,
      );
      final key = dayKey(day);
      days[key] = day;
      expensesByDay.putIfAbsent(key, () => <ReportExpenseDetail>[]).add(detail);
    }
    for (final detail in report.paymentDetails) {
      final day = DateTime(
        detail.payment.paidAt.year,
        detail.payment.paidAt.month,
        detail.payment.paidAt.day,
      );
      final key = dayKey(day);
      days[key] = day;
      paymentsByDay.putIfAbsent(key, () => <ReportPaymentDetail>[]).add(detail);
    }

    final sortedDays = days.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    if (sortedDays.isEmpty) {
      await _text(
        'Seçili dönemde gider ayrıntısı bulunmuyor.',
        fontSize: 21,
        color: const Color(0xFF667085),
      );
      _y += 14;
      return;
    }

    for (final dayEntry in sortedDays) {
      final expenses = expensesByDay[dayEntry.key] ?? const [];
      final payments = paymentsByDay[dayEntry.key] ?? const [];
      final total =
          expenses.fold<double>(
            0,
            (sum, item) => sum + item.expense.totalAmount,
          ) +
          payments.fold<double>(0, (sum, item) => sum + item.payment.amount);
      await _dayHeader(
        dayEntry.value,
        normalCount: expenses.length,
        paymentCount: payments.length,
        total: total,
        continuedTitle: 'Gider ayrıntıları',
      );

      if (expenses.isNotEmpty) {
        await _subsectionLabel(
          'Günlük harcamalar',
          const Color(0xFF0F766E),
          continuedTitle: 'Gider ayrıntıları',
        );
        for (final detail in expenses) {
          final note = detail.expense.note.trim().isEmpty
              ? null
              : detail.expense.note.trim();
          await _keyValue(
            '${detail.categoryName} · ${detail.expense.name}',
            money(detail.expense.totalAmount),
            subtitle:
                '${decimalText(detail.expense.quantity)} × ${money(detail.expense.unitPrice)}${note == null ? '' : '\nNot: $note'}',
            continuedTitle: 'Gider ayrıntıları',
            accentColor: _stableTone('expense-${detail.categoryName}'),
          );
        }
      }

      if (payments.isNotEmpty) {
        await _subsectionLabel(
          'Ödemeler',
          const Color(0xFF2459B3),
          continuedTitle: 'Gider ayrıntıları',
        );
        for (final detail in payments) {
          final method = detail.payment.method.trim().isEmpty
              ? ''
              : ' · ${detail.payment.method.trim()}';
          final note = detail.payment.note.trim().isEmpty
              ? null
              : detail.payment.note.trim();
          await _keyValue(
            '${detail.personName} · ${_typeLabel(detail.type)}\n${detail.recordTitle}',
            money(detail.payment.amount),
            subtitle:
                '${detail.payment.entryType.label}$method · ${detail.recordSubtitle}${note == null ? '' : '\nNot: $note'}',
            continuedTitle: 'Gider ayrıntıları',
            accentColor: _paymentAccent(detail),
          );
        }
      }
      _y += 10;
    }
    _y += 14;
  }

  Future<void> _remainingSections() async {
    await _sectionTitle(
      'Kalan ödeme yükünün dağılımı',
      'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme/taksit tutarları gösterilir.',
    );
    for (final type in RecordType.values) {
      await _keyValue(
        _typeLabel(type),
        money(report.remainingTotalsByType[type] ?? 0),
        continuedTitle: 'Kalan ödeme yükünün dağılımı',
        accentColor: _recordColor(type),
      );
    }
    await _sectionTitle(
      'Kalan ödeme ayrıntıları',
      'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur. $mizanCalculationWarning',
    );
    if (report.remainingDetails.isEmpty) {
      await _text(
        'Seçili dönemde açık ödeme yükü bulunmuyor.',
        fontSize: 21,
        color: const Color(0xFF667085),
      );
    } else {
      for (final record in report.remainingDetails) {
        await _keyValue(
          '${shortDate(record.dueDate)} · ${record.title}',
          money(record.amount),
          subtitle:
              '${_typeLabel(record.type)} · ${record.subtitle} · ${recordTimingLabel(record, report.balanceReference)}',
          continuedTitle: 'Kalan ödeme ayrıntıları',
          accentColor: _recordAccent(record),
        );
      }
    }
    _y += 14;
  }

  Future<void> _personSections() async {
    await _sectionTitle(
      'Kişi bazında güncel kalan borç',
      'Seçili kişilerin bütün açık kayıtları, dönem filtresinden bağımsız güncel bakiye olarak sunulur.',
    );
    if (report.personDebtDetails.isEmpty) {
      await _text(
        'Kişi kaydı bulunmuyor.',
        fontSize: 21,
        color: const Color(0xFF667085),
      );
      return;
    }
    for (final person in report.personDebtDetails) {
      await _ensure(110, continuedTitle: 'Kişi bazında güncel kalan borç');
      await _text(
        person.personName,
        fontSize: 27,
        weight: FontWeight.w900,
        color: const Color(0xFF2459B3),
        bottomSpace: 5,
        continuedTitle: 'Kişi bazında güncel kalan borç',
      );
      await _keyValue(
        'Toplam güncel kalan borç',
        money(person.totalRemaining),
        emphasized: true,
        continuedTitle: person.personName,
      );
      for (final type in RecordType.values) {
        final value = person.byType[type] ?? 0;
        if (value <= 0) continue;
        await _keyValue(
          _typeLabel(type),
          money(value),
          continuedTitle: person.personName,
          accentColor: _recordColor(type),
        );
      }
      for (final record in person.records) {
        await _keyValue(
          '${record.title} · ${shortDate(record.dueDate)}',
          money(record.amount),
          subtitle: '${_typeLabel(record.type)} · ${record.subtitle}',
          continuedTitle: person.personName,
          accentColor: _recordAccent(record),
        );
      }
      _y += 12;
    }
  }
}

String _typeLabel(RecordType type) => switch (type) {
  RecordType.debt => 'Banka borçları',
  RecordType.personalDebt => 'Kişisel ve kurumsal borçlar',
  RecordType.bill => 'Faturalar',
  RecordType.subscription => 'Abonelikler',
  RecordType.rent => 'Kira ve taksitler',
};
