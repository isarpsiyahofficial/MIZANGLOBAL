import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import '../core/localized_material.dart';
import 'package:printing/printing.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/mizan_models.dart';
import '../services/expense_browser_service.dart';
import '../services/pdf_report_service.dart';
import '../services/report_service.dart';
import '../widgets/mizan_cards.dart';
import 'people_screen.dart';

class _ReportNavigationData {
  const _ReportNavigationData({
    required this.monthStamp,
    required this.months,
    required this.years,
  });

  final int monthStamp;
  final List<DateTime> months;
  final List<int> years;
}

final Expando<_ReportNavigationData> _reportNavigationCache =
    Expando<_ReportNavigationData>('mizan-report-navigation');

enum _ReportMetricDetailKind {
  normalExpenses,
  payments,
  allOutflows,
  remaining,
  overdue,
  upcoming,
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({required this.controller, super.key});

  final MizanController controller;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod period = ReportPeriod.monthly;
  DateTime anchorDate = DateTime.now();
  Set<String> selectedPersonIds = {};
  PaymentStatus? status;
  bool generatingPdf = false;
  MizanState? _cachedState;
  String? _cachedFilterKey;
  MizanReport? _cachedReport;

  MizanReport _reportFor(MizanState state, ReportFilter filter) {
    final peopleKey = filter.selectedPersonIds.toList()..sort();
    final current = DateTime.now();
    final dayStamp = current.year * 10000 + current.month * 100 + current.day;
    final key =
        '$dayStamp|${filter.period.name}|${filter.anchorDate.toIso8601String()}|${peopleKey.join(',')}|${filter.status?.name ?? 'all'}';
    if (identical(_cachedState, state) &&
        _cachedFilterKey == key &&
        _cachedReport != null) {
      return _cachedReport!;
    }
    final report = const MizanReportService().build(
      state: state,
      filter: filter,
    );
    _cachedState = state;
    _cachedFilterKey = key;
    _cachedReport = report;
    return report;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final validPersonIds = selectedPersonIds
        .where((id) => state.people.any((person) => person.id == id))
        .toSet();
    final now = DateTime.now();
    final monthStamp = now.year * 100 + now.month;
    var navigation = _reportNavigationCache[state];
    if (navigation == null || navigation.monthStamp != monthStamp) {
      final months = <DateTime>{
        DateTime(now.year, now.month),
        ...state.availableReportMonths(now),
      }.toList(growable: false)
        ..sort((a, b) => b.compareTo(a));
      final years = <int>{
        now.year,
        ...months.map((item) => item.year),
      }.toList(growable: false)
        ..sort((a, b) => b.compareTo(a));
      navigation = _ReportNavigationData(
        monthStamp: monthStamp,
        months: months,
        years: years,
      );
      _reportNavigationCache[state] = navigation;
    }
    final resolvedNavigation = navigation;
    final availableMonths = resolvedNavigation.months;
    final availableYears = resolvedNavigation.years;
    final effectiveAnchor = anchorDate;
    final filter = ReportFilter(
      period: period,
      anchorDate: effectiveAnchor,
      selectedPersonIds: validPersonIds,
      status: status,
    );
    final report = _reportFor(state, filter);
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;

    return ListView(
      key: const PageStorageKey('reports'),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 110),
      children: [
        const PageHeader(
          title: 'Raporlar',
          subtitle:
              'Ödemeleri, giderleri ve kalan yükü aynı filtreyle doğru ve ayrıntılı gösterir.',
        ),
        const SizedBox(height: 18),
        _ReportFilters(
          state: state,
          period: period,
          anchorDate: effectiveAnchor,
          availableMonths: availableMonths,
          availableYears: availableYears,
          selectedPersonIds: validPersonIds,
          status: status,
          onPeriodChanged: (value) => setState(() {
            period = value;
            final current = DateTime.now();
            if (value == ReportPeriod.monthly) {
              anchorDate = DateTime(current.year, current.month);
            } else if (value == ReportPeriod.yearly) {
              anchorDate = DateTime(current.year);
            } else if (value == ReportPeriod.daily ||
                value == ReportPeriod.weekly) {
              anchorDate = dateOnly(current);
            }
          }),
          onAnchorChanged: (value) => setState(() => anchorDate = value),
          onPeoplePressed: () => _selectPeople(state),
          onStatusChanged: (value) => setState(() => status = value),
        ),
        const SizedBox(height: 12),
        _CurrentExpenseOverview(
          report: report,
          onNormalExpenses: () => _showMetricDetails(
            report,
            _ReportMetricDetailKind.normalExpenses,
          ),
          onPayments: () =>
              _showMetricDetails(report, _ReportMetricDetailKind.payments),
          onAllOutflows: () =>
              _showMetricDetails(report, _ReportMetricDetailKind.allOutflows),
        ),
        const SizedBox(height: 12),
        _IncomeReportCard(report: report),
        const SizedBox(height: 12),
        _PdfActions(
          generating: generatingPdf,
          onSave: () => _savePdf(report),
          onShare: () => _sharePdf(report),
        ),
        const SizedBox(height: 16),
        _RealizedTotalCard(report: report),
        const SizedBox(height: 16),
        AdaptiveGrid(
          minTileWidth: 175,
          children: [
            MetricCard(
              label: 'Gelir',
              value: report.incomeSpecified
                  ? moneyBuckets(report.totalIncomeByCurrency)
                  : 'Belirtilmemiş',
              color: MizanTheme.green,
              icon: Icons.trending_up_outlined,
            ),
            MetricCard(
              label: 'Ödemelere yapılan gider',
              value: moneyBuckets(report.totalPaymentsByCurrency),
              color: MizanTheme.blue,
              icon: Icons.payments_outlined,
              onTap: () =>
                  _showMetricDetails(report, _ReportMetricDetailKind.payments),
            ),
            MetricCard(
              label: 'Normal giderler',
              value: moneyBuckets(report.totalExpensesByCurrency),
              color: MizanTheme.green,
              icon: Icons.shopping_bag_outlined,
              onTap: () => _showMetricDetails(
                report,
                _ReportMetricDetailKind.normalExpenses,
              ),
            ),
            MetricCard(
              label: 'Kalan ödeme yükü',
              value: moneyBuckets(report.remainingLoadByCurrency),
              icon: Icons.account_balance_wallet_outlined,
              onTap: () =>
                  _showMetricDetails(report, _ReportMetricDetailKind.remaining),
            ),
            MetricCard(
              label: 'Gecikmiş',
              value: moneyBuckets(report.overdueLoadByCurrency),
              color: MizanTheme.red,
              icon: Icons.warning_amber_rounded,
              onTap: () =>
                  _showMetricDetails(report, _ReportMetricDetailKind.overdue),
            ),
            MetricCard(
              label: 'Önümüzdeki 7 gün',
              value: moneyBuckets(report.upcomingLoadByCurrency),
              color: MizanTheme.orange,
              icon: Icons.upcoming_outlined,
              onTap: () =>
                  _showMetricDetails(report, _ReportMetricDetailKind.upcoming),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DetailedListSection(
          title: 'Gelir ayrıntıları',
          subtitle:
              'Serbest girilen gelir türleri ve seçili döneme düşen tutarları gösterilir.',
          emptyMessage: report.incomeSpecified
              ? 'Seçili dönemde gelir oluşmuyor.'
              : 'Gelir bilgisi belirtilmemiş.',
          childrenBuilder: (_) => [
            for (final detail in report.incomeDetails)
              MizanListCard(
                title: MizanI18n.user(detail.income.title),
                subtitle:
                    '${detail.income.frequency.label} · Başlangıç ${shortDate(detail.income.startDate)}${detail.income.note.isEmpty ? '' : '\n${MizanI18n.user(detail.income.note)}'}',
                icon: Icons.account_balance_outlined,
                leadingColor: MizanTheme.green,
                trailing: Text(
                  money(
                    detail.amount,
                    currencyCode: detail.income.currencyCode,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ReportSection(
          title: 'Gerçekleşen harcamaların dağılımı',
          subtitle:
              'Günlük harcamalar ve ödeme geçmişi ayrı kaynaklar olarak, en yüksek tutardan en düşüğe sıralanır.',
          showZeroEntries: true,
          entries: [
            for (final entry in report.realizedDistributionByCurrency)
              _ReportEntry(
                label: entry.label,
                amount: entry.amount,
                currencyCode: entry.currencyCode,
                icon: entry.type == null
                    ? Icons.shopping_bag_outlined
                    : recordIcon(entry.type!),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _DetailedListSection(
          title: 'Gerçekleşen ödeme ayrıntıları',
          subtitle:
              'Kişi, kayıt, ödeme türü, tarih ve tutar birbirine karışmadan listelenir.',
          emptyMessage: 'Seçili kapsamda gerçekleşen ödeme bulunmuyor.',
          childrenBuilder: (_) => [
            for (final detail in report.paymentDetails)
              MizanListCard(
                title:
                    '${MizanI18n.user(detail.personName)} · ${reportTypeLabel(detail.type)} · ${MizanI18n.user(detail.recordTitle)}',
                subtitle:
                    '${shortDate(detail.payment.paidAt)} · ${detail.payment.entryType.label}${detail.payment.method.isEmpty ? '' : ' · ${MizanI18n.user(detail.payment.method)}'}${detail.payment.note.isEmpty ? '' : '\n${MizanI18n.user(detail.payment.note)}'}',
                icon: recordIcon(detail.type),
                leadingColor: MizanTheme.green,
                trailing: Text(
                  money(
                    detail.payment.amount,
                    currencyCode: detail.currencyCode,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                onTap: () => showRecordDetails(
                  context: context,
                  controller: widget.controller,
                  personId: detail.personId,
                  type: detail.type,
                  sourceId: detail.recordId,
                  bankId: detail.bankId,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ReportSection(
          title: 'Kalan ödeme yükünün dağılımı',
          subtitle:
              'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme ve taksit tutarları gösterilir.',
          showZeroEntries: true,
          entries: _remainingDistributionEntries(report),
        ),
        const SizedBox(height: 12),
        _DetailedListSection(
          title: 'Kalan ödeme ayrıntıları',
          subtitle:
              'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı gösterilir. $mizanCalculationWarning',
          emptyMessage: 'Seçili dönemde açık ödeme yükü bulunmuyor.',
          childrenBuilder: (_) => [
            for (final record in report.remainingDetails)
              _ReportDueDetailCard(
                record: record,
                referenceDate: report.balanceReference,
                onTap: () => showRecordDetails(
                  context: context,
                  controller: widget.controller,
                  personId: record.personId,
                  type: record.type,
                  sourceId: record.sourceId,
                  bankId: record.bankId,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ReportSection(
          title: 'Gider dağılımı',
          subtitle:
              'Normal giderler ile ödeme kayıtları aynı toplamda yer alır; kaynak türleri ayrı etiketlerle gösterilir.',
          entries: [
            for (final entry in report.combinedOutflowDistributionByCurrency)
              _ReportEntry(
                label: entry.label,
                amount: entry.amount,
                currencyCode: entry.currencyCode,
                icon: entry.type == null
                    ? Icons.category_outlined
                    : recordIcon(entry.type!),
              ),
          ],
          emptyMessage: 'Seçili dönemde gider veya ödeme kaydı yok.',
        ),
        const SizedBox(height: 12),
        _DetailedListSection(
          title: 'Bütün harcama ayrıntıları',
          subtitle:
              'Her gün başlık olarak gösterilir. Başlığa dokununca günlük harcamalar ve ödemeler kendi bölümlerinde açılır.',
          emptyMessage: 'Seçili dönemde gider veya ödeme ayrıntısı bulunmuyor.',
          childrenBuilder: (_) =>
              report.expenseDetails.isEmpty && report.paymentDetails.isEmpty
                  ? const []
                  : [
                      _ReportOutflowGroups(
                        report: report,
                        controller: widget.controller,
                      ),
                    ],
        ),
        const SizedBox(height: 12),
        _PersonDebtSection(
          details: report.personDebtDetails,
          referenceDate: report.generatedAt,
          controller: widget.controller,
        ),
      ],
    );
  }

  Future<void> _showMetricDetails(
    MizanReport report,
    _ReportMetricDetailKind kind,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _ReportMetricDetailSheet(
        report: report,
        kind: kind,
        controller: widget.controller,
      ),
    );
  }

  Future<void> _selectPeople(MizanState state) async {
    final working = {...selectedPersonIds};
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final allSelected = working.isEmpty;
          return AlertDialog(
            scrollable: true,
            title: const Text('Kişi kapsamı'),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allSelected,
                    title: const Text('Tüm kişileri kapsa'),
                    subtitle: const Text(
                      'Bütün kişilerin ödeme ve borç kayıtları rapora alınır.',
                    ),
                    onChanged: (_) => setDialogState(working.clear),
                  ),
                  const Divider(),
                  for (final person in state.people)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: working.contains(person.id),
                      title: Text.user(person.name),
                      onChanged: (value) => setDialogState(() {
                        if (value == true) {
                          working.add(person.id);
                        } else {
                          working.remove(person.id);
                        }
                      }),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, working),
                child: const Text('Uygula'),
              ),
            ],
          );
        },
      ),
    );
    if (selected != null && mounted) {
      setState(() => selectedPersonIds = selected);
    }
  }

  Future<Uint8List> _buildPdf(MizanReport report) async {
    if (generatingPdf) throw StateError('PDF hazırlanıyor.');
    setState(() => generatingPdf = true);
    try {
      return await const PdfReportService().build(report);
    } finally {
      if (mounted) setState(() => generatingPdf = false);
    }
  }

  String _pdfFileName(MizanReport report) {
    final date = report.generatedAt;
    final stamp =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final suffix = switch (report.languageTag) {
      'en' => 'REPORT',
      'es' => 'INFORME',
      _ => 'RAPOR',
    };
    return 'MIZAN-${report.filter.period.name.toUpperCase()}-$suffix-$stamp.pdf';
  }

  Future<void> _savePdf(MizanReport report) async {
    try {
      final bytes = await _buildPdf(report);
      final result = await FilePicker.platform.saveFile(
        dialogTitle: MizanI18n.text('MİZAN PDF raporunu kaydet'),
        fileName: _pdfFileName(report),
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );
      if (mounted && result != null) {
        _message('PDF raporu kaydedildi.');
      }
    } on Object catch (error) {
      if (mounted) _message('PDF raporu kaydedilemedi: $error', error: true);
    }
  }

  Future<void> _sharePdf(MizanReport report) async {
    try {
      final bytes = await _buildPdf(report);
      await Printing.sharePdf(bytes: bytes, filename: _pdfFileName(report));
    } on Object catch (error) {
      if (mounted) _message('PDF raporu paylaşılamadı: $error', error: true);
    }
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? MizanTheme.red : null,
      ),
    );
  }
}

class _ReportMetricDetailItem {
  const _ReportMetricDetailItem.header(this.title)
      : subtitle = '',
        amount = 0,
        icon = Icons.info_outline,
        color = MizanTheme.ink,
        currencyCode = '',
        record = null,
        payment = null;

  const _ReportMetricDetailItem.data({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currencyCode,
    this.record,
    this.payment,
  });

  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;
  final String currencyCode;
  final RecordReference? record;
  final ReportPaymentDetail? payment;

  bool get isHeader =>
      subtitle.isEmpty && record == null && payment == null && amount == 0;
}

class _ReportMetricDetailSheet extends StatelessWidget {
  const _ReportMetricDetailSheet({
    required this.report,
    required this.kind,
    required this.controller,
  });

  final MizanReport report;
  final _ReportMetricDetailKind kind;
  final MizanController controller;

  String get _title => switch (kind) {
        _ReportMetricDetailKind.normalExpenses => 'Normal gider ayrıntıları',
        _ReportMetricDetailKind.payments => 'Ödeme ayrıntıları',
        _ReportMetricDetailKind.allOutflows => 'Bütün harcama ayrıntıları',
        _ReportMetricDetailKind.remaining => 'Kalan ödeme yükü ayrıntıları',
        _ReportMetricDetailKind.overdue => 'Gecikmiş ödeme ayrıntıları',
        _ReportMetricDetailKind.upcoming => 'Yaklaşan ödeme ayrıntıları',
      };

  String get _subtitle => switch (kind) {
        _ReportMetricDetailKind.normalExpenses =>
          '${report.range.label} dönemindeki günlük gider kayıtlarıdır.',
        _ReportMetricDetailKind.payments =>
          '${report.range.label} döneminde banka, şahıs, fatura, abonelik, kira ve taksit kayıtlarına yapılan ödemelerdir.',
        _ReportMetricDetailKind.allOutflows =>
          'Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.',
        _ReportMetricDetailKind.remaining =>
          'Seçili döneme taşınan gecikmiş kayıtlar ile dönemin açık ödeme yükü ayrıntılı gösterilir.',
        _ReportMetricDetailKind.overdue =>
          'Gecikmiş tutar, açık ve ödenmemiş dönemlerin toplamıdır. $mizanCalculationWarning',
        _ReportMetricDetailKind.upcoming =>
          'Raporun referans gününden itibaren önümüzdeki 7 gün içinde vadesi kalan açık kayıtlar gösterilir.',
      };

  List<_ReportMetricDetailItem> _items() {
    final result = <_ReportMetricDetailItem>[];

    void addExpenses({bool withHeader = false}) {
      if (withHeader) {
        result.add(const _ReportMetricDetailItem.header('Günlük harcamalar'));
      }
      for (final detail in report.expenseDetails) {
        result.add(
          _ReportMetricDetailItem.data(
            title:
                '${MizanI18n.user(detail.categoryName)} · ${MizanI18n.user(detail.expense.name)}',
            subtitle:
                '${shortDate(detail.expense.spentAt)} · ${decimalText(detail.expense.quantity)} × ${money(detail.expense.unitPrice, currencyCode: detail.expense.currencyCode)}${detail.expense.note.trim().isEmpty ? '' : '\n${MizanI18n.user(detail.expense.note.trim())}'}',
            amount: detail.expense.totalAmount,
            icon: Icons.shopping_bag_outlined,
            color: MizanTheme.green,
            currencyCode: detail.expense.currencyCode,
          ),
        );
      }
    }

    void addPayments({bool withHeader = false}) {
      if (withHeader) {
        result.add(const _ReportMetricDetailItem.header('Ödemeler'));
      }
      for (final detail in report.paymentDetails) {
        result.add(
          _ReportMetricDetailItem.data(
            title:
                '${MizanI18n.user(detail.personName)} · ${reportTypeLabel(detail.type)} · ${MizanI18n.user(detail.recordTitle)}',
            subtitle:
                '${shortDate(detail.payment.paidAt)} · ${detail.payment.entryType.label} · ${MizanI18n.user(detail.recordSubtitle)}${detail.payment.note.trim().isEmpty ? '' : '\n${MizanI18n.user(detail.payment.note.trim())}'}',
            amount: detail.payment.amount,
            icon: recordIcon(detail.type),
            color: MizanTheme.blue,
            currencyCode: detail.currencyCode,
            payment: detail,
          ),
        );
      }
    }

    void addRecords(
      Iterable<RecordReference> records, {
      DateTime? referenceDate,
    }) {
      final effectiveReference = referenceDate ?? report.balanceReference;
      for (final record in records) {
        result.add(
          _ReportMetricDetailItem.data(
            title:
                '${reportTypeLabel(record.type)} · ${MizanI18n.user(record.title)}',
            subtitle:
                '${MizanI18n.user(record.subtitle)}\n${shortDate(record.dueDate)} · ${recordTimingLabel(record, effectiveReference)}',
            amount: record.amount,
            icon: recordIcon(record.type),
            color: statusColor(record.status),
            currencyCode: record.currencyCode,
            record: record,
          ),
        );
      }
    }

    switch (kind) {
      case _ReportMetricDetailKind.normalExpenses:
        addExpenses();
        break;
      case _ReportMetricDetailKind.payments:
        addPayments();
        break;
      case _ReportMetricDetailKind.allOutflows:
        addExpenses(withHeader: true);
        addPayments(withHeader: true);
        break;
      case _ReportMetricDetailKind.remaining:
        addRecords(report.remainingDetails);
        break;
      case _ReportMetricDetailKind.overdue:
        addRecords(
          report.remainingDetails.where(
            (item) => item.status == PaymentStatus.overdue,
          ),
        );
        break;
      case _ReportMetricDetailKind.upcoming:
        addRecords(
          report.upcomingDetails,
          referenceDate: report.upcomingReference,
        );
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .86,
      minChildSize: .55,
      maxChildSize: .96,
      builder: (_, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  _subtitle,
                  style: const TextStyle(color: MizanTheme.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Seçili kapsamda ayrıntı bulunmuyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: MizanTheme.muted),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item.isHeader) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Text.user(
                            item.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      }
                      return MizanListCard(
                        title: MizanI18n.user(item.title),
                        subtitle: MizanI18n.user(item.subtitle),
                        icon: item.icon,
                        leadingColor: item.color,
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            money(item.amount, currencyCode: item.currencyCode),
                            textAlign: TextAlign.end,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        onTap: item.record != null
                            ? () => showRecordDetails(
                                  context: context,
                                  controller: controller,
                                  personId: item.record!.personId,
                                  type: item.record!.type,
                                  sourceId: item.record!.sourceId,
                                  bankId: item.record!.bankId,
                                )
                            : item.payment != null
                                ? () => showRecordDetails(
                                      context: context,
                                      controller: controller,
                                      personId: item.payment!.personId,
                                      type: item.payment!.type,
                                      sourceId: item.payment!.recordId,
                                      bankId: item.payment!.bankId,
                                    )
                                : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportFilters extends StatelessWidget {
  const _ReportFilters({
    required this.state,
    required this.period,
    required this.anchorDate,
    required this.availableMonths,
    required this.availableYears,
    required this.selectedPersonIds,
    required this.status,
    required this.onPeriodChanged,
    required this.onAnchorChanged,
    required this.onPeoplePressed,
    required this.onStatusChanged,
  });

  final MizanState state;
  final ReportPeriod period;
  final DateTime anchorDate;
  final List<DateTime> availableMonths;
  final List<int> availableYears;
  final Set<String> selectedPersonIds;
  final PaymentStatus? status;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final ValueChanged<DateTime> onAnchorChanged;
  final VoidCallback onPeoplePressed;
  final ValueChanged<PaymentStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final peopleLabel = selectedPersonIds.isEmpty
        ? 'Tüm kişiler'
        : '${selectedPersonIds.length} kişi seçili';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(
              'Rapor kapsamı',
              subtitle:
                  'Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in const [
                  ReportPeriod.monthly,
                  ReportPeriod.yearly,
                  ReportPeriod.allTime,
                ])
                  ChoiceChip(
                    label: Text(item.label),
                    selected: period == item,
                    onSelected: (_) => onPeriodChanged(item),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (period == ReportPeriod.allTime)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.history_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tüm kayıt geçmişi',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: period == ReportPeriod.monthly
                    ? availableMonths.isEmpty
                        ? null
                        : () async {
                            final selected = await _selectRecordedMonth(
                              context,
                              availableMonths,
                              anchorDate,
                            );
                            if (selected != null) onAnchorChanged(selected);
                          }
                    : availableYears.isEmpty
                        ? null
                        : () async {
                            final selected = await _selectRecordedYear(
                              context,
                              availableYears,
                              anchorDate.year,
                            );
                            if (selected != null) {
                              onAnchorChanged(DateTime(selected));
                            }
                          },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  period == ReportPeriod.monthly && availableMonths.isEmpty
                      ? 'Kayıtlı ay bulunmuyor'
                      : period == ReportPeriod.yearly && availableYears.isEmpty
                          ? 'Kayıtlı yıl bulunmuyor'
                          : _anchorLabel(period, anchorDate),
                ),
              ),
            const SizedBox(height: 6),
            Text(
                switch (period) {
                  ReportPeriod.monthly =>
                    'Güncel ay her zaman açılır; geçmişte kayıt, ödeme, gider veya gelir bulunan aylar ayrıca seçilebilir.',
                  ReportPeriod.yearly =>
                    'Güncel yıl her zaman açılır; kayıt bulunan geçmiş yıllar ayrıca seçilebilir.',
                  ReportPeriod.allTime =>
                    'İlk kayıttan bugüne kadar bütün ödeme, gider ve gelir hareketleri kapsanır.',
                  _ => '',
                },
                style: const TextStyle(color: MizanTheme.muted, fontSize: 12)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onPeoplePressed,
              icon: const Icon(Icons.people_outline),
              label: Text(peopleLabel),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<PaymentStatus?>(
              initialValue: status,
              isExpanded: true,
              decoration: localizedInputDecoration(
                const InputDecoration(
                  labelText: 'Kalan kayıt durumu (opsiyonel)',
                ),
              ),
              items: [
                const DropdownMenuItem<PaymentStatus?>(
                  value: null,
                  child: Text('Tüm durumlar'),
                ),
                for (final item in PaymentStatus.values)
                  DropdownMenuItem<PaymentStatus?>(
                    value: item,
                    child: Text(item.label),
                  ),
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 8),
            const Text(
              'Gider kayıtlarında kişi alanı bulunmadığı için giderler seçili dönem kapsamında ve kişi filtresinden bağımsız hesaplanır.',
              style: TextStyle(color: MizanTheme.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

Future<int?> _selectRecordedYear(
  BuildContext context,
  List<int> years,
  int selected,
) =>
    showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Text(
            'Kayıtlı yılı seç',
            style: Theme.of(
              sheetContext,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final year in years)
            ListTile(
              leading: Icon(
                year == selected
                    ? Icons.check_circle
                    : Icons.calendar_today_outlined,
              ),
              title: Text(year.toString()),
              onTap: () => Navigator.pop(sheetContext, year),
            ),
        ],
      ),
    );

Future<DateTime?> _selectRecordedMonth(
  BuildContext context,
  List<DateTime> months,
  DateTime selected,
) =>
    showModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Text(
            'Kayıtlı ayı seç',
            style: Theme.of(
              sheetContext,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final month in months)
            ListTile(
              leading: Icon(
                month.year == selected.year && month.month == selected.month
                    ? Icons.check_circle
                    : Icons.calendar_month_outlined,
              ),
              title: Text(monthLabel(month)),
              onTap: () => Navigator.pop(sheetContext, month),
            ),
        ],
      ),
    );

class _IncomeReportCard extends StatelessWidget {
  const _IncomeReportCard({required this.report});
  final MizanReport report;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                'Gelir ve net durum',
                subtitle:
                    'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.',
              ),
              const SizedBox(height: 12),
              if (!report.incomeSpecified)
                const Text(
                  'Gelir bilgisi belirtilmemiş',
                  style: TextStyle(
                    color: MizanTheme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else ...[
                _InlineTotal(
                    label: 'Gelir', amounts: report.totalIncomeByCurrency),
                const SizedBox(height: 6),
                _InlineTotal(
                  label: 'Ödemeler sonrası kalan',
                  amounts: report.afterPaymentsByCurrency,
                ),
                const SizedBox(height: 6),
                _InlineTotal(
                  label: 'Ödeme ve gider sonrası net',
                  amounts: report.finalNetByCurrency,
                ),
              ],
            ],
          ),
        ),
      );
}

class _PdfActions extends StatelessWidget {
  const _PdfActions({
    required this.generating,
    required this.onSave,
    required this.onShare,
  });

  final bool generating;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                'PDF raporu',
                subtitle:
                    'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: generating ? null : onSave,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(generating ? 'PDF hazırlanıyor' : 'PDF indir'),
                  ),
                  OutlinedButton.icon(
                    onPressed: generating ? null : onShare,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('PDF paylaş'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _CurrentExpenseOverview extends StatelessWidget {
  const _CurrentExpenseOverview({
    required this.report,
    required this.onNormalExpenses,
    required this.onPayments,
    required this.onAllOutflows,
  });

  final MizanReport report;
  final VoidCallback onNormalExpenses;
  final VoidCallback onPayments;
  final VoidCallback onAllOutflows;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            'Seçili dönem gider özeti',
            subtitle:
                '${report.range.label} filtresine ait normal gider, ödeme ve birleşik toplamlar gösterilir.',
          ),
          const SizedBox(height: 10),
          AdaptiveGrid(
            minTileWidth: 175,
            children: [
              MetricCard(
                label: 'Normal giderler',
                value: moneyBuckets(report.totalExpensesByCurrency),
                color: MizanTheme.green,
                icon: Icons.shopping_bag_outlined,
                note: 'Detayı gör',
                onTap: onNormalExpenses,
              ),
              MetricCard(
                label: 'Ödemeler',
                value: moneyBuckets(report.totalPaymentsByCurrency),
                color: MizanTheme.blue,
                icon: Icons.payments_outlined,
                note: 'Detayı gör',
                onTap: onPayments,
              ),
              MetricCard(
                label: 'Bütün harcamalar',
                value: moneyBuckets(report.realizedGrandTotalsByCurrency),
                color: MizanTheme.orange,
                icon: Icons.account_balance_wallet_outlined,
                note: 'Detayı gör',
                onTap: onAllOutflows,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bütün harcamalar, normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.',
            style:
                TextStyle(color: MizanTheme.muted, fontWeight: FontWeight.w600),
          ),
        ],
      );
}

class _RealizedTotalCard extends StatelessWidget {
  const _RealizedTotalCard({required this.report});
  final MizanReport report;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${report.range.label} toplam gider',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerine yapılan giderlerin toplamıdır. Gelir ayrı gösterilir.',
                style: TextStyle(color: MizanTheme.muted),
              ),
              const SizedBox(height: 14),
              Text(
                moneyBuckets(report.realizedGrandTotalsByCurrency),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: MizanTheme.ink,
                    ),
              ),
              const SizedBox(height: 12),
              _InlineTotal(
                label: 'Ödemelere yapılan gider',
                amounts: report.totalPaymentsByCurrency,
              ),
              const SizedBox(height: 6),
              _InlineTotal(
                label: 'Normal giderler',
                amounts: report.totalExpensesByCurrency,
              ),
              if (report.incomeSpecified) ...[
                const SizedBox(height: 6),
                _InlineTotal(
                  label: 'Gelir sonrası net',
                  amounts: report.finalNetByCurrency,
                ),
              ],
            ],
          ),
        ),
      );
}

class _InlineTotal extends StatelessWidget {
  const _InlineTotal({required this.label, required this.amounts});
  final String label;
  final Map<String, double> amounts;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              moneyBuckets(amounts),
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
}

class _ReportEntry {
  const _ReportEntry({
    required this.label,
    required this.amount,
    required this.icon,
    this.currencyCode = '',
  });
  final String label;
  final double amount;
  final IconData icon;
  final String currencyCode;
}

List<_ReportEntry> _remainingDistributionEntries(MizanReport report) {
  final totals = <String, double>{};
  for (final record in report.remainingDetails) {
    final key = '${record.currencyCode}|${record.type.name}';
    totals[key] = (totals[key] ?? 0) + record.amount;
  }
  return [
    for (final entry in totals.entries)
      _ReportEntry(
        label: reportTypeLabel(
          RecordType.values.firstWhere(
            (item) => item.name == entry.key.split('|')[1],
          ),
        ),
        amount: entry.value,
        currencyCode: entry.key.split('|')[0],
        icon: recordIcon(
          RecordType.values.firstWhere(
            (item) => item.name == entry.key.split('|')[1],
          ),
        ),
      ),
  ];
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.entries,
    this.emptyMessage = 'Kayıt bulunmuyor.',
    this.showZeroEntries = false,
  });

  final String title;
  final String subtitle;
  final List<_ReportEntry> entries;
  final String emptyMessage;
  final bool showZeroEntries;

  @override
  Widget build(BuildContext context) {
    final visible = (showZeroEntries
        ? [...entries]
        : entries.where((item) => item.amount > 0).toList())
      ..sort((a, b) {
        final amountOrder = b.amount.compareTo(a.amount);
        return amountOrder != 0 ? amountOrder : a.label.compareTo(b.label);
      });
    final maxAmount = visible.fold<double>(
      0,
      (max, item) => item.amount > max ? item.amount : max,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(title, subtitle: subtitle),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              Text(
                emptyMessage,
                style: const TextStyle(color: MizanTheme.muted),
              )
            else
              for (final item in visible) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(item.icon, size: 19, color: MizanTheme.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.currencyCode.isEmpty
                                  ? money(item.amount)
                                  : money(
                                      item.amount,
                                      currencyCode: item.currencyCode,
                                    ),
                              textAlign: TextAlign.end,
                              softWrap: true,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: maxAmount <= 0 ? 0 : item.amount / maxAmount,
                          backgroundColor: MizanTheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _ReportDueDetailCard extends StatelessWidget {
  const _ReportDueDetailCard({
    required this.record,
    required this.referenceDate,
    required this.onTap,
  });

  final RecordReference record;
  final DateTime referenceDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timing = recordTimingLabel(record, referenceDate);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor(record.status).withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      recordIcon(record.type),
                      color: statusColor(record.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.user(
                          record.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.user(
                          record.subtitle,
                          style: const TextStyle(
                            color: MizanTheme.muted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: Text(
                      money(record.amount, currencyCode: record.currencyCode),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReportPill(
                    icon: Icons.calendar_today_outlined,
                    label: shortDate(record.dueDate),
                  ),
                  _ReportPill(
                    icon: record.status == PaymentStatus.overdue
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_outlined,
                    label: timing,
                    color: statusColor(record.status),
                  ),
                  _ReportPill(
                    icon: Icons.category_outlined,
                    label: reportTypeLabel(record.type),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportOutflowGroups extends StatefulWidget {
  const _ReportOutflowGroups({required this.report, required this.controller});

  final MizanReport report;
  final MizanController controller;

  @override
  State<_ReportOutflowGroups> createState() => _ReportOutflowGroupsState();
}

class _ReportOutflowDay {
  const _ReportOutflowDay({
    required this.day,
    required this.expenses,
    required this.payments,
  });

  final DateTime day;
  final List<ReportExpenseDetail> expenses;
  final List<ReportPaymentDetail> payments;

  Map<String, double> get totalsByCurrency {
    final result = <String, double>{};
    for (final detail in expenses) {
      final code = detail.expense.currencyCode;
      result[code] = (result[code] ?? 0) + detail.expense.totalAmount;
    }
    for (final detail in payments) {
      final code = detail.currencyCode;
      result[code] = (result[code] ?? 0) + detail.payment.amount;
    }
    return result;
  }
}

class _ReportOutflowGroupsState extends State<_ReportOutflowGroups> {
  static const _pageSize = 30;
  static const _browser = ExpenseBrowserService();
  int visibleDayLimit = _pageSize;
  final Set<int> expandedDays = <int>{};

  int _key(DateTime value) =>
      value.year * 10000 + value.month * 100 + value.day;

  @override
  void didUpdateWidget(covariant _ReportOutflowGroups oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.report, widget.report)) {
      visibleDayLimit = _pageSize;
      expandedDays.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseGroups = <int, List<ReportExpenseDetail>>{};
    final paymentGroups = <int, List<ReportPaymentDetail>>{};
    final days = <int, DateTime>{};
    for (final detail in widget.report.expenseDetails) {
      final day = dateOnly(detail.expense.spentAt);
      final key = _key(day);
      days[key] = day;
      expenseGroups.putIfAbsent(key, () => <ReportExpenseDetail>[]).add(detail);
    }
    for (final detail in widget.report.paymentDetails) {
      final day = dateOnly(detail.payment.paidAt);
      final key = _key(day);
      days[key] = day;
      paymentGroups.putIfAbsent(key, () => <ReportPaymentDetail>[]).add(detail);
    }
    final groups = [
      for (final entry in days.entries)
        _ReportOutflowDay(
          day: entry.value,
          expenses: expenseGroups[entry.key] ?? const [],
          payments: paymentGroups[entry.key] ?? const [],
        ),
    ]..sort((a, b) => b.day.compareTo(a.day));
    final visible = groups.take(visibleDayLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in visible) ...[
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() {
              final key = _key(group.day);
              if (!expandedDays.add(key)) expandedDays.remove(key);
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: MizanTheme.blue.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: MizanTheme.blue.withValues(alpha: .14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: MizanTheme.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _browser.dayLabel(group.day),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${group.expenses.length} günlük harcama · ${group.payments.length} ödeme',
                          style: const TextStyle(
                            color: MizanTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 125),
                    child: Text(
                      moneyBuckets(group.totalsByCurrency),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expandedDays.contains(_key(group.day))
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (expandedDays.contains(_key(group.day))) ...[
            if (group.expenses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 12, 4, 7),
                child: Text(
                  'Günlük harcamalar',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              for (final detail in group.expenses)
                _ReportExpenseDetailCard(detail: detail),
            ],
            if (group.payments.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 12, 4, 7),
                child: Text(
                  'Ödemeler',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              for (final detail in group.payments)
                _ReportPaymentDetailCard(
                  detail: detail,
                  controller: widget.controller,
                ),
            ],
          ],
          const SizedBox(height: 9),
        ],
        if (visible.length < groups.length)
          OutlinedButton.icon(
            onPressed: () => setState(() => visibleDayLimit += _pageSize),
            icon: const Icon(Icons.expand_more),
            label: Text(
              'Daha fazla gün göster (${groups.length - visible.length} kaldı)',
            ),
          ),
      ],
    );
  }
}

class _ReportPaymentDetailCard extends StatelessWidget {
  const _ReportPaymentDetailCard({
    required this.detail,
    required this.controller,
  });

  final ReportPaymentDetail detail;
  final MizanController controller;

  @override
  Widget build(BuildContext context) => MizanListCard(
        title:
            '${MizanI18n.user(detail.personName)} · ${reportTypeLabel(detail.type)} · ${MizanI18n.user(detail.recordTitle)}',
        subtitle:
            '${MizanI18n.user(detail.recordSubtitle)}\n${shortDate(detail.payment.paidAt)} · ${detail.payment.entryType.label}${detail.payment.method.trim().isEmpty ? '' : ' · ${MizanI18n.user(detail.payment.method.trim())}'}${detail.payment.note.trim().isEmpty ? '' : '\nNot: ${MizanI18n.user(detail.payment.note.trim())}'}',
        icon: recordIcon(detail.type),
        leadingColor: MizanTheme.blue,
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 125),
          child: Text(
            money(detail.payment.amount, currencyCode: detail.currencyCode),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        onTap: () => showRecordDetails(
          context: context,
          controller: controller,
          personId: detail.personId,
          type: detail.type,
          sourceId: detail.recordId,
          bankId: detail.bankId,
        ),
      );
}

class _ReportExpenseGroups extends StatefulWidget {
  const _ReportExpenseGroups({required this.details});

  final List<ReportExpenseDetail> details;

  @override
  State<_ReportExpenseGroups> createState() => _ReportExpenseGroupsState();
}

class _ReportExpenseGroupsState extends State<_ReportExpenseGroups> {
  static const _pageSize = 30;
  static const _browser = ExpenseBrowserService();
  int visibleDayLimit = _pageSize;
  final Set<int> expandedDays = <int>{};

  @override
  void didUpdateWidget(covariant _ReportExpenseGroups oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.details, widget.details)) {
      visibleDayLimit = _pageSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <int, List<ReportExpenseDetail>>{};
    for (final detail in widget.details) {
      final date = dateOnly(detail.expense.spentAt);
      final key = date.year * 10000 + date.month * 100 + date.day;
      groups.putIfAbsent(key, () => <ReportExpenseDetail>[]).add(detail);
    }
    final sorted = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final visible = sorted.take(visibleDayLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in visible) ...[
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() {
              if (!expandedDays.add(entry.key)) expandedDays.remove(entry.key);
            }),
            child: _ReportExpenseDayHeader(
              day: DateTime(
                entry.key ~/ 10000,
                (entry.key ~/ 100) % 100,
                entry.key % 100,
              ),
              count: entry.value.length,
              totals: {
                for (final code in entry.value
                    .map((item) => item.expense.currencyCode)
                    .toSet())
                  code: entry.value
                      .where((item) => item.expense.currencyCode == code)
                      .fold<double>(
                        0,
                        (sum, item) => sum + item.expense.totalAmount,
                      ),
              },
              labelBuilder: _browser.dayLabel,
            ),
          ),
          if (expandedDays.contains(entry.key)) ...[
            const SizedBox(height: 8),
            for (final detail in entry.value)
              _ReportExpenseDetailCard(detail: detail),
          ],
          const SizedBox(height: 8),
        ],
        if (visible.length < sorted.length)
          OutlinedButton.icon(
            key: const ValueKey('report-expense-load-more'),
            onPressed: () => setState(() => visibleDayLimit += _pageSize),
            icon: const Icon(Icons.expand_more),
            label: Text(
              'Daha fazla gider günü göster '
              '(${sorted.length - visible.length} kaldı)',
            ),
          ),
      ],
    );
  }
}

class _ReportExpenseDayHeader extends StatelessWidget {
  const _ReportExpenseDayHeader({
    required this.day,
    required this.count,
    required this.totals,
    required this.labelBuilder,
  });

  final DateTime day;
  final int count;
  final Map<String, double> totals;
  final String Function(DateTime) labelBuilder;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: MizanTheme.blue.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MizanTheme.blue.withValues(alpha: .14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: MizanTheme.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelBuilder(day),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '$count gider kaydı',
                    style:
                        const TextStyle(color: MizanTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                moneyBuckets(totals),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
}

class _ReportExpenseDetailCard extends StatelessWidget {
  const _ReportExpenseDetailCard({required this.detail});

  final ReportExpenseDetail detail;

  @override
  Widget build(BuildContext context) {
    final expense = detail.expense;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: MizanTheme.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.user(
                    expense.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Text(
                    money(
                      expense.totalAmount,
                      currencyCode: expense.currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReportPill(
                  icon: Icons.calendar_today_outlined,
                  label: shortDate(expense.spentAt),
                ),
                _ReportPill(
                  icon: Icons.category_outlined,
                  label: MizanI18n.user(detail.categoryName),
                ),
                _ReportPill(
                  icon: Icons.calculate_outlined,
                  label:
                      '${decimalText(expense.quantity)} × ${money(expense.unitPrice, currencyCode: expense.currencyCode)}',
                ),
              ],
            ),
            if (expense.note.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Not: ${MizanI18n.user(expense.note.trim())}',
                style: const TextStyle(color: MizanTheme.muted, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportPill extends StatelessWidget {
  const _ReportPill({
    required this.icon,
    required this.label,
    this.color = MizanTheme.blue,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: .16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _DetailedListSection extends StatefulWidget {
  const _DetailedListSection({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.childrenBuilder,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<Widget> Function(BuildContext context) childrenBuilder;

  @override
  State<_DetailedListSection> createState() => _DetailedListSectionState();
}

class _DetailedListSectionState extends State<_DetailedListSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final children =
        expanded ? widget.childrenBuilder(context) : const <Widget>[];
    return Card(
      child: ExpansionTile(
        key: PageStorageKey('report-detail-${widget.title}'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => setState(() => expanded = value),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(widget.subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: expanded
            ? [
                if (children.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.emptyMessage,
                      style: const TextStyle(color: MizanTheme.muted),
                    ),
                  )
                else
                  for (var index = 0; index < children.length; index++) ...[
                    children[index],
                    if (index != children.length - 1) const SizedBox(height: 8),
                  ],
              ]
            : const [],
      ),
    );
  }
}

class _PersonDebtSection extends StatelessWidget {
  const _PersonDebtSection({
    required this.details,
    required this.referenceDate,
    required this.controller,
  });

  final List<ReportPersonDebtDetail> details;
  final DateTime referenceDate;
  final MizanController controller;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                'Kişi bazında güncel kalan borç',
                subtitle:
                    'Kişi ve kayıt türü başlıklarına dokunarak ayrıntıları açıp kapatabilirsiniz. Kayıt satırına dokununca tam kayıt detayı açılır.',
              ),
              const SizedBox(height: 12),
              if (details.isEmpty)
                const Text(
                  'Kişi kaydı bulunmuyor.',
                  style: TextStyle(color: MizanTheme.muted),
                )
              else
                for (final person in details)
                  _PersonDebtPersonTile(
                    detail: person,
                    referenceDate: referenceDate,
                    controller: controller,
                  ),
            ],
          ),
        ),
      );
}

class _PersonDebtPersonTile extends StatefulWidget {
  const _PersonDebtPersonTile({
    required this.detail,
    required this.referenceDate,
    required this.controller,
  });

  final ReportPersonDebtDetail detail;
  final DateTime referenceDate;
  final MizanController controller;

  @override
  State<_PersonDebtPersonTile> createState() => _PersonDebtPersonTileState();
}

class _PersonDebtPersonTileState extends State<_PersonDebtPersonTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final person = widget.detail;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        key: PageStorageKey('report-person-${person.personId}'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => setState(() => expanded = value),
        title: Text.user(
          person.personName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          'Toplam kalan: ${moneyBuckets(_recordBuckets(person.records))}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: expanded
            ? [
                for (final type in RecordType.values)
                  if ((person.byType[type] ?? 0) > 0)
                    _PersonDebtTypeTile(
                      person: person,
                      type: type,
                      referenceDate: widget.referenceDate,
                      controller: widget.controller,
                    ),
              ]
            : const [],
      ),
    );
  }
}

class _PersonDebtTypeTile extends StatefulWidget {
  const _PersonDebtTypeTile({
    required this.person,
    required this.type,
    required this.referenceDate,
    required this.controller,
  });

  final ReportPersonDebtDetail person;
  final RecordType type;
  final DateTime referenceDate;
  final MizanController controller;

  @override
  State<_PersonDebtTypeTile> createState() => _PersonDebtTypeTileState();
}

class _PersonDebtTypeTileState extends State<_PersonDebtTypeTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final records = expanded
        ? widget.person.records
            .where((item) => item.type == widget.type)
            .toList(growable: false)
        : const <RecordReference>[];
    return ExpansionTile(
      key: PageStorageKey(
        'report-person-${widget.person.personId}-${widget.type.name}',
      ),
      initiallyExpanded: expanded,
      onExpansionChanged: (value) => setState(() => expanded = value),
      tilePadding: EdgeInsets.zero,
      title: Text(
        reportTypeLabel(widget.type),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${widget.person.records.where((item) => item.type == widget.type).length} kayıt',
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Text(
          moneyBuckets(
            _recordBuckets(
              widget.person.records.where((item) => item.type == widget.type),
            ),
          ),
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      children: expanded
          ? [
              for (final record in records)
                MizanListCard(
                  title: MizanI18n.user(record.title),
                  subtitle:
                      '${MizanI18n.user(record.subtitle)}\n${shortDate(record.dueDate)} · ${recordTimingLabel(record, widget.referenceDate)}',
                  icon: recordIcon(record.type),
                  leadingColor: statusColor(record.status),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 115),
                    child: Text(
                      money(record.amount, currencyCode: record.currencyCode),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  onTap: () => showRecordDetails(
                    context: context,
                    controller: widget.controller,
                    personId: record.personId,
                    type: record.type,
                    sourceId: record.sourceId,
                    bankId: record.bankId,
                  ),
                ),
            ]
          : const [],
    );
  }
}

Map<String, double> _recordBuckets(Iterable<RecordReference> records) {
  final result = <String, double>{};
  for (final record in records) {
    result[record.currencyCode] =
        (result[record.currencyCode] ?? 0) + record.amount;
  }
  return result;
}

String _anchorLabel(ReportPeriod period, DateTime anchor) => switch (period) {
      ReportPeriod.daily => shortDate(anchor),
      ReportPeriod.weekly =>
        'Hafta: ${shortDate(anchor.subtract(Duration(days: anchor.weekday - 1)))}',
      ReportPeriod.monthly => monthLabel(anchor),
      ReportPeriod.yearly => anchor.year.toString(),
      ReportPeriod.allTime => 'Tüm zamanlar',
    };

String reportTypeLabel(RecordType type) => switch (type) {
      RecordType.debt => 'Banka borçları',
      RecordType.personalDebt => 'Kişisel ve kurumsal borçlar',
      RecordType.bill => 'Faturalar',
      RecordType.subscription => 'Abonelikler',
      RecordType.rent => 'Kira ve taksitler',
    };

IconData recordIcon(RecordType type) => switch (type) {
      RecordType.debt => Icons.account_balance_outlined,
      RecordType.personalDebt => Icons.handshake_outlined,
      RecordType.bill => Icons.receipt_long_outlined,
      RecordType.subscription => Icons.autorenew_outlined,
      RecordType.rent => Icons.home_work_outlined,
    };
