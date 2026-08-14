import '../core/localized_material.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../global/global_catalog.dart';
import '../models/mizan_models.dart';
import '../widgets/global_picker_dialog.dart';
import '../services/monthly_payment_status_service.dart';
import '../services/report_service.dart';
import '../widgets/mizan_cards.dart';
import 'people_screen.dart';

class _DashboardData {
  const _DashboardData({
    required this.dayStamp,
    required this.records,
    required this.critical,
    required this.monthIncomeByCurrency,
    required this.todayPaymentsByCurrency,
    required this.monthPaymentsByCurrency,
    required this.todayExpensesByCurrency,
    required this.monthExpensesByCurrency,
    required this.monthOpenRecords,
    required this.monthOpenByCurrency,
    required this.monthPaymentDetails,
  });

  final int dayStamp;
  final List<RecordReference> records;
  final List<RecordReference> critical;
  final Map<String, double> monthIncomeByCurrency;
  final Map<String, double> todayPaymentsByCurrency;
  final Map<String, double> monthPaymentsByCurrency;
  final Map<String, double> todayExpensesByCurrency;
  final Map<String, double> monthExpensesByCurrency;
  final List<RecordReference> monthOpenRecords;
  final Map<String, double> monthOpenByCurrency;
  final List<ReportPaymentDetail> monthPaymentDetails;
}

Map<String, double> _dashboardRecordBuckets(Iterable<RecordReference> records) {
  final result = <String, double>{};
  for (final record in records) {
    result[record.currencyCode] =
        (result[record.currencyCode] ?? 0) + record.amount;
  }
  return result;
}

Map<String, double> _dashboardPaymentBuckets(
  Iterable<ReportPaymentDetail> details,
) {
  final result = <String, double>{};
  for (final detail in details) {
    result[detail.currencyCode] =
        (result[detail.currencyCode] ?? 0) + detail.payment.amount;
  }
  return result;
}

