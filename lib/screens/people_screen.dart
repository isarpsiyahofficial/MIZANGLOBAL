import '../core/mizan_clock.dart';
import '../core/localized_material.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/mizan_models.dart';
import '../widgets/mizan_cards.dart';
import '../widgets/record_notes_panel.dart';
import 'record_form_dialogs.dart';

enum _PersonMetricKind { remaining, monthly, overdue }

Map<String, double> _peopleCurrencyBuckets(
  Iterable<({String currencyCode, double amount})> items,
) {
  final result = <String, double>{};
  for (final item in items) {
    if (item.amount.abs() < 0.000001) continue;
    result[item.currencyCode] = (result[item.currencyCode] ?? 0) + item.amount;
  }
  return result;
}

Map<String, double> _personRemainingBuckets(PersonAccount person) {
  return _peopleCurrencyBuckets([
    for (final bank in person.banks)
      for (final item in bank.products.where((item) => !item.isArchived))
        (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.personalDebts.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.bills.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.subscriptions.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.rents.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
  ]);
}

Map<String, double> _personMonthlyBuckets(
  PersonAccount person,
  DateTime month,
) {
  return _peopleCurrencyBuckets([
    for (final bank in person.banks)
      for (final item in bank.products.where(
        (item) =>
            !item.isArchived &&
            item.remainingAmount > 0 &&
            item.isDueInMonth(month),
      ))
        (currencyCode: item.currencyCode, amount: item.scheduledPaymentAmount),
    for (final item in person.personalDebts.where(
      (item) =>
          !item.isArchived &&
          item.remainingAmount > 0 &&
          item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.effectiveDueAmount),
    for (final item in person.bills.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.amountForMonth(month)),
    for (final item in person.subscriptions.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.amount),
    for (final item in person.rents.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.plannedCycleAmount),
  ]);
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({required this.controller, super.key});

  final MizanController controller;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String? selectedPersonId;
  bool includeArchived = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final now = MizanClock.now();
    if (state.people.isNotEmpty &&
        !state.people.any((item) => item.id == selectedPersonId)) {
      selectedPersonId = state.people.first.id;
    }
    final selected = selectedPersonId == null
        ? null
        : state.people.where((item) => item.id == selectedPersonId).firstOrNull;
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 18.0;

    return ListView(
      key: const PageStorageKey('records'),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 110),
      children: [
        PageHeader(
          title: 'Kayıtlar',
          subtitle:
              'Önce kişiyi seç, ardından kayıt türünü aç. Her bölüm birbirinden bağımsız tutulur.',
          action: FilledButton.icon(
            onPressed: () =>
                showPersonForm(context: context, controller: widget.controller),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Kişi ekle'),
          ),
        ),
        const SizedBox(height: 18),
        if (state.people.isEmpty)
          EmptyState(
            title: 'Henüz kişi yok',
            message:
                'Kayıtların birbirine karışmaması için önce ödeme ve gider kayıtlarının sahibi olacak kişiyi ekleyin.',
            action: FilledButton.icon(
              onPressed: () => showPersonForm(
                context: context,
                controller: widget.controller,
              ),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('İlk kişiyi ekle'),
            ),
          )
        else ...[
          _PersonSelector(
            controller: widget.controller,
            people: state.people,
            selected: selected!,
            includeArchived: includeArchived,
            onPersonChanged: (value) =>
                setState(() => selectedPersonId = value),
            onArchivedChanged: (value) =>
                setState(() => includeArchived = value),
          ),
          const SizedBox(height: 16),
          _BankDebtGroup(
            controller: widget.controller,
            person: selected,
            includeArchived: includeArchived,
          ),
          const SizedBox(height: 12),
          _SimpleRecordGroup(
            title: 'Kişisel ve Kurumsal Borçlar',
            subtitle:
                'Kişi, şirket/kurum, çek, senet, esnaf/işletme, aile/yakın ve diğer alacaklılar',
            icon: Icons.handshake_outlined,
            totals: _peopleCurrencyBuckets(
              selected.personalDebts
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),
            count: selected.personalDebts.length,
            onAdd: () => showPersonalDebtForm(
              context: context,
              controller: widget.controller,
              person: selected,
            ),
            addLabel: 'Kişisel / kurumsal borç ekle',
            emptyMessage: 'Banka dışı borç kaydı bulunmuyor.',
            childrenBuilder: (_) => [
              for (final debt in selected.personalDebts.where(
                (item) => includeArchived || !item.isArchived,
              ))
                MizanListCard(
                  title: MizanI18n.user(debt.title),
                  subtitle:
                      '${debt.creditorType.label} · ${MizanI18n.user(debt.displayCreditor)}\nKalan ${money(debt.remainingAmount, currencyCode: debt.currencyCode)} · Vade ${shortDate(debt.effectiveDueDate)} · ${paymentTimingLabel(debt.statusAt(now), debt.effectiveDueDate, now)}',
                  leadingColor: statusColor(debt.status),
                  icon: _creditorIcon(debt.creditorType),
                  trailing: StatusChip(status: debt.status),
                  onTap: () => showRecordDetails(
                    context: context,
                    controller: widget.controller,
                    personId: selected.id,
                    type: RecordType.personalDebt,
                    sourceId: debt.id,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SimpleRecordGroup(
            title: RecordType.bill.groupLabel,
            subtitle:
                'Elektrik, su, telefon, internet, doğalgaz ve özel faturalar',
            icon: Icons.receipt_long_outlined,
            totals: _peopleCurrencyBuckets(
              selected.bills
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),
            count: selected.bills.length,
            onAdd: () => showBillForm(
              context: context,
              controller: widget.controller,
              person: selected,
            ),
            addLabel: 'Fatura ekle',
            emptyMessage: 'Fatura kaydı bulunmuyor.',
            childrenBuilder: (_) => [
              for (final bill in selected.bills.where(
                (item) => includeArchived || !item.isArchived,
              ))
                _BillSummaryCard(
                  bill: bill,
                  now: now,
                  onTap: () => showRecordDetails(
                    context: context,
                    controller: widget.controller,
                    personId: selected.id,
                    type: RecordType.bill,
                    sourceId: bill.id,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SimpleRecordGroup(
            title: RecordType.subscription.groupLabel,
            subtitle:
                'Belirli aralıklarla tekrarlayan dijital hizmet, üyelik, sigorta, eğitim ve bakım ödemeleri',
            icon: Icons.autorenew_outlined,
            totals: _peopleCurrencyBuckets(
              selected.subscriptions
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),
            count: selected.subscriptions.length,
            onAdd: () => showSubscriptionForm(
              context: context,
              controller: widget.controller,
              person: selected,
            ),
            addLabel: 'Abonelik ekle',
            emptyMessage: 'Abonelik kaydı bulunmuyor.',
            childrenBuilder: (_) => [
              for (final item in selected.subscriptions.where(
                (item) => includeArchived || !item.isArchived,
              ))
                MizanListCard(
                  title: MizanI18n.user(item.title),
                  subtitle:
                      '${MizanI18n.user(item.providerName)} · ${item.frequency.label}\nBu dönem ${money(item.remainingAmount, currencyCode: item.currencyCode)} · Sıradaki tarih ${shortDate(item.nextDueDate)} · ${paymentTimingLabel(item.statusAt(now), item.nextDueDate, now)}',
                  leadingColor: statusColor(item.status),
                  icon: Icons.autorenew_outlined,
                  trailing: StatusChip(status: item.status),
                  onTap: () => showRecordDetails(
                    context: context,
                    controller: widget.controller,
                    personId: selected.id,
                    type: RecordType.subscription,
                    sourceId: item.id,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SimpleRecordGroup(
            title: 'Kira ve Taksitler',
            subtitle:
                'Ev/iş yeri kirası, ürün taksiti ve düzenli ödeme planları',
            icon: Icons.home_work_outlined,
            totals: _peopleCurrencyBuckets(
              selected.rents
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),
            count: selected.rents.length,
            onAdd: () => showRentForm(
              context: context,
              controller: widget.controller,
              person: selected,
            ),
            addLabel: 'Kira / taksit ekle',
            emptyMessage: 'Kira veya taksit kaydı bulunmuyor.',
            childrenBuilder: (_) => [
              for (final rent in selected.rents.where(
                (item) => includeArchived || !item.isArchived,
              ))
                _RentSummaryCard(
                  rent: rent,
                  now: now,
                  onTap: () => showRecordDetails(
                    context: context,
                    controller: widget.controller,
                    personId: selected.id,
                    type: RecordType.rent,
                    sourceId: rent.id,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BillSummaryCard extends StatelessWidget {
  const _BillSummaryCard({
    required this.bill,
    required this.now,
    required this.onTap,
  });

  final BillEntry bill;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final due = bill.effectiveDueDateAt(now);
    final status = bill.statusAt(now);
    final currentDue = bill.dueAmountAt(now);
    final outstanding = bill.outstandingAmountAt(now);
    final schedule = bill.isMonthly
        ? 'Her ayın ${bill.paymentDay}. günü'
        : 'Tek dönem';
    return MizanListCard(
      title: '${bill.kind.label} · ${MizanI18n.user(bill.institutionName)}',
      subtitle:
          '$schedule · Bu dönem ${money(currentDue, currencyCode: bill.currencyCode)}\n'
          'Ödenmemiş toplam ${money(outstanding, currencyCode: bill.currencyCode)} · ${shortDate(due)} · ${paymentTimingLabel(status, due, now)}',
      leadingColor: statusColor(status),
      icon: Icons.receipt_long_outlined,
      trailing: StatusChip(status: status),
      onTap: onTap,
    );
  }
}

class _RentSummaryCard extends StatelessWidget {
  const _RentSummaryCard({
    required this.rent,
    required this.now,
    required this.onTap,
  });

  final RentEntry rent;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final due = rent.effectiveDueDateAt(now);
    final status = rent.statusAt(now);
    final currentDue = rent.dueAmountAt(now);
    final outstanding = rent.outstandingAmountAt(now);
    final schedule = rent.isMonthlySchedule
        ? 'Her ayın ${rent.paymentDay}. günü'
        : 'Tek ödeme';
    return MizanListCard(
      title: MizanI18n.user(rent.title),
      subtitle:
          '${rent.kind.label} · ${MizanI18n.user(rent.receiverName)}\n'
          '$schedule · Bu dönem ${money(currentDue, currencyCode: rent.currencyCode)} · Toplam ${money(outstanding, currencyCode: rent.currencyCode)}\n'
          '${shortDate(due)} · ${paymentTimingLabel(status, due, now)}',
      leadingColor: statusColor(status),
      icon: Icons.home_work_outlined,
      trailing: StatusChip(status: status),
      onTap: onTap,
    );
  }
}

class _PersonSelector extends StatelessWidget {
  const _PersonSelector({
    required this.controller,
    required this.people,
    required this.selected,
    required this.includeArchived,
    required this.onPersonChanged,
    required this.onArchivedChanged,
  });

  final MizanController controller;
  final List<PersonAccount> people;
  final PersonAccount selected;
  final bool includeArchived;
  final ValueChanged<String> onPersonChanged;
  final ValueChanged<bool> onArchivedChanged;

  @override
  Widget build(BuildContext context) {
    final now = MizanClock.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kayıt sahibi',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Aşağıdaki bütün kayıtlar yalnızca seçili kişiye aittir.',
              style: TextStyle(color: MizanTheme.muted),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selected.id,
              isExpanded: true,
              decoration: localizedInputDecoration(
                const InputDecoration(
                  labelText: 'Kişi seçin',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              items: [
                for (final person in people)
                  DropdownMenuItem(
                    value: person.id,
                    child: Text.user(person.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onPersonChanged(value);
              },
            ),
            const SizedBox(height: 12),
            AdaptiveGrid(
              minTileWidth: 170,
              children: [
                MetricCard(
                  label: 'Kalan toplam',
                  value: moneyBuckets(_personRemainingBuckets(selected)),
                  icon: Icons.account_balance_wallet_outlined,
                  note: 'Detayı gör',
                  onTap: () => _showPersonMetricDetails(
                    context: context,
                    controller: controller,
                    personId: selected.id,
                    kind: _PersonMetricKind.remaining,
                  ),
                ),
                MetricCard(
                  label: 'Bu ay planlanan',
                  value: moneyBuckets(_personMonthlyBuckets(selected, now)),
                  color: MizanTheme.blue,
                  icon: Icons.calendar_month_outlined,
                  note: 'Detayı gör',
                  onTap: () => _showPersonMetricDetails(
                    context: context,
                    controller: controller,
                    personId: selected.id,
                    kind: _PersonMetricKind.monthly,
                  ),
                ),
                MetricCard(
                  label: 'Gecikmiş kayıt',
                  value: selected.overdueCountAt(now).toString(),
                  color: MizanTheme.red,
                  icon: Icons.warning_amber_rounded,
                  note: 'Detayı gör',
                  onTap: () => _showPersonMetricDetails(
                    context: context,
                    controller: controller,
                    personId: selected.id,
                    kind: _PersonMetricKind.overdue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () => _showPersonDetails(
                context: context,
                controller: controller,
                personId: selected.id,
                includeArchived: includeArchived,
              ),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Kişi detaylarını aç'),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: includeArchived,
                label: const Text('Arşivdekileri göster'),
                onSelected: onArchivedChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPersonMetricDetails({
  required BuildContext context,
  required MizanController controller,
  required String personId,
  required _PersonMetricKind kind,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _PersonMetricDetailSheet(
      controller: controller,
      personId: personId,
      kind: kind,
    ),
  );
}

class _PersonMetricRow {
  const _PersonMetricRow({
    required this.type,
    required this.sourceId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currencyCode,
    required this.dueDate,
    required this.status,
    this.bankId,
  });

  final RecordType type;
  final String sourceId;
  final String? bankId;
  final String title;
  final String subtitle;
  final double amount;
  final String currencyCode;
  final DateTime dueDate;
  final PaymentStatus status;
}

class _PersonMetricDetailSheet extends StatelessWidget {
  const _PersonMetricDetailSheet({
    required this.controller,
    required this.personId,
    required this.kind,
  });

  final MizanController controller;
  final String personId;
  final _PersonMetricKind kind;

  List<_PersonMetricRow> _remainingRows(PersonAccount person, DateTime now) {
    final rows = <_PersonMetricRow>[];
    for (final bank in person.banks) {
      for (final product in bank.products) {
        if (product.isArchived || product.remainingAmount <= 0) continue;
        rows.add(
          _PersonMetricRow(
            type: RecordType.debt,
            sourceId: product.id,
            bankId: bank.id,
            title: product.title,
            subtitle:
                '${MizanI18n.user(bank.userWrittenName)} · ${product.displayKind}',
            amount: product.remainingAmount,
            currencyCode: product.currencyCode,
            dueDate: product.effectiveDueDateAt(now),
            status: product.statusAt(now),
          ),
        );
      }
    }
    for (final debt in person.personalDebts) {
      if (debt.isArchived || debt.remainingAmount <= 0) continue;
      rows.add(
        _PersonMetricRow(
          type: RecordType.personalDebt,
          sourceId: debt.id,
          title: MizanI18n.user(debt.title),
          subtitle:
              '${debt.creditorType.label} · ${MizanI18n.user(debt.displayCreditor)}',
          amount: debt.remainingAmount,
          currencyCode: debt.currencyCode,
          dueDate: debt.effectiveDueDate,
          status: debt.statusAt(now),
        ),
      );
    }
    for (final bill in person.bills) {
      if (bill.isArchived || bill.remainingAmount <= 0) continue;
      rows.add(
        _PersonMetricRow(
          type: RecordType.bill,
          sourceId: bill.id,
          title: '${bill.kind.label} · ${MizanI18n.user(bill.institutionName)}',
          subtitle: bill.subscriberNumber.trim().isEmpty
              ? MizanI18n.user(bill.institutionName)
              : 'Abone ${MizanI18n.user(bill.subscriberNumber.trim())}',
          amount: bill.remainingAmount,
          currencyCode: bill.currencyCode,
          dueDate: bill.effectiveDueDateAt(now),
          status: bill.statusAt(now),
        ),
      );
    }
    for (final subscription in person.subscriptions) {
      if (subscription.isArchived || subscription.remainingAmount <= 0) {
        continue;
      }
      rows.add(
        _PersonMetricRow(
          type: RecordType.subscription,
          sourceId: subscription.id,
          title: MizanI18n.user(subscription.title),
          subtitle:
              '${MizanI18n.user(subscription.providerName)} · ${subscription.displayKind}',
          amount: subscription.remainingAmount,
          currencyCode: subscription.currencyCode,
          dueDate: subscription.nextDueDate,
          status: subscription.statusAt(now),
        ),
      );
    }
    for (final rent in person.rents) {
      if (rent.isArchived || rent.remainingAmount <= 0) continue;
      rows.add(
        _PersonMetricRow(
          type: RecordType.rent,
          sourceId: rent.id,
          title: MizanI18n.user(rent.title),
          subtitle: '${rent.kind.label} · ${MizanI18n.user(rent.receiverName)}',
          amount: rent.remainingAmount,
          currencyCode: rent.currencyCode,
          dueDate: rent.effectiveDueDateAt(now),
          status: rent.statusAt(now),
        ),
      );
    }
    return rows;
  }

  List<_PersonMetricRow> _monthlyRows(PersonAccount person, DateTime month) {
    final rows = <_PersonMetricRow>[];
    for (final bank in person.banks) {
      for (final product in bank.products) {
        if (product.isArchived ||
            product.remainingAmount <= 0 ||
            !product.isDueInMonth(month)) {
          continue;
        }
        rows.add(
          _PersonMetricRow(
            type: RecordType.debt,
            sourceId: product.id,
            bankId: bank.id,
            title: product.title,
            subtitle:
                '${MizanI18n.user(bank.userWrittenName)} · ${product.displayKind}',
            amount: product.scheduledPaymentAmount,
            currencyCode: product.currencyCode,
            dueDate: product.dueMode == DebtDueMode.monthlyDay
                ? product.dueDateForMonth(month)
                : product.dueDate,
            status: product.statusAt(month),
          ),
        );
      }
    }
    for (final debt in person.personalDebts) {
      if (debt.isArchived ||
          debt.remainingAmount <= 0 ||
          !debt.isDueInMonth(month)) {
        continue;
      }
      rows.add(
        _PersonMetricRow(
          type: RecordType.personalDebt,
          sourceId: debt.id,
          title: MizanI18n.user(debt.title),
          subtitle:
              '${debt.creditorType.label} · ${MizanI18n.user(debt.displayCreditor)}',
          amount: debt.effectiveDueAmount,
          currencyCode: debt.currencyCode,
          dueDate: debt.effectiveDueDate,
          status: debt.statusAt(month),
        ),
      );
    }
    for (final bill in person.bills) {
      if (bill.isArchived || !bill.isDueInMonth(month)) continue;
      rows.add(
        _PersonMetricRow(
          type: RecordType.bill,
          sourceId: bill.id,
          title: '${bill.kind.label} · ${MizanI18n.user(bill.institutionName)}',
          subtitle: bill.isMonthly
              ? 'Her ayın ${bill.paymentDay ?? bill.dueDate.day}. günü'
              : 'Tek dönem',
          amount: bill.amountForMonth(month),
          currencyCode: bill.currencyCode,
          dueDate: bill.isMonthly ? bill.dueDateForMonth(month) : bill.dueDate,
          status: bill.statusAt(month),
        ),
      );
    }
    for (final subscription in person.subscriptions) {
      if (subscription.isArchived || !subscription.isDueInMonth(month)) {
        continue;
      }
      rows.add(
        _PersonMetricRow(
          type: RecordType.subscription,
          sourceId: subscription.id,
          title: MizanI18n.user(subscription.title),
          subtitle:
              '${MizanI18n.user(subscription.providerName)} · ${subscription.displayKind}',
          amount: subscription.amount,
          currencyCode: subscription.currencyCode,
          dueDate: subscription.nextDueDate,
          status: subscription.statusAt(month),
        ),
      );
    }
    for (final rent in person.rents) {
      if (rent.isArchived || !rent.isDueInMonth(month)) continue;
      rows.add(
        _PersonMetricRow(
          type: RecordType.rent,
          sourceId: rent.id,
          title: MizanI18n.user(rent.title),
          subtitle: '${rent.kind.label} · ${MizanI18n.user(rent.receiverName)}',
          amount: rent.plannedCycleAmount,
          currencyCode: rent.currencyCode,
          dueDate: rent.isMonthlySchedule
              ? rent.dueDateForMonth(month)
              : rent.dueDate,
          status: rent.statusAt(month),
        ),
      );
    }
    return rows;
  }

  List<_PersonMetricRow> _overdueRows(PersonAccount person, DateTime now) =>
      controller.state
          .recordReferencesAt(now)
          .where(
            (record) =>
                record.personId == person.id &&
                record.status == PaymentStatus.overdue,
          )
          .map(
            (record) => _PersonMetricRow(
              type: record.type,
              sourceId: record.sourceId,
              bankId: record.bankId,
              title: MizanI18n.user(record.title),
              subtitle: MizanI18n.user(record.subtitle),
              amount: record.amount,
              currencyCode: record.currencyCode,
              dueDate: record.dueDate,
              status: record.status,
            ),
          )
          .toList(growable: false);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final person = controller.state.people
          .where((item) => item.id == personId)
          .firstOrNull;
      if (person == null) {
        return const Center(child: Text('Kişi kaydı bulunamadı.'));
      }
      final now = MizanClock.now();
      final rows = switch (kind) {
        _PersonMetricKind.remaining => _remainingRows(person, now),
        _PersonMetricKind.monthly => _monthlyRows(person, now),
        _PersonMetricKind.overdue => _overdueRows(person, now),
      }..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final title = switch (kind) {
        _PersonMetricKind.remaining =>
          '${MizanI18n.user(person.name)} · Kalan toplam',
        _PersonMetricKind.monthly =>
          '${MizanI18n.user(person.name)} · Bu ay planlanan',
        _PersonMetricKind.overdue =>
          '${MizanI18n.user(person.name)} · Gecikmiş kayıtlar',
      };
      final totals = _peopleCurrencyBuckets(
        rows.map(
          (item) => (currencyCode: item.currencyCode, amount: item.amount),
        ),
      );
      final summary = switch (kind) {
        _PersonMetricKind.remaining => 'Toplam ${moneyBuckets(totals)}',
        _PersonMetricKind.monthly =>
          '${monthLabel(now)} planı · Toplam ${moneyBuckets(totals)}',
        _PersonMetricKind.overdue =>
          '${rows.length} gecikmiş kayıt · Açık dönem toplamı ${moneyBuckets(totals)}',
      };

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
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    summary,
                    style: const TextStyle(
                      color: MizanTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (kind == _PersonMetricKind.overdue) ...[
                    const SizedBox(height: 5),
                    Text(
                      mizanCalculationWarning,
                      style: TextStyle(color: MizanTheme.muted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: rows.isEmpty
                  ? const Center(
                      child: Text(
                        'Bu başlıkta kayıt bulunmuyor.',
                        style: TextStyle(color: MizanTheme.muted),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return MizanListCard(
                          title: '${row.type.label} · ${row.title}',
                          subtitle:
                              '${row.subtitle}\n${shortDate(row.dueDate)} · ${paymentTimingLabel(row.status, row.dueDate, now)}',
                          icon: _recordTypeIcon(row.type),
                          leadingColor: statusColor(row.status),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              money(row.amount, currencyCode: row.currencyCode),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          onTap: () => showRecordDetails(
                            context: context,
                            controller: controller,
                            personId: person.id,
                            type: row.type,
                            sourceId: row.sourceId,
                            bankId: row.bankId,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showPersonDetails({
  required BuildContext context,
  required MizanController controller,
  required String personId,
  required bool includeArchived,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .88,
      minChildSize: .58,
      maxChildSize: .96,
      builder: (_, scrollController) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final person = controller.state.people
              .where((item) => item.id == personId)
              .firstOrNull;
          if (person == null) {
            return const Center(child: Text('Kişi kaydı bulunamadı.'));
          }
          final now = MizanClock.now();
          final records =
              controller.state
                  .recordReferencesAt(now)
                  .where(
                    (item) =>
                        item.personId == person.id &&
                        (includeArchived ||
                            item.status != PaymentStatus.passive),
                  )
                  .toList(growable: false)
                ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          final summaries =
              <({String label, double amount, int count, IconData icon})>[
                (
                  label: RecordType.debt.groupLabel,
                  amount: person.banks.fold<double>(
                    0,
                    (sum, bank) => sum + bank.totalDebt,
                  ),
                  count: person.banks
                      .expand((bank) => bank.products)
                      .where((item) => includeArchived || !item.isArchived)
                      .length,
                  icon: Icons.account_balance_outlined,
                ),
                (
                  label: RecordType.personalDebt.groupLabel,
                  amount: person.personalDebts
                      .where((item) => !item.isArchived)
                      .fold<double>(
                        0,
                        (sum, item) => sum + item.remainingAmount,
                      ),
                  count: person.personalDebts
                      .where((item) => includeArchived || !item.isArchived)
                      .length,
                  icon: Icons.handshake_outlined,
                ),
                (
                  label: RecordType.bill.groupLabel,
                  amount: person.bills
                      .where((item) => !item.isArchived)
                      .fold<double>(
                        0,
                        (sum, item) => sum + item.remainingAmount,
                      ),
                  count: person.bills
                      .where((item) => includeArchived || !item.isArchived)
                      .length,
                  icon: Icons.receipt_long_outlined,
                ),
                (
                  label: RecordType.subscription.groupLabel,
                  amount: person.subscriptions
                      .where((item) => !item.isArchived)
                      .fold<double>(
                        0,
                        (sum, item) => sum + item.remainingAmount,
                      ),
                  count: person.subscriptions
                      .where((item) => includeArchived || !item.isArchived)
                      .length,
                  icon: Icons.autorenew_outlined,
                ),
                (
                  label: RecordType.rent.groupLabel,
                  amount: person.rents
                      .where((item) => !item.isArchived)
                      .fold<double>(
                        0,
                        (sum, item) => sum + item.remainingAmount,
                      ),
                  count: person.rents
                      .where((item) => includeArchived || !item.isArchived)
                      .length,
                  icon: Icons.home_work_outlined,
                ),
              ];
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(child: Icon(Icons.person_outline)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kişi detayları',
                          style: Theme.of(sheetContext).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text.user(
                          person.name,
                          style: const TextStyle(
                            color: MizanTheme.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                    tooltip: MizanI18n.text('Kapat'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final summary in summaries) ...[
                MizanListCard(
                  title: summary.label,
                  subtitle:
                      '${summary.count} kayıt · Kalan ${money(summary.amount)}',
                  leadingColor: MizanTheme.blue,
                  icon: summary.icon,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              SectionTitle(
                'Bu kişiye ait kayıtlar',
                subtitle:
                    '${records.length} kayıt · Toplam kalan ${money(person.totalDebt)}',
              ),
              const SizedBox(height: 10),
              if (records.isEmpty)
                const EmptyState(
                  title: 'Kayıt bulunmuyor',
                  message: 'Bu kişiye bağlı açık ödeme kaydı yok.',
                )
              else
                for (final record in records) ...[
                  MizanListCard(
                    title: MizanI18n.user(record.title),
                    subtitle:
                        '${record.type.label} · ${MizanI18n.user(record.subtitle)}\n${shortDate(record.dueDate)} · ${recordTimingLabel(record, MizanClock.now())} · Bu vade ${money(record.amount)}',
                    leadingColor: statusColor(record.status),
                    icon: _recordTypeIcon(record.type),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await showPersonForm(
                    context: context,
                    controller: controller,
                    person: person,
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Kişiyi düzenle'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: MizanTheme.red),
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await _confirmDeletePerson(context, controller, person);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Kişiyi sil'),
              ),
            ],
          );
        },
      ),
    ),
  );
}

IconData _recordTypeIcon(RecordType type) => switch (type) {
  RecordType.debt => Icons.account_balance_outlined,
  RecordType.personalDebt => Icons.handshake_outlined,
  RecordType.bill => Icons.receipt_long_outlined,
  RecordType.subscription => Icons.autorenew_outlined,
  RecordType.rent => Icons.home_work_outlined,
};

class _BankDebtGroup extends StatelessWidget {
  const _BankDebtGroup({
    required this.controller,
    required this.person,
    required this.includeArchived,
  });

  final MizanController controller;
  final PersonAccount person;
  final bool includeArchived;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        key: PageStorageKey('bank-debts-${person.id}'),
        initiallyExpanded: true,
        leading: const Icon(Icons.account_balance_outlined),
        title: const Text(
          'Banka Borçları',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${person.banks.length} banka grubu · Kalan ${moneyBuckets(_peopleCurrencyBuckets([for (final bank in person.banks)
            for (final item in bank.products.where((item) => !item.isArchived)) (currencyCode: item.currencyCode, amount: item.remainingAmount)]))}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => showBankForm(
                context: context,
                controller: controller,
                person: person,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Banka grubu ekle'),
            ),
          ),
          const SizedBox(height: 10),
          if (person.banks.isEmpty)
            const EmptyState(
              title: 'Banka borcu yok',
              message:
                  'Banka adı kullanıcı tarafından yazılır. Hazır banka markası veya logosu kullanılmaz.',
            )
          else
            for (final bank in person.banks) ...[
              _BankCard(
                controller: controller,
                person: person,
                bank: bank,
                includeArchived: includeArchived,
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _BankCard extends StatefulWidget {
  const _BankCard({
    required this.controller,
    required this.person,
    required this.bank,
    required this.includeArchived,
  });

  final MizanController controller;
  final PersonAccount person;
  final BankGroup bank;
  final bool includeArchived;

  @override
  State<_BankCard> createState() => _BankCardState();
}

class _BankCardState extends State<_BankCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final now = MizanClock.now();
    final products = widget.bank.products
        .where((item) => widget.includeArchived || !item.isArchived)
        .toList(growable: false);
    return Material(
      color: MizanTheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('bank-${widget.bank.id}'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => setState(() => expanded = value),
        title: Text.user(
          widget.bank.userWrittenName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${widget.bank.products.length} kayıt · Kalan ${moneyBuckets(_peopleCurrencyBuckets(widget.bank.products.where((item) => !item.isArchived).map((item) => (currencyCode: item.currencyCode, amount: item.remainingAmount))))}',
        ),
        trailing: PopupMenuButton<String>(
          tooltip: MizanI18n.text('Banka grubu işlemleri'),
          onSelected: (value) async {
            if (value == 'add') {
              await showDebtForm(
                context: context,
                controller: widget.controller,
                person: widget.person,
                bank: widget.bank,
              );
            } else if (value == 'edit') {
              await showBankForm(
                context: context,
                controller: widget.controller,
                person: widget.person,
                bank: widget.bank,
              );
            } else if (value == 'delete') {
              await _confirmAction(
                context,
                title: 'Banka grubunu sil',
                message:
                    '${MizanI18n.user(widget.bank.userWrittenName)} ve altındaki tüm borç kayıtları silinecek.',
                confirmLabel: 'Grubu sil',
                action: () => widget.controller.deleteBankGroup(
                  personId: widget.person.id,
                  bankId: widget.bank.id,
                ),
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'add', child: Text('Borç ekle')),
            PopupMenuItem(value: 'edit', child: Text('Grubu düzenle')),
            PopupMenuItem(value: 'delete', child: Text('Grubu sil')),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: expanded
            ? [
                if (products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Bu banka grubunda görüntülenecek borç bulunmuyor.',
                      style: TextStyle(color: MizanTheme.muted),
                    ),
                  )
                else
                  for (final debt in products) ...[
                    MizanListCard(
                      title: MizanI18n.user(debt.title),
                      subtitle:
                          '${debt.displayKind} · Kalan ${money(debt.remainingAmount, currencyCode: debt.currencyCode)}\nSıradaki ${shortDate(debt.effectiveDueDateAt(now))} · ${debt.overdueDaysAt(now) > 0 ? '${debt.overdueDaysAt(now)} gün gecikmede' : paymentTimingLabel(debt.statusAt(now), debt.effectiveDueDateAt(now), now)}',
                      leadingColor: statusColor(debt.status),
                      icon: Icons.credit_card_outlined,
                      trailing: StatusChip(status: debt.status),
                      onTap: () => showRecordDetails(
                        context: context,
                        controller: widget.controller,
                        personId: widget.person.id,
                        type: RecordType.debt,
                        sourceId: debt.id,
                        bankId: widget.bank.id,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
              ]
            : const [],
      ),
    );
  }
}

class _SimpleRecordGroup extends StatefulWidget {
  const _SimpleRecordGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.totals,
    required this.count,
    required this.onAdd,
    required this.addLabel,
    required this.emptyMessage,
    required this.childrenBuilder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Map<String, double> totals;
  final int count;
  final VoidCallback onAdd;
  final String addLabel;
  final String emptyMessage;
  final List<Widget> Function(BuildContext context) childrenBuilder;

  @override
  State<_SimpleRecordGroup> createState() => _SimpleRecordGroupState();
}

class _SimpleRecordGroupState extends State<_SimpleRecordGroup> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final children = expanded
        ? widget.childrenBuilder(context)
        : const <Widget>[];
    return Card(
      child: ExpansionTile(
        key: PageStorageKey(widget.title),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => setState(() => expanded = value),
        leading: Icon(widget.icon),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${widget.count} kayıt · Kalan ${moneyBuckets(widget.totals)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: expanded
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.subtitle,
                    style: const TextStyle(color: MizanTheme.muted),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: widget.onAdd,
                    icon: const Icon(Icons.add),
                    label: Text(widget.addLabel),
                  ),
                ),
                const SizedBox(height: 10),
                if (children.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(14),
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

Future<void> showRecordDetails({
  required BuildContext context,
  required MizanController controller,
  required String personId,
  required RecordType type,
  required String sourceId,
  String? bankId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecordDetailSheet(
      controller: controller,
      personId: personId,
      type: type,
      sourceId: sourceId,
      bankId: bankId,
    ),
  );
}

class _RecordDetailSheet extends StatelessWidget {
  const _RecordDetailSheet({
    required this.controller,
    required this.personId,
    required this.type,
    required this.sourceId,
    this.bankId,
  });

  final MizanController controller;
  final String personId;
  final RecordType type;
  final String sourceId;
  final String? bankId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = _detailData(
          controller,
          personId,
          type,
          sourceId,
          bankId,
        );
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .82,
          minChildSize: .55,
          maxChildSize: .96,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.user(
                          current.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          current.subtitle,
                          style: const TextStyle(color: MizanTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: current.status),
                ],
              ),
              const SizedBox(height: 14),
              AdaptiveGrid(
                minTileWidth: 150,
                children: [
                  MetricCard(
                    label: current.amountLabel,
                    value: money(
                      current.remainingAmount,
                      currencyCode: current.currencyCode,
                    ),
                    color: statusColor(current.status),
                  ),
                  MetricCard(
                    label: 'Son ödeme tarihi',
                    value: shortDate(current.dueDate),
                    color: MizanTheme.blue,
                  ),
                  MetricCard(
                    label: 'Toplam ödeme',
                    value: money(
                      current.paidAmount,
                      currencyCode: current.currencyCode,
                    ),
                    color: MizanTheme.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (current.status == PaymentStatus.overdue ||
                  current.status == PaymentStatus.upcoming) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: current.status == PaymentStatus.overdue
                        ? MizanTheme.red.withValues(alpha: .08)
                        : MizanTheme.orange.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.overdueDays > 0
                            ? '${current.overdueDays} gün gecikmede'
                            : paymentTimingLabel(
                                current.status,
                                current.dueDate,
                                MizanClock.now(),
                              ),
                        style: TextStyle(
                          color: current.status == PaymentStatus.overdue
                              ? MizanTheme.red
                              : MizanTheme.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mizanCalculationWarning,
                        style: TextStyle(
                          color: MizanTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: current.remainingAmount <= 0
                        ? null
                        : () => showPaymentForm(
                            context: context,
                            controller: controller,
                            personId: personId,
                            type: type,
                            sourceId: sourceId,
                            remainingAmount: current.remainingAmount,
                            suggestedInstallmentAmount:
                                current.scheduledPaymentAmount,
                            allowInstallmentPayment:
                                current.allowInstallmentPayment,
                            currencyCode: current.currencyCode,
                          ),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Ödeme ekle'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => current.edit(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Düzenle'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => current.setArchived(!current.isArchived),
                    icon: Icon(
                      current.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                    ),
                    label: Text(
                      current.isArchived ? 'Arşivden çıkar' : 'Arşivle',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteRecord(context, current),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Sil'),
                  ),
                ],
              ),
              if (current.description.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                _InformationCard(
                  title: 'Açıklama',
                  lines: [current.description],
                ),
              ],
              if (current.detailLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InformationCard(
                  title: 'Kayıt bilgileri',
                  lines: current.detailLines,
                ),
              ],
              if (current.schedule.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ScheduleCard(
                  items: current.schedule,
                  currencyCode: current.currencyCode,
                ),
              ],
              const SizedBox(height: 14),
              const SectionTitle(
                'Ödeme geçmişi',
                subtitle: 'Yalnızca bu kayda bağlı ödemeler',
              ),
              const SizedBox(height: 8),
              if (current.payments.isEmpty)
                const EmptyState(
                  title: 'Ödeme yok',
                  message: 'Bu kayda henüz ödeme eklenmedi.',
                )
              else
                for (final payment in current.payments) ...[
                  MizanListCard(
                    title: money(
                      payment.amount,
                      currencyCode: current.currencyCode,
                    ),
                    subtitle:
                        '${payment.entryType.label} · ${shortDate(payment.paidAt)}${payment.method.isEmpty ? '' : ' · ${MizanI18n.user(payment.method)}'}${payment.note.isEmpty ? '' : '\n${MizanI18n.user(payment.note)}'}',
                    leadingColor: MizanTheme.green,
                    icon: Icons.check_circle_outline,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await showPaymentForm(
                            context: context,
                            controller: controller,
                            personId: personId,
                            type: type,
                            sourceId: sourceId,
                            remainingAmount:
                                current.remainingAmount + payment.amount,
                            suggestedInstallmentAmount:
                                current.scheduledPaymentAmount,
                            allowInstallmentPayment:
                                current.allowInstallmentPayment,
                            currencyCode: current.currencyCode,
                            payment: payment,
                          );
                        } else if (value == 'delete') {
                          await _confirmAction(
                            context,
                            title: 'Ödemeyi sil',
                            message:
                                '${money(payment.amount, currencyCode: current.currencyCode)} tutarındaki ödeme yalnızca bu kayıttan silinecek.',
                            confirmLabel: 'Ödemeyi sil',
                            action: () => controller.deletePayment(
                              personId: personId,
                              type: type,
                              sourceId: sourceId,
                              paymentId: payment.id,
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                        PopupMenuItem(value: 'delete', child: Text('Sil')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 10),
              RecordNotesPanel(
                notes: current.notes,
                onAddNote: (text) => controller.addNote(
                  personId: personId,
                  type: type,
                  sourceId: sourceId,
                  text: text,
                ),
                onDeleteNote: (noteId) => controller.deleteNote(
                  personId: personId,
                  type: type,
                  sourceId: sourceId,
                  noteId: noteId,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(line),
            ),
        ],
      ),
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.items, required this.currencyCode});

  final List<DueScheduleItem> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ödeme planı',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item.isCompleted
                    ? Icons.check_circle
                    : Icons.calendar_today_outlined,
                color: item.isCompleted ? MizanTheme.green : MizanTheme.blue,
              ),
              title: Text(item.label),
              subtitle: Text(shortDate(item.dueDate)),
              trailing: Text(
                money(item.amount, currencyCode: currencyCode),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    ),
  );
}

class _RecordDetailData {
  const _RecordDetailData({
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.currencyCode,
    required this.remainingAmount,
    required this.paidAmount,
    required this.scheduledPaymentAmount,
    required this.allowInstallmentPayment,
    required this.dueDate,
    required this.status,
    required this.overdueDays,
    required this.unpaidDueDates,
    required this.description,
    required this.detailLines,
    required this.schedule,
    required this.payments,
    required this.notes,
    required this.isArchived,
    required this.edit,
    required this.setArchived,
    required this.delete,
  });

  final String title;
  final String subtitle;
  final String amountLabel;
  final String currencyCode;
  final double remainingAmount;
  final double paidAmount;
  final double scheduledPaymentAmount;
  final bool allowInstallmentPayment;
  final DateTime dueDate;
  final PaymentStatus status;
  final int overdueDays;
  final List<DateTime> unpaidDueDates;
  final String description;
  final List<String> detailLines;
  final List<DueScheduleItem> schedule;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;
  final bool isArchived;
  final Future<void> Function(BuildContext context) edit;
  final Future<void> Function(bool archived) setArchived;
  final Future<void> Function() delete;
}

_RecordDetailData _detailData(
  MizanController controller,
  String personId,
  RecordType type,
  String sourceId,
  String? bankId,
) {
  final state = controller.state;
  final person = state.people.firstWhere((item) => item.id == personId);
  final now = MizanClock.now();
  switch (type) {
    case RecordType.debt:
      final bank = bankId == null
          ? person.banks.firstWhere(
              (item) => item.products.any((product) => product.id == sourceId),
            )
          : person.banks.firstWhere((item) => item.id == bankId);
      final debt = bank.products.firstWhere((item) => item.id == sourceId);
      return _RecordDetailData(
        title: MizanI18n.user(debt.title),
        subtitle:
            '${MizanI18n.user(person.name)} · ${MizanI18n.user(bank.userWrittenName)} · ${debt.displayKind}',
        amountLabel: 'Kalan borç',
        currencyCode: debt.currencyCode,
        remainingAmount: debt.remainingAmount,
        paidAmount: debt.paidAmount,
        scheduledPaymentAmount: debt.scheduledPaymentAmount,
        allowInstallmentPayment:
            debt.monthlyAmount > 0 || debt.installmentCount != null,
        dueDate: debt.effectiveDueDateAt(MizanClock.now()),
        status: debt.status,
        overdueDays: debt.overdueDaysAt(MizanClock.now()),
        unpaidDueDates: debt.unpaidDueDatesAt(MizanClock.now()),
        description: debt.description,
        detailLines: [
          if (debt.monthlyAmount > 0)
            'Aylık tutar: ${money(debt.monthlyAmount, currencyCode: debt.currencyCode)}',
          'Ödeme tarihi: ${debt.dueRuleLabel}',
          if (debt.overdueDaysAt(MizanClock.now()) > 0)
            'Gecikme: ${debt.overdueDaysAt(MizanClock.now())} gün',
          if (debt.dueMode == DebtDueMode.monthlyDay &&
              debt.unpaidDueDatesAt(MizanClock.now()).isNotEmpty)
            'Ödenmeyen aylar: ${debt.unpaidDueDatesAt(MizanClock.now()).map(monthLabel).join(', ')}',
          if (debt.installmentCount != null) ...[
            'Kalan taksit sayısı: ${debt.remainingInstallmentCount}',
          ],
          if (debt.limit != null)
            'Limit: ${money(debt.limit!, currencyCode: debt.currencyCode)}',
          if (debt.usedLimit != null)
            'Kullanılan limit: ${money(debt.usedLimit!, currencyCode: debt.currencyCode)}',
        ],
        schedule: const [],
        payments: debt.payments,
        notes: debt.notes,
        isArchived: debt.isArchived,
        edit: (context) => showDebtForm(
          context: context,
          controller: controller,
          person: person,
          bank: bank,
          debt: debt,
        ),
        setArchived: (archived) => controller.setDebtArchived(
          personId: person.id,
          bankId: bank.id,
          debtId: debt.id,
          archived: archived,
        ),
        delete: () => controller.deleteDebtProduct(
          personId: person.id,
          bankId: bank.id,
          debtId: debt.id,
        ),
      );
    case RecordType.personalDebt:
      final debt = person.personalDebts.firstWhere(
        (item) => item.id == sourceId,
      );
      return _RecordDetailData(
        title: MizanI18n.user(debt.title),
        subtitle:
            '${MizanI18n.user(person.name)} · ${debt.creditorType.label} · ${MizanI18n.user(debt.displayCreditor)}',
        amountLabel: 'Kalan borç',
        currencyCode: debt.currencyCode,
        remainingAmount: debt.remainingAmount,
        paidAmount: debt.paidAmount,
        scheduledPaymentAmount: debt.effectiveDueAmount,
        allowInstallmentPayment: debt.isInstallment || debt.schedule.isNotEmpty,
        dueDate: debt.effectiveDueDate,
        status: debt.status,
        overdueDays: debt.statusAt(MizanClock.now()) == PaymentStatus.overdue
            ? dateOnly(
                MizanClock.now(),
              ).difference(dateOnly(debt.effectiveDueDate)).inDays
            : 0,
        unpaidDueDates: const [],
        description: debt.description,
        detailLines: [
          'Borç tarihi: ${shortDate(debt.debtDate)}',
          'Ödeme sıklığı: ${debt.frequency.label}',
          if (debt.installmentCount != null) ...[
            'Kalan taksit sayısı: ${debt.remainingInstallmentCount}',
          ],
          if (debt.monthlyAmount > 0)
            'Düzenli ödeme: ${money(debt.monthlyAmount, currencyCode: debt.currencyCode)}',
          if (debt.chequeNumber.isNotEmpty) 'Çek no: ${debt.chequeNumber}',
          if (debt.issuerName.isNotEmpty) 'Düzenleyen: ${debt.issuerName}',
          if (debt.bankInfo.isNotEmpty) 'Banka bilgisi: ${debt.bankInfo}',
          if (debt.promissoryNoteNumber.isNotEmpty)
            'Senet no: ${debt.promissoryNoteNumber}',
          if (debt.documentCount != null)
            'Senet: ${debt.currentDocument ?? 1}/${debt.documentCount}',
        ],
        schedule: debt.resolvedSchedule,
        payments: debt.payments,
        notes: debt.notes,
        isArchived: debt.isArchived,
        edit: (context) => showPersonalDebtForm(
          context: context,
          controller: controller,
          person: person,
          debt: debt,
        ),
        setArchived: (archived) => controller.setPersonalDebtArchived(
          personId: person.id,
          debtId: debt.id,
          archived: archived,
        ),
        delete: () =>
            controller.deletePersonalDebt(personId: person.id, debtId: debt.id),
      );
    case RecordType.bill:
      final bill = person.bills.firstWhere((item) => item.id == sourceId);
      return _RecordDetailData(
        title: bill.kind.label,
        subtitle:
            '${MizanI18n.user(person.name)} · ${MizanI18n.user(bill.institutionName)}',
        amountLabel: 'Kalan fatura',
        currencyCode: bill.currencyCode,
        remainingAmount: bill.outstandingAmountAt(now),
        paidAmount: bill.paidAmount,
        scheduledPaymentAmount: bill.dueAmountAt(now),
        allowInstallmentPayment: false,
        dueDate: bill.effectiveDueDateAt(now),
        status: bill.statusAt(now),
        overdueDays: bill.overdueDaysAt(now),
        unpaidDueDates: bill.unpaidDueDatesAt(now),
        description: bill.description,
        detailLines: [
          'Fatura düzeni: ${bill.scheduleMode.label}',
          if (bill.isMonthly) ...[
            'Ödeme günü: Her ayın ${bill.paymentDay}. günü',
            'İlk fatura ayı: ${monthLabel(bill.firstScheduledDueDate)}',
            if (bill.periodAmounts.isNotEmpty)
              'Kayıtlı değişken tutarlar: ${bill.normalizedPeriodAmounts.length} ay',
          ],
          if (bill.subscriberNumber.isNotEmpty)
            'Abone no: ${bill.subscriberNumber}',
          if (bill.contractNumber.isNotEmpty)
            'Sözleşme / tesisat no: ${bill.contractNumber}',
        ],
        schedule: const [],
        payments: bill.payments,
        notes: bill.notes,
        isArchived: bill.isArchived,
        edit: (context) => showBillForm(
          context: context,
          controller: controller,
          person: person,
          bill: bill,
        ),
        setArchived: (archived) => controller.setBillArchived(
          personId: person.id,
          billId: bill.id,
          archived: archived,
        ),
        delete: () =>
            controller.deleteBill(personId: person.id, billId: bill.id),
      );
    case RecordType.subscription:
      final item = person.subscriptions.firstWhere(
        (item) => item.id == sourceId,
      );
      return _RecordDetailData(
        title: MizanI18n.user(item.title),
        subtitle:
            '${MizanI18n.user(person.name)} · ${MizanI18n.user(item.providerName)} · ${item.displayKind}',
        amountLabel: 'Bu dönem kalan',
        currencyCode: item.currencyCode,
        remainingAmount: item.remainingAmount,
        paidAmount: item.paidAmount,
        scheduledPaymentAmount: item.remainingAmount,
        allowInstallmentPayment: false,
        dueDate: item.nextDueDate,
        status: item.status,
        overdueDays: item.statusAt(MizanClock.now()) == PaymentStatus.overdue
            ? dateOnly(
                MizanClock.now(),
              ).difference(dateOnly(item.nextDueDate)).inDays
            : 0,
        unpaidDueDates: const [],
        description: item.description,
        detailLines: [
          'Tekrar sıklığı: ${item.frequency.label}',
          if (item.subscriberNumber.isNotEmpty)
            'Abone no: ${item.subscriberNumber}',
          if (item.contractNumber.isNotEmpty)
            'Sözleşme no: ${item.contractNumber}',
        ],
        schedule: const [],
        payments: item.payments,
        notes: item.notes,
        isArchived: item.isArchived,
        edit: (context) => showSubscriptionForm(
          context: context,
          controller: controller,
          person: person,
          subscription: item,
        ),
        setArchived: (archived) => controller.setSubscriptionArchived(
          personId: person.id,
          subscriptionId: item.id,
          archived: archived,
        ),
        delete: () => controller.deleteSubscription(
          personId: person.id,
          subscriptionId: item.id,
        ),
      );
    case RecordType.rent:
      final rent = person.rents.firstWhere((item) => item.id == sourceId);
      return _RecordDetailData(
        title: MizanI18n.user(rent.title),
        subtitle:
            '${MizanI18n.user(person.name)} · ${MizanI18n.user(rent.receiverName)}',
        amountLabel: 'Kalan tutar',
        currencyCode: rent.currencyCode,
        remainingAmount: rent.outstandingAmountAt(now),
        paidAmount: rent.paidAmount,
        scheduledPaymentAmount: rent.dueAmountAt(now),
        allowInstallmentPayment: rent.installmentCount != null,
        dueDate: rent.effectiveDueDateAt(now),
        status: rent.statusAt(now),
        overdueDays: rent.overdueDaysAt(now),
        unpaidDueDates: rent.unpaidDueDatesAt(now),
        description: rent.description,
        detailLines: [
          'Kayıt türü: ${rent.kind.label}',
          'Ödeme günü: ${rent.isMonthlySchedule ? 'Her ayın ${rent.paymentDay}. günü' : shortDate(rent.dueDate)}',
          if (rent.isMonthlySchedule)
            'İlk ödeme ayı: ${monthLabel(rent.firstScheduledDueDate)}',
          if (rent.iban.isNotEmpty) 'IBAN: ${rent.iban}',
          if (rent.installmentCount != null) ...[
            'Kalan taksit sayısı: ${rent.remainingInstallmentCount}',
          ],
          if (rent.contractStart != null)
            'Sözleşme başlangıcı: ${shortDate(rent.contractStart!)}',
          if (rent.contractEnd != null)
            'Sözleşme bitişi: ${shortDate(rent.contractEnd!)}',
        ],
        schedule: const [],
        payments: rent.payments,
        notes: rent.notes,
        isArchived: rent.isArchived,
        edit: (context) => showRentForm(
          context: context,
          controller: controller,
          person: person,
          rent: rent,
        ),
        setArchived: (archived) => controller.setRentArchived(
          personId: person.id,
          rentId: rent.id,
          archived: archived,
        ),
        delete: () =>
            controller.deleteRent(personId: person.id, rentId: rent.id),
      );
  }
}

Future<void> _confirmDeletePerson(
  BuildContext context,
  MizanController controller,
  PersonAccount person,
) => _confirmAction(
  context,
  title: 'Kişiyi sil',
  message:
      '${MizanI18n.user(person.name)} ve bu kişiye bağlı bütün kayıtlar silinecek. Bu işlem yalnız açık onayla yapılır.',
  confirmLabel: 'Kişiyi sil',
  action: () => controller.deletePerson(person.id),
);

Future<void> _confirmDeleteRecord(
  BuildContext context,
  _RecordDetailData data,
) async {
  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Kaydı sil'),
      content: Text(
        '${data.title} kaydı, kendi ödeme ve not geçmişiyle birlikte silinecek.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: MizanTheme.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Kaydı sil'),
        ),
      ],
    ),
  );
  if (accepted != true) {
    return;
  }
  if (context.mounted) {
    Navigator.pop(context);
  }
  await Future<void>.delayed(kThemeAnimationDuration);
  await data.delete();
}

Future<void> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function() action,
}) async {
  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: MizanTheme.red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (accepted == true) await action();
}

IconData _creditorIcon(CreditorType type) => switch (type) {
  CreditorType.person => Icons.person_outline,
  CreditorType.companyInstitution => Icons.business_outlined,
  CreditorType.cheque => Icons.payments_outlined,
  CreditorType.promissoryNote => Icons.description_outlined,
  CreditorType.merchantBusiness => Icons.storefront_outlined,
  CreditorType.familyRelative => Icons.family_restroom_outlined,
  CreditorType.other => Icons.category_outlined,
};

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