Map<String, double> _dashboardSumBuckets(Iterable<Map<String, double>> maps) {
  final result = <String, double>{};
  for (final map in maps) {
    for (final entry in map.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
  }
  result.removeWhere((_, value) => value.abs() < 0.000001);
  return result;
}

Map<String, double> _dashboardSubtractBuckets(
  Map<String, double> income,
  Iterable<Map<String, double>> outflows,
) {
  final result = <String, double>{...income};
  for (final map in outflows) {
    for (final entry in map.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
  }
  result.removeWhere((_, value) => value.abs() < 0.000001);
  return result;
}

Map<String, double> _dashboardRemainingByType(
  MizanState state,
  RecordType type,
) {
  final result = <String, double>{};
  void add(String code, double amount) {
    if (amount <= 0) return;
    result[code] = (result[code] ?? 0) + amount;
  }

  switch (type) {
    case RecordType.debt:
      for (final item in state.allDebtProducts.where(
        (item) => !item.isArchived,
      )) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.personalDebt:
      for (final item in state.allPersonalDebts.where(
        (item) => !item.isArchived,
      )) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.bill:
      for (final item in state.allBills.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.subscription:
      for (final item in state.allSubscriptions.where(
        (item) => !item.isArchived,
      )) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.rent:
      for (final item in state.allRents.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
  }
  return result;
}

final Expando<_DashboardData> _dashboardDataCache = Expando<_DashboardData>(
  'mizan-dashboard-data',
);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({required this.controller, super.key});

  final MizanController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final now = DateTime.now();
    final dayStamp = now.year * 10000 + now.month * 100 + now.day;
    var data = _dashboardDataCache[state];
    if (data == null || data.dayStamp != dayStamp) {
      final records = state.recordReferencesAt(now)
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final critical = records
          .where((item) {
            final days = calendarDaysBetween(now, item.dueDate);
            return item.amount > 0 &&
                item.status != PaymentStatus.completed &&
                item.status != PaymentStatus.passive &&
                days <= 7;
          })
          .take(8)
          .toList(growable: false);
      final monthlyStatus = const MonthlyPaymentStatusService().build(
        state: state,
        month: now,
        referenceDate: now,
      );
      final monthOpenRecords = monthlyStatus.openRecords;
      final monthPaymentDetails = monthlyStatus.paymentDetails;
      final monthStart = DateTime(now.year, now.month);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final todayPaymentDetails = monthPaymentDetails
          .where((item) => dateOnly(item.payment.paidAt) == dateOnly(now))
          .toList(growable: false);
      data = _DashboardData(
        dayStamp: dayStamp,
        records: records,
        critical: critical,
        monthIncomeByCurrency: state.incomeTotalsForRangeByCurrency(
          monthStart,
          monthEnd,
        ),
        todayPaymentsByCurrency: _dashboardPaymentBuckets(todayPaymentDetails),
        monthPaymentsByCurrency: _dashboardPaymentBuckets(monthPaymentDetails),
        todayExpensesByCurrency: state.expenseTotalsForRangeByCurrency(
          now,
          now,
        ),
        monthExpensesByCurrency: state.expenseTotalsForRangeByCurrency(
          monthStart,
          monthEnd,
        ),
        monthOpenRecords: monthOpenRecords,
        monthOpenByCurrency: _dashboardRecordBuckets(monthOpenRecords),
        monthPaymentDetails: monthPaymentDetails,
      );
      _dashboardDataCache[state] = data;
    }
    final resolvedData = data;
    final records = resolvedData.records;
    final critical = resolvedData.critical;
    final monthIncome = resolvedData.monthIncomeByCurrency;
    final todayPayments = resolvedData.todayPaymentsByCurrency;
    final monthPayments = resolvedData.monthPaymentsByCurrency;
    final todayExpenses = resolvedData.todayExpensesByCurrency;
    final monthExpenses = resolvedData.monthExpensesByCurrency;
    final monthOpenRecords = resolvedData.monthOpenRecords;
    final monthOpenTotal = resolvedData.monthOpenByCurrency;
    final monthPaymentDetails = resolvedData.monthPaymentDetails;
    final todayTotalOutflow = _dashboardSumBuckets([
      todayExpenses,
      todayPayments,
    ]);
    final monthTotalOutflow = _dashboardSumBuckets([
      monthExpenses,
      monthPayments,
    ]);
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;

    return ListView(
      key: const PageStorageKey('dashboard'),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 110),
      children: [
        const PageHeader(
          title: 'LEFFERION PRIME - MİZAN',
          subtitle:
              'Borç, ödeme ve giderlerin sade özeti. Detay görmek için kartlara dokunabilirsin.',
        ),
        const SizedBox(height: 18),
        _IncomeOverviewCard(
          hasIncome: state.hasIncomeInformation,
          monthIncome: monthIncome,
          afterPayments: _dashboardSubtractBuckets(monthIncome, [
            monthPayments,
          ]),
          finalNet: _dashboardSubtractBuckets(monthIncome, [
            monthPayments,
            monthExpenses,
          ]),
          onManage: () => _showIncomeManager(context),
        ),
        const SizedBox(height: 18),
        AdaptiveGrid(
          minTileWidth: 185,
          children: [
            MetricCard(
              label: 'Kalan toplam borç',
              value: moneyBuckets(state.recordRemainingTotalsByCurrency()),
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => _showDebtBreakdown(context, state),
            ),
            MetricCard(
              label: 'Bu Ayın Ödeme Durumu',
              value: moneyBuckets(
                _dashboardSumBuckets([monthOpenTotal, monthPayments]),
              ),
              color: MizanTheme.blue,
              icon: Icons.calendar_month_outlined,
              note:
                  'Açık plan ${moneyBuckets(monthOpenTotal)} · Bu ay yapılan ${moneyBuckets(monthPayments)}',
              onTap: () => _showMonthlyPaymentOverview(
                context,
                openRecords: monthOpenRecords,
                paymentDetails: monthPaymentDetails,
                month: now,
              ),
            ),
            MetricCard(
              label: 'Gecikmiş toplam',
              value: moneyBuckets(
                _dashboardRecordBuckets(
                  records.where((item) => item.status == PaymentStatus.overdue),
                ),
              ),
              color: MizanTheme.red,
              icon: Icons.warning_amber_rounded,
              onTap: () => _showRecordList(
                context,
                title: 'Gecikmiş ödemeler',
                records: records
                    .where((item) => item.status == PaymentStatus.overdue)
                    .toList(growable: false),
              ),
            ),
            MetricCard(
              label: 'Önümüzdeki 7 gün',
              value: moneyBuckets(
                _dashboardRecordBuckets(
                  records.where((item) {
                    final days = calendarDaysBetween(now, item.dueDate);
                    return days >= 0 && days <= 7 && item.amount > 0;
                  }),
                ),
              ),
              color: MizanTheme.orange,
              icon: Icons.upcoming_outlined,
              onTap: () => _showRecordList(
                context,
                title: 'Önümüzdeki 7 gün',
                records: records.where((item) {
                  final days = calendarDaysBetween(now, item.dueDate);
                  return days >= 0 && days <= 7 && item.amount > 0;
                }).toList(growable: false),
              ),
            ),
            MetricCard(
              label: 'Bugünkü normal gider',
              value: moneyBuckets(todayExpenses),
              color: MizanTheme.green,
              icon: Icons.shopping_bag_outlined,
            ),
            MetricCard(
              label: 'Bu ay normal gider',
              value: moneyBuckets(monthExpenses),
              color: MizanTheme.green,
              icon: Icons.receipt_outlined,
            ),
            MetricCard(
              label: 'Bugünkü ödemelere yapılan gider',
              value: moneyBuckets(todayPayments),
              color: MizanTheme.blue,
              icon: Icons.payments_outlined,
            ),
            MetricCard(
              label: 'Bu ay ödemelere yapılan gider',
              value: moneyBuckets(monthPayments),
              color: MizanTheme.blue,
              icon: Icons.account_balance_outlined,
            ),
            MetricCard(
              label: 'Bugünkü toplam gider',
              value: moneyBuckets(todayTotalOutflow),
              color: MizanTheme.purple,
              icon: Icons.calculate_outlined,
              note:
                  'Normal giderler ile banka, şahıs, fatura, abonelik, kira ve taksit ödemelerinin toplamıdır.',
            ),
            MetricCard(
              label: 'Bu ay toplam gider',
              value: moneyBuckets(monthTotalOutflow),
              color: MizanTheme.purple,
              icon: Icons.summarize_outlined,
              note:
                  'Bu ayın normal giderleri ile kaydedilmiş tüm ödeme giderlerinin toplamıdır.',
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle(
          'Kritik ödemeler',
          subtitle:
              'Gecikmiş veya yedi gün içinde vadesi gelen kayıtlar. Ayrıntı için satıra dokun.',
        ),
        const SizedBox(height: 8),
        Text(
          mizanCalculationWarning,
          style: TextStyle(
            color: MizanTheme.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (critical.isEmpty)
          const EmptyState(
            title: 'Kritik ödeme yok',
            message:
                'Gecikmiş veya önümüzdeki yedi gün içinde vadesi gelen kayıt bulunmuyor.',
          )
        else
          for (final record in critical) ...[
            MizanListCard(
              title: MizanI18n.user(record.title),
              subtitle:
                  '${record.type.label} · ${MizanI18n.user(record.subtitle)}\n${_dueText(record, now)} · ${money(record.amount, currencyCode: record.currencyCode)}',
              leadingColor: statusColor(record.status),
              icon: _recordIcon(record.type),
              trailing: StatusChip(status: record.status),
              onTap: () => showRecordDetails(
                context: context,
                controller: controller,
                personId: record.personId,
                type: record.type,
                sourceId: record.sourceId,
                bankId: record.bankId,
              ),
            ),
            const SizedBox(height: 8),
          ],
        if (state.people.isEmpty) ...[
          const SizedBox(height: 18),
          const EmptyState(
            title: 'Uygulama boş ve kullanıma hazır',
            message:
                'Örnek ödeme veya borç oluşturulmadı. Kayıtlar bölümünden ilk kişiyi ekleyerek başlayabilirsin.',
          ),
        ],
      ],
    );
  }

  Future<void> _showIncomeManager(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final incomes = controller.state.incomes;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .78,
            minChildSize: .45,
            maxChildSize: .95,
            builder: (_, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Gelir bilgileri',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        await _showIncomeForm(sheetContext);
                        setSheetState(() {});
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Gelir ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gelir kaydı opsiyoneldir. Borç ödemeleri ve giderler gelirden ayrı tutulur; net sonuç raporda hesaplanır.',
                  style: TextStyle(color: MizanTheme.muted),
                ),
                const SizedBox(height: 14),
                if (incomes.isEmpty)
                  const EmptyState(
                    title: 'Gelir bilgisi belirtilmemiş',
                    message:
                        'Tek seferlik, günlük, haftalık veya aylık gelir ekleyebilirsin.',
                  )
                else
                  for (final income in incomes) ...[
                    MizanListCard(
                      title: MizanI18n.user(income.title),
                      subtitle: _incomeSubtitle(income, DateTime.now()),
                      leadingColor: income.isArchived
                          ? MizanTheme.muted
                          : MizanTheme.green,
                      icon: Icons.account_balance_outlined,
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'received') {
                            await _markIncomeReceived(sheetContext, income);
                          } else if (action == 'undo-received') {
                            await controller.undoLatestIncomeReceipt(income.id);
                          } else if (action == 'edit') {
                            await _showIncomeForm(sheetContext, income: income);
                          } else if (action == 'archive') {
                            await controller.setIncomeArchived(
                              income.id,
                              !income.isArchived,
                            );
                          } else if (action == 'delete') {
                            await controller.deleteIncome(income.id);
                          }
                          setSheetState(() {});
                        },
                        itemBuilder: (_) => [
                          if (income.scheduleTrackingEnabled &&
                              income.supportsScheduleTracking)
                            const PopupMenuItem(
                              value: 'received',
                              child: Text('Gelir yattı'),
                            ),
                          if (income.receipts.isNotEmpty)
                            const PopupMenuItem(
                              value: 'undo-received',
                              child: Text('Son alınma işaretini geri al'),
                            ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Düzenle'),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Text(
                              income.isArchived ? 'Arşivden çıkar' : 'Arşivle',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Sil'),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await _showIncomeForm(sheetContext, income: income);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showIncomeForm(
    BuildContext context, {
    IncomeEntry? income,
  }) async {
    final title = TextEditingController(text: income?.title ?? '');
    final amount = TextEditingController(
      text: income == null ? '' : decimalText(income.amount),
    );
    final note = TextEditingController(text: income?.note ?? '');
    var currencyCode =
        income?.currencyCode ?? controller.state.defaultCurrencyCode;
    var frequency = income?.frequency ?? IncomeFrequency.monthly;
    var startDate = income?.startDate ?? dateOnly(DateTime.now());
    var scheduleTrackingEnabled = income?.scheduleTrackingEnabled ?? false;
    var scheduledWeekday = income?.scheduledWeekday ?? startDate.weekday;
    var scheduledDayOfMonth = income?.scheduledDayOfMonth ?? startDate.day;
    final formKey = GlobalKey<FormState>();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            scrollable: true,
            title: Text(income == null ? 'Gelir ekle' : 'Geliri düzenle'),
            content: SizedBox(
              width: 520,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: title,
                      maxLength: 100,
                      decoration: localizedInputDecoration(
                        const InputDecoration(
                          labelText: 'Gelir türü / adı',
                          hintText: 'Maaş, ek iş, kira geliri…',
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Gelir türü boş bırakılamaz.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.currency_exchange_outlined),
                      title: const Text('Para birimi seç'),
                      subtitle: Text.user(currencyCode),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final catalog = GlobalCatalogRepository.current;
                        final selected = await showCurrencyPicker(
                          dialogContext,
                          catalog: catalog,
                          selectedCode: currencyCode,
                        );
                        if (selected != null) {
                          setDialogState(() => currencyCode = selected.code);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: localizedInputDecoration(
                        InputDecoration(
                          labelText: 'Gelir tutarı',
                          suffixText: currencyCode,
                        ),
                      ),
                      validator: (value) {
                        try {
                          if (parseMoney(value ?? '') <= 0) {
                            return 'Gelir tutarı sıfırdan büyük olmalıdır.';
                          }
                          return null;
                        } on FormatException catch (error) {
                          return error.message;
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<IncomeFrequency>(
                      initialValue: frequency,
                      isExpanded: true,
                      decoration: localizedInputDecoration(
                        const InputDecoration(labelText: 'Gelir sıklığı'),
                      ),
                      items: [
                        for (final item in IncomeFrequency.values)
                          DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                      ],
                      onChanged: (value) => setDialogState(() {
                        frequency = value ?? frequency;
                        if (frequency != IncomeFrequency.weekly &&
                            frequency != IncomeFrequency.monthly) {
                          scheduleTrackingEnabled = false;
                        }
                      }),
                    ),
                    if (frequency == IncomeFrequency.weekly ||
                        frequency == IncomeFrequency.monthly) ...[
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Yatış gününü takip et'),
                        subtitle: const Text(
                          'Opsiyoneldir. Planlanan gün ile gerçek alınma tarihi ayrı tutulur.',
                        ),
                        value: scheduleTrackingEnabled,
                        onChanged: (value) => setDialogState(
                          () => scheduleTrackingEnabled = value,
                        ),
                      ),
                      if (scheduleTrackingEnabled) ...[
                        const SizedBox(height: 8),
                        if (frequency == IncomeFrequency.weekly)
                          DropdownButtonFormField<int>(
                            initialValue: scheduledWeekday,
                            isExpanded: true,
                            decoration: localizedInputDecoration(
                              const InputDecoration(
                                labelText: 'Haftanın hangi günü yatıyor?',
                              ),
                            ),
                            items: [
                              for (var day = DateTime.monday;
                                  day <= DateTime.sunday;
                                  day++)
                                DropdownMenuItem(
                                  value: day,
                                  child: Text(_weekdayName(day)),
                                ),
                            ],
                            onChanged: (value) => setDialogState(
                              () =>
                                  scheduledWeekday = value ?? scheduledWeekday,
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            initialValue:
                                scheduledDayOfMonth.clamp(1, 31).toInt(),
                            isExpanded: true,
                            decoration: localizedInputDecoration(
                              const InputDecoration(
                                labelText: 'Her ayın kaçında yatıyor?',
                                helperText:
                                    'Ay daha kısaysa o ayın son geçerli günü kullanılır.',
                              ),
                            ),
                            items: [
                              for (var day = 1; day <= 31; day++)
                                DropdownMenuItem(
                                  value: day,
                                  child: Text('Ayın $day. günü'),
                                ),
                            ],
                            onChanged: (value) => setDialogState(
                              () => scheduledDayOfMonth =
                                  value ?? scheduledDayOfMonth,
                            ),
                          ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: dialogContext,
                          initialDate: startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          helpText: 'Gelir başlangıç tarihini seçin',
                        );
                        if (selected != null) {
                          setDialogState(() => startDate = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text('Başlangıç: ${shortDate(startDate)}'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: note,
                      maxLength: 240,
                      minLines: 2,
                      maxLines: 4,
                      decoration: localizedInputDecoration(
                        const InputDecoration(
                          labelText: 'Gelir notu (opsiyonel)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  if (income == null) {
                    await controller.addIncome(
                      title: title.text,
                      currencyCode: currencyCode,
                      amount: parseMoney(amount.text),
                      frequency: frequency,
                      startDate: startDate,
                      note: note.text,
                      scheduleTrackingEnabled: scheduleTrackingEnabled,
                      scheduledWeekday: frequency == IncomeFrequency.weekly
                          ? scheduledWeekday
                          : null,
                      scheduledDayOfMonth: frequency == IncomeFrequency.monthly
                          ? scheduledDayOfMonth
                          : null,
                    );
                  } else {
                    await controller.updateIncome(
                      incomeId: income.id,
                      currencyCode: currencyCode,
                      title: title.text,
                      amount: parseMoney(amount.text),
                      frequency: frequency,
                      startDate: startDate,
                      note: note.text,
                      scheduleTrackingEnabled: scheduleTrackingEnabled,
                      scheduledWeekday: frequency == IncomeFrequency.weekly
                          ? scheduledWeekday
                          : null,
                      scheduledDayOfMonth: frequency == IncomeFrequency.monthly
                          ? scheduledDayOfMonth
                          : null,
                    );
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      );
    } finally {
      await Future<void>.delayed(kThemeAnimationDuration);
      title.dispose();
      amount.dispose();
      note.dispose();
    }
  }

  static String _weekdayName(int weekday) => switch (weekday) {
        DateTime.monday => 'Pazartesi',
        DateTime.tuesday => 'Salı',
        DateTime.wednesday => 'Çarşamba',
        DateTime.thursday => 'Perşembe',
        DateTime.friday => 'Cuma',
        DateTime.saturday => 'Cumartesi',
        DateTime.sunday => 'Pazar',
        _ => 'Gün',
      };

  String _incomeSubtitle(IncomeEntry income, DateTime reference) {
    final lines = <String>[
      '${income.frequency.label} · ${money(income.amount, currencyCode: income.currencyCode)} · Başlangıç ${shortDate(income.startDate)}',
    ];
    if (income.scheduleTrackingEnabled && income.supportsScheduleTracking) {
      final schedule = income.frequency == IncomeFrequency.weekly
          ? 'Her ${_weekdayName(income.effectiveScheduledWeekday)}'
          : 'Her ayın ${income.effectiveScheduledDayOfMonth}. günü';
      final days = income.daysUntilTrackedOccurrence(reference);
      final subject =
          income.title.toLowerCase().contains('maaş') ? 'Maaş' : 'Gelir';
      final status = days == null
          ? ''
          : days < 0
              ? '$subject ${-days} gün gecikti'
              : days == 0
                  ? '$subject bugün bekleniyor'
                  : '$subject için $days gün kaldı';
      lines.add(status.isEmpty ? schedule : '$schedule · $status');
      final latest = income.latestReceipt;
      if (latest != null) {
        lines.add(
          'Son alındı: ${shortDate(latest.receivedDate)} · Planlanan ${shortDate(latest.scheduledDate)}',
        );
      }
    }
    if (income.isArchived) lines.add('Arşivde');
    return lines.join('\n');
  }

  Future<void> _markIncomeReceived(
    BuildContext context,
    IncomeEntry income,
  ) async {
    final today = dateOnly(DateTime.now());
    final scheduledDate = income.trackedOccurrenceAt(today);
    if (scheduledDate == null) return;
    final receivedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: income.effectiveTrackingStart,
      lastDate: DateTime(2100),
      helpText: 'Gelirin gerçekten alındığı tarihi seçin',
    );
    if (receivedDate == null) return;
    await controller.markIncomeReceived(
      incomeId: income.id,
      receivedAt: receivedDate,
      referenceDate: today,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Planlanan ${shortDate(scheduledDate)} dönemi, ${shortDate(receivedDate)} tarihinde alındı olarak kaydedildi. Sabit yatış günü değişmedi.',
        ),
      ),
    );
  }

  Future<void> _showDebtBreakdown(
    BuildContext context,
    MizanState state,
  ) async {
    final now = DateTime.now();
    final references = state.recordReferencesAt(now);
    final groups =
        <({String title, Map<String, double> amounts, RecordType? type})>[
      (
        title: 'Banka borçları',
        amounts: _dashboardRemainingByType(state, RecordType.debt),
        type: RecordType.debt,
      ),
      (
        title: 'Kişisel ve kurumsal borçlar',
        amounts: _dashboardRemainingByType(state, RecordType.personalDebt),
        type: RecordType.personalDebt,
      ),
      (
        title: 'Faturalar',
        amounts: _dashboardRemainingByType(state, RecordType.bill),
        type: RecordType.bill,
      ),
      (
        title: 'Abonelikler',
        amounts: _dashboardRemainingByType(state, RecordType.subscription),
        type: RecordType.subscription,
      ),
      (
        title: 'Kira ve taksitler',
        amounts: _dashboardRemainingByType(state, RecordType.rent),
        type: RecordType.rent,
      ),
      (
        title: 'Gecikmiş toplam',
        amounts: _dashboardRecordBuckets(
          references.where((item) => item.status == PaymentStatus.overdue),
        ),
        type: null,
      ),
      (
        title: 'Önümüzdeki 7 gün',
        amounts: _dashboardRecordBuckets(
          references.where((item) {
            final days = calendarDaysBetween(now, item.dueDate);
            return days >= 0 && days <= 7 && item.amount > 0;
          }),
        ),
        type: null,
      ),
    ];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kalan toplam borç detayı',
                style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Her bölümün toplamı ayrı hesaplanır. Satıra dokunarak yalnız ilgili kayıtları görebilirsin.',
                style: TextStyle(color: MizanTheme.muted),
              ),
              const SizedBox(height: 14),
              for (final group in groups) ...[
                MizanListCard(
                  title: group.title,
                  subtitle: moneyBuckets(group.amounts),
                  leadingColor: group.amounts.values.any((amount) => amount > 0)
                      ? MizanTheme.blue
                      : MizanTheme.muted,
                  icon: group.type == null
                      ? Icons.summarize_outlined
                      : _recordIcon(group.type!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final records = state.recordReferencesAt(now).where((item) {
                      if (group.type != null) {
                        return item.type == group.type;
                      }
                      if (group.title == 'Gecikmiş toplam') {
                        return item.status == PaymentStatus.overdue;
                      }
                      final days = calendarDaysBetween(now, item.dueDate);
                      return days >= 0 && days <= 7 && item.amount > 0;
                    }).toList(growable: false);
                    Navigator.pop(sheetContext);
                    await _showRecordList(
                      context,
                      title: group.title,
                      records: records,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMonthlyPaymentOverview(
    BuildContext context, {
    required List<RecordReference> openRecords,
    required List<ReportPaymentDetail> paymentDetails,
    required DateTime month,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: .86,
          minChildSize: .55,
          maxChildSize: .96,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Text(
                '${monthLabel(month)} Ödeme Durumu',
                style: Theme.of(
                  sheetContext,
                )
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Açık planlanan kayıtlar ile bu ay gerçekten yapılan ödemeler ayrı gösterilir.',
                style: TextStyle(color: MizanTheme.muted),
              ),
              const SizedBox(height: 18),
              SectionTitle(
                'Açık planlanan ödemeler',
                subtitle:
                    '${openRecords.length} açık kayıt · ${moneyBuckets(_dashboardRecordBuckets(openRecords))}',
              ),
              const SizedBox(height: 10),
              if (openRecords.isEmpty)
                const EmptyState(
                  title: 'Açık plan kalmadı',
                  message: 'Bu aya ait açık veya eksik ödeme bulunmuyor.',
                )
              else
                for (final record in openRecords) ...[
                  MizanListCard(
                    title: MizanI18n.user(record.title),
                    subtitle:
                        '${MizanI18n.user(record.subtitle)}\n${shortDate(record.dueDate)} · ${recordTimingLabel(record, DateTime.now())}',
                    icon: _recordIcon(record.type),
                    leadingColor: statusColor(record.status),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 112),
                      child: Text(
                        money(record.amount, currencyCode: record.currencyCode),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await showRecordDetails(
                        context: context,
                        controller: controller,
                        personId: record.personId,
                        type: record.type,
                        sourceId: record.sourceId,
                        bankId: record.bankId,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 18),
              SectionTitle(
                'Bu ay yapılan ödemeler',
                subtitle:
                    '${paymentDetails.length} ödeme · ${moneyBuckets(_dashboardPaymentBuckets(paymentDetails))}',
              ),
              const SizedBox(height: 10),
              if (paymentDetails.isEmpty)
                const EmptyState(
                  title: 'Yapılan ödeme yok',
                  message:
                      'Bu ay ödeme geçmişine kaydedilmiş işlem bulunmuyor.',
                )
              else
                for (final detail in paymentDetails) ...[
                  MizanListCard(
                    title:
                        '${MizanI18n.user(detail.personName)} · ${MizanI18n.user(detail.recordTitle)}',
                    subtitle:
                        '${detail.type.label} · ${MizanI18n.user(detail.recordSubtitle)}\n${shortDate(detail.payment.paidAt)} · ${detail.payment.entryType.label}',
                    icon: _recordIcon(detail.type),
                    leadingColor: MizanTheme.green,
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 112),
                      child: Text(
                        money(
                          detail.payment.amount,
                          currencyCode: detail.currencyCode,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await showRecordDetails(
                        context: context,
                        controller: controller,
                        personId: detail.personId,
                        type: detail.type,
                        sourceId: detail.recordId,
                        bankId: detail.bankId,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      );

  Future<void> _showRecordList(
    BuildContext context, {
    required String title,
    required List<RecordReference> records,
  }) {
    final sorted = [...records]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .78,
        minChildSize: .45,
        maxChildSize: .95,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Text(
              title,
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (sorted.isEmpty)
              const EmptyState(
                title: 'Kayıt bulunmuyor',
                message: 'Bu başlığa ait açık ödeme kaydı yok.',
              )
            else
              for (final record in sorted) ...[
                MizanListCard(
                  title: MizanI18n.user(record.title),
                  subtitle:
                      '${MizanI18n.user(record.subtitle)}\n${shortDate(record.dueDate)} · ${recordTimingLabel(record, DateTime.now())} · ${money(record.amount, currencyCode: record.currencyCode)}',
                  leadingColor: statusColor(record.status),
                  icon: _recordIcon(record.type),
                  trailing: StatusChip(status: record.status),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await showRecordDetails(
                      context: context,
                      controller: controller,
                      personId: record.personId,
                      type: record.type,
                      sourceId: record.sourceId,
                      bankId: record.bankId,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _IncomeOverviewCard extends StatelessWidget {
  const _IncomeOverviewCard({
    required this.hasIncome,
    required this.monthIncome,
    required this.afterPayments,
    required this.finalNet,
    required this.onManage,
  });

  final bool hasIncome;
  final Map<String, double> monthIncome;
  final Map<String, double> afterPayments;
  final Map<String, double> finalNet;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.trending_up_outlined,
                      color: MizanTheme.green),
                  Text(
                    'Gelir özeti',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  OutlinedButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(hasIncome ? 'Yönet' : 'Gelir ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!hasIncome)
                const Text(
                  'Gelir bilgisi belirtilmemiş',
                  style: TextStyle(
                    color: MizanTheme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else ...[
                _IncomeLine(
                    label: 'Bu ay gelir', value: moneyBuckets(monthIncome)),
                const SizedBox(height: 6),
                _IncomeLine(
                  label: 'Ödemeler sonrası kalan',
                  value: moneyBuckets(afterPayments),
                ),
                const SizedBox(height: 6),
                _IncomeLine(
                  label: 'Ödeme ve gider sonrası net',
                  value: moneyBuckets(finalNet),
                  emphasized: true,
                ),
              ],
            ],
          ),
        ),
      );
}

class _IncomeLine extends StatelessWidget {
  const _IncomeLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: emphasized ? MizanTheme.green : MizanTheme.ink,
              ),
            ),
          ),
        ],
      );
}

String _dueText(RecordReference record, DateTime now) =>
    recordTimingLabel(record, now);

IconData _recordIcon(RecordType type) => switch (type) {
      RecordType.debt => Icons.account_balance_outlined,
      RecordType.personalDebt => Icons.handshake_outlined,
      RecordType.bill => Icons.receipt_long_outlined,
      RecordType.subscription => Icons.autorenew_outlined,
      RecordType.rent => Icons.home_work_outlined,
    };
