import '../core/mizan_clock.dart';
import '../core/localized_material.dart';
import 'package:flutter/services.dart';

import '../controllers/mizan_controller.dart';
import '../core/formatters.dart';
import '../core/theme.dart';
import '../global/global_catalog.dart';
import '../models/mizan_models.dart';
import '../widgets/global_picker_dialog.dart';

Future<void> showPersonForm({
  required BuildContext context,
  required MizanController controller,
  PersonAccount? person,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PersonForm(controller: controller, person: person),
  );
}

Future<void> showBankForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  BankGroup? bank,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _BankForm(controller: controller, person: person, bank: bank),
  );
}

Future<void> showDebtForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  required BankGroup bank,
  DebtProduct? debt,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DebtForm(
      controller: controller,
      person: person,
      bank: bank,
      debt: debt,
    ),
  );
}

Future<void> showBillForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  BillEntry? bill,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _BillForm(controller: controller, person: person, bill: bill),
  );
}

Future<void> showPersonalDebtForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  PersonalDebtEntry? debt,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _PersonalDebtForm(controller: controller, person: person, debt: debt),
  );
}

Future<void> showSubscriptionForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  SubscriptionEntry? subscription,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SubscriptionForm(
      controller: controller,
      person: person,
      subscription: subscription,
    ),
  );
}

Future<void> showRentForm({
  required BuildContext context,
  required MizanController controller,
  required PersonAccount person,
  RentEntry? rent,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) =>
        _RentForm(controller: controller, person: person, rent: rent),
  );
}

Future<void> showPaymentForm({
  required BuildContext context,
  required MizanController controller,
  required String personId,
  required RecordType type,
  required String sourceId,
  required double remainingAmount,
  required String currencyCode,
  required double suggestedInstallmentAmount,
  required bool allowInstallmentPayment,
  PaymentRecord? payment,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PaymentForm(
      controller: controller,
      personId: personId,
      type: type,
      sourceId: sourceId,
      remainingAmount: remainingAmount,
      currencyCode: currencyCode,
      suggestedInstallmentAmount: suggestedInstallmentAmount,
      allowInstallmentPayment: allowInstallmentPayment,
      payment: payment,
    ),
  );
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: MediaQuery.sizeOf(context).height * .72,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: _withSpacing(children),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) {
              return;
            }
            try {
              await onSave();
              if (context.mounted) {
                Navigator.pop(context);
              }
            } on Object catch (error) {
              if (error is _DialogSaveCancelled) return;
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(_message(error))));
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

List<Widget> _withSpacing(List<Widget> children) {
  return [
    for (var i = 0; i < children.length; i++) ...[
      children[i],
      if (i != children.length - 1) const SizedBox(height: 12),
    ],
  ];
}

class _DialogSaveCancelled implements Exception {
  const _DialogSaveCancelled();
}

String _message(Object error) => MizanI18n.text(
  error
      .toString()
      .replaceFirst('Invalid argument(s): ', '')
      .replaceFirst('FormatException: ', '')
      .replaceFirst('Bad state: ', ''),
);

int? _basePaidInstallmentFromRemaining(
  String totalInput,
  String remainingInput, {
  required int recordedInstallmentPayments,
}) {
  final total = parseOptionalPositiveInt(
    totalInput,
    fieldName: 'Toplam taksit',
  );
  final remaining = parseOptionalNonNegativeInt(
    remainingInput,
    fieldName: 'Kalan taksit sayısı',
  );
  if (total == null || remaining == null) return null;
  if (remaining > total) {
    throw const FormatException(
      'Kalan taksit sayısı toplam taksit sayısını aşamaz.',
    );
  }
  final base = total - remaining - recordedInstallmentPayments;
  if (base < 0) {
    throw const FormatException(
      'Kalan taksit sayısı, kayıtlı taksit ödemeleriyle uyumlu değil.',
    );
  }
  return base;
}

String? _required(String? value, String label) =>
    value == null || value.trim().isEmpty ? '$label boş bırakılamaz.' : null;

String? _moneyValidator(String? value, String label, {bool allowZero = false}) {
  try {
    final parsed = parseMoney(value ?? '');
    if (allowZero ? parsed < 0 : parsed <= 0) {
      return '$label geçersiz.';
    }
    return null;
  } on FormatException catch (error) {
    return error.message;
  }
}

class _PersonForm extends StatefulWidget {
  const _PersonForm({required this.controller, this.person});
  final MizanController controller;
  final PersonAccount? person;
  @override
  State<_PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<_PersonForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.person?.name ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      title: widget.person == null ? 'Kişi ekle' : 'Kişiyi düzenle',
      formKey: key,
      children: [
        TextFormField(
          controller: name,
          maxLength: 80,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Kişi adı'),
          ),
          validator: (value) => _required(value, 'Kişi adı'),
        ),
      ],
      onSave: () => widget.person == null
          ? widget.controller.addPerson(name.text)
          : widget.controller.updatePerson(
              personId: widget.person!.id,
              name: name.text,
            ),
    );
  }
}

class _BankForm extends StatefulWidget {
  const _BankForm({required this.controller, required this.person, this.bank});
  final MizanController controller;
  final PersonAccount person;
  final BankGroup? bank;
  @override
  State<_BankForm> createState() => _BankFormState();
}

class _BankFormState extends State<_BankForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.bank?.userWrittenName ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      title: widget.bank == null ? 'Banka grubu ekle' : 'Banka grubunu düzenle',
      formKey: key,
      children: [
        TextFormField(
          controller: name,
          maxLength: 100,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: localizedInputDecoration(
            const InputDecoration(
              labelText: 'Banka adı',
              helperText: 'Hazır marka listesi yoktur; adı kullanıcı belirler.',
              helperMaxLines: 4,
              counterText: '',
            ),
          ),
          validator: (value) => _required(value, 'Banka adı'),
        ),
      ],
      onSave: () => widget.bank == null
          ? widget.controller.addBankGroup(
              personId: widget.person.id,
              userWrittenName: name.text,
            )
          : widget.controller.updateBankGroup(
              personId: widget.person.id,
              bankId: widget.bank!.id,
              userWrittenName: name.text,
            ),
    );
  }
}

class _DebtForm extends StatefulWidget {
  const _DebtForm({
    required this.controller,
    required this.person,
    required this.bank,
    this.debt,
  });
  final MizanController controller;
  final PersonAccount person;
  final BankGroup bank;
  final DebtProduct? debt;
  @override
  State<_DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<_DebtForm> {
  final key = GlobalKey<FormState>();
  late String currencyCode;
  late final TextEditingController title,
      total,
      monthly,
      custom,
      installmentCount,
      currentInstallment,
      limit,
      usedLimit,
      dueDay,
      manualOverdueDays,
      description;
  late DebtKind kind;
  late DebtDueMode dueMode;
  late DateTime dueDate;
  late List<DateTime> manualOverduePeriods;
  late final int? initialManualOverdueDaysAtOpen;
  late bool manualOverdueEditing;

  @override
  void initState() {
    super.initState();
    final item = widget.debt;
    currencyCode =
        item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;
    kind = widget.controller.state.usesTurkeyDebtCatalog
        ? item?.kind ?? DebtKind.creditCard
        : DebtKind.custom;
    dueMode = item?.dueMode ?? DebtDueMode.fixedDate;
    dueDate =
        item?.dueDate ??
        dateOnly(MizanClock.now().add(const Duration(days: 7)));
    title = TextEditingController(text: item?.title ?? '');
    total = TextEditingController(
      text: item == null ? '' : decimalText(item.totalAmount),
    );
    monthly = TextEditingController(
      text: item == null ? '' : decimalText(item.monthlyAmount),
    );
    custom = TextEditingController(
      text: item == null
          ? ''
          : widget.controller.state.usesTurkeyDebtCatalog
          ? item.customKindName
          : item.displayKind,
    );
    installmentCount = TextEditingController(
      text: item?.installmentCount?.toString() ?? '',
    );
    currentInstallment = TextEditingController(
      text: item?.installmentCount == null
          ? ''
          : item!.remainingInstallmentCount.toString(),
    );
    limit = TextEditingController(
      text: item?.limit == null ? '' : decimalText(item!.limit!),
    );
    usedLimit = TextEditingController(
      text: item?.usedLimit == null ? '' : decimalText(item!.usedLimit!),
    );
    dueDay = TextEditingController(
      text: (item?.dueDayOfMonth ?? dueDate.day).toString(),
    );
    final hasManualOverdue = (item?.manualOverdueDays ?? 0) > 0;
    initialManualOverdueDaysAtOpen = hasManualOverdue
        ? item!.currentManualOverdueDaysAt(MizanClock.now())
        : null;
    manualOverdueEditing = item == null;
    manualOverdueDays = TextEditingController(
      text: initialManualOverdueDaysAtOpen?.toString() ?? '',
    );
    manualOverduePeriods = [...?item?.normalizedManualOverduePeriods];
    description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      title,
      total,
      monthly,
      custom,
      installmentCount,
      currentInstallment,
      limit,
      usedLimit,
      dueDay,
      manualOverdueDays,
      description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usesTurkeyDebtCatalog = widget.controller.state.usesTurkeyDebtCatalog;
    return _DialogShell(
      title: widget.debt == null ? 'Borç ürünü ekle' : 'Borç ürününü düzenle',
      formKey: key,
      children: [
        _RecordCurrencyField(
          currencyCode: currencyCode,
          onChanged: (value) => setState(() => currencyCode = value),
        ),
        if (usesTurkeyDebtCatalog)
          DropdownButtonFormField<DebtKind>(
            initialValue: kind,
            isExpanded: true,
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Borç türü'),
            ),
            items: [
              for (final item in DebtKind.values)
                DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) => setState(() => kind = value ?? kind),
          ),
        if (!usesTurkeyDebtCatalog || kind == DebtKind.custom)
          TextFormField(
            controller: custom,
            maxLength: 60,
            decoration: localizedInputDecoration(
              InputDecoration(
                labelText: usesTurkeyDebtCatalog
                    ? 'Özel borç türü'
                    : 'Borç türü',
              ),
            ),
            validator: (value) => _required(
              value,
              usesTurkeyDebtCatalog ? 'Özel borç türü' : 'Borç türü',
            ),
          ),
        TextFormField(
          controller: title,
          maxLength: 100,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Başlık'),
          ),
          validator: (v) => _required(v, 'Başlık'),
        ),
        _MoneyField(
          controller: total,
          currencyCode: currencyCode,
          label: 'Toplam borç',
          validator: (v) => _moneyValidator(v, 'Toplam borç'),
        ),
        _MoneyField(
          controller: monthly,
          currencyCode: currencyCode,
          label: 'Aylık tutar',
          validator: (v) => _moneyValidator(v, 'Aylık tutar', allowZero: true),
        ),
        DropdownButtonFormField<DebtDueMode>(
          initialValue: dueMode,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Ödeme tarihi yöntemi'),
          ),
          items: [
            for (final item in DebtDueMode.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => dueMode = value ?? dueMode),
        ),
        if (dueMode == DebtDueMode.fixedDate)
          _DateField(
            label: 'Son ödeme tarihi',
            value: dueDate,
            onChanged: (value) => setState(() => dueDate = value),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: dueDay,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: localizedInputDecoration(
                  const InputDecoration(
                    labelText: 'Her ayın kaçıncı günü?',
                    helperText: '1 ile 31 arasında bir gün girin.',
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final day = int.tryParse(value?.trim() ?? '');
                  if (day == null || day < 1 || day > 31) {
                    return 'Aylık ödeme günü 1 ile 31 arasında olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text(
                'İlk geçerli vade: ${shortDate(_nextMonthDateForPreview(int.tryParse(dueDay.text.trim()) ?? dueDate.day))}',
                style: const TextStyle(
                  color: MizanTheme.blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        if (dueMode == DebtDueMode.monthlyDay)
          _OverdueMonthSelector(
            months: manualOverduePeriods,
            dueDay: int.tryParse(dueDay.text.trim()) ?? dueDate.day,
            onAdd: () async {
              final picked = await _showMonthPickerDialog(
                context,
                initial: manualOverduePeriods.isEmpty
                    ? MizanClock.now()
                    : manualOverduePeriods.last,
              );
              if (picked == null || !mounted) return;
              final normalized = DateTime(picked.year, picked.month);
              if (manualOverduePeriods.any(
                (item) =>
                    item.year == normalized.year &&
                    item.month == normalized.month,
              )) {
                return;
              }
              setState(() {
                manualOverduePeriods = [...manualOverduePeriods, normalized]
                  ..sort();
              });
            },
            onRemove: (month) => setState(() {
              manualOverduePeriods = manualOverduePeriods
                  .where(
                    (item) =>
                        item.year != month.year || item.month != month.month,
                  )
                  .toList(growable: false);
            }),
          ),
        TextFormField(
          key: const Key('manual-overdue-days-field'),
          controller: manualOverdueDays,
          readOnly: widget.debt != null && !manualOverdueEditing,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: localizedInputDecoration(
            InputDecoration(
              labelText: widget.debt != null && !manualOverdueEditing
                  ? 'Güncel manuel gecikme günü'
                  : 'Yeni manuel gecikme günü (opsiyonel)',
              helperText: widget.debt != null && !manualOverdueEditing
                  ? 'Takvimle otomatik artar. Diğer alanları kaydetmek bu gecikme referansını değiştirmez.'
                  : null,
              suffixIcon: widget.debt == null
                  ? null
                  : IconButton(
                      tooltip: manualOverdueEditing
                          ? 'Gecikme düzenlemesi açık'
                          : 'Gecikme gününü değiştir',
                      onPressed: manualOverdueEditing
                          ? null
                          : () => setState(() {
                              manualOverdueEditing = true;
                              manualOverdueDays.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: manualOverdueDays.text.length,
                              );
                            }),
                      icon: const Icon(Icons.edit_calendar_outlined),
                    ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final days = int.tryParse(value.trim());
            if (days == null || days < 0 || days > 3650) {
              return 'Gecikme günü 0 ile 3650 arasında olmalıdır.';
            }
            return null;
          },
        ),
        if (widget.debt != null && !manualOverdueEditing)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                manualOverdueEditing = true;
                manualOverdueDays.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: manualOverdueDays.text.length,
                );
              }),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Gecikme gününü değiştir'),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.',
                ),
              ),
            ],
          ),
        ),
        _TwoColumn(
          left: TextFormField(
            controller: installmentCount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Toplam taksit'),
            ),
          ),
          right: TextFormField(
            controller: currentInstallment,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: localizedInputDecoration(
              const InputDecoration(
                labelText: 'Kalan taksit sayısı (opsiyonel)',
                helperText: 'Ödeme kaydı eklendikçe otomatik azalır.',
              ),
            ),
          ),
        ),
        _RemainingInstallmentPreview(
          totalController: installmentCount,
          paidController: currentInstallment,
        ),
        _TwoColumn(
          left: _MoneyField(
            controller: limit,
            currencyCode: currencyCode,
            label: 'Limit (opsiyonel)',
            requiredValue: false,
          ),
          right: _MoneyField(
            controller: usedLimit,
            currencyCode: currencyCode,
            label: 'Kullanılan limit',
            requiredValue: false,
          ),
        ),
        TextFormField(
          controller: description,
          maxLength: 240,
          minLines: 2,
          maxLines: 5,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Açıklama'),
          ),
        ),
      ],
      onSave: () async {
        final parsedManualOverdueDays = manualOverdueDays.text.trim().isEmpty
            ? null
            : int.parse(manualOverdueDays.text.trim());
        final replaceManualOverdueDays =
            widget.debt != null &&
            manualOverdueEditing &&
            parsedManualOverdueDays != initialManualOverdueDaysAtOpen;
        if (replaceManualOverdueDays) {
          final fromLabel = initialManualOverdueDaysAtOpen == null
              ? MizanI18n.text('Belirtilmemiş')
              : MizanI18n.text('$initialManualOverdueDaysAtOpen gün');
          final toLabel = parsedManualOverdueDays == null
              ? MizanI18n.text('Kaldırılacak')
              : MizanI18n.text('$parsedManualOverdueDays gün');
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Gecikme hesabını yeniden kur'),
              content: Text.user('$fromLabel → $toLabel'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Değişikliği onayla'),
                ),
              ],
            ),
          );
          if (confirmed != true) throw const _DialogSaveCancelled();
        }
        final args = (
          personId: widget.person.id,
          bankId: widget.bank.id,
          kind: kind,
          title: title.text,
          totalAmount: parseMoney(total.text),
          monthlyAmount: monthly.text.trim().isEmpty
              ? 0.0
              : parseMoney(monthly.text),
          dueDate: dueDate,
          dueMode: dueMode,
          dueDayOfMonth: dueMode == DebtDueMode.monthlyDay
              ? int.parse(dueDay.text.trim())
              : null,
          customKindName: custom.text,
          installmentCount: parseOptionalPositiveInt(
            installmentCount.text,
            fieldName: 'Toplam taksit',
          ),
          currentInstallment: _basePaidInstallmentFromRemaining(
            installmentCount.text,
            currentInstallment.text,
            recordedInstallmentPayments:
                widget.debt?.payments
                    .where(
                      (item) => item.entryType == PaymentEntryType.installment,
                    )
                    .length ??
                0,
          ),
          manualOverdueDays: parsedManualOverdueDays,
          limit: limit.text.trim().isEmpty ? null : parseMoney(limit.text),
          usedLimit: usedLimit.text.trim().isEmpty
              ? null
              : parseMoney(usedLimit.text),
          description: description.text,
        );
        if (widget.debt == null) {
          return widget.controller.addDebtProduct(
            personId: args.personId,
            currencyCode: currencyCode,
            bankId: args.bankId,
            kind: args.kind,
            title: args.title,
            totalAmount: args.totalAmount,
            monthlyAmount: args.monthlyAmount,
            dueDate: args.dueDate,
            dueMode: args.dueMode,
            dueDayOfMonth: args.dueDayOfMonth,
            customKindName: args.customKindName,
            installmentCount: args.installmentCount,
            currentInstallment: args.currentInstallment,
            manualOverdueDays: args.manualOverdueDays,
            manualOverduePeriods: dueMode == DebtDueMode.monthlyDay
                ? manualOverduePeriods
                : const [],
            limit: args.limit,
            usedLimit: args.usedLimit,
            description: args.description,
          );
        }
        return widget.controller.updateDebtProduct(
          personId: args.personId,
          currencyCode: currencyCode,
          bankId: args.bankId,
          debtId: widget.debt!.id,
          kind: args.kind,
          title: args.title,
          totalAmount: args.totalAmount,
          monthlyAmount: args.monthlyAmount,
          dueDate: args.dueDate,
          dueMode: args.dueMode,
          dueDayOfMonth: args.dueDayOfMonth,
          customKindName: args.customKindName,
          installmentCount: args.installmentCount,
          currentInstallment: args.currentInstallment,
          manualOverdueDays: args.manualOverdueDays,
          replaceManualOverdueDays: replaceManualOverdueDays,
          manualOverduePeriods: dueMode == DebtDueMode.monthlyDay
              ? manualOverduePeriods
              : const [],
          limit: args.limit,
          usedLimit: args.usedLimit,
          description: args.description,
        );
      },
    );
  }
}

DateTime _nextMonthDateForPreview(int day) {
  final now = MizanClock.now();
  final month = DateTime(now.year, now.month + 1);
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, day.clamp(1, lastDay).toInt());
}

class _OverdueMonthSelector extends StatelessWidget {
  const _OverdueMonthSelector({
    required this.months,
    required this.dueDay,
    required this.onAdd,
    required this.onRemove,
  });

  final List<DateTime> months;
  final int dueDay;
  final VoidCallback onAdd;
  final ValueChanged<DateTime> onRemove;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(MizanClock.now());
    final oldest = months.isEmpty
        ? null
        : DateTime(
            months.first.year,
            months.first.month,
            dueDay.clamp(
              1,
              DateTime(months.first.year, months.first.month + 1, 0).day,
            ),
          );
    final overdueDays = oldest == null || !oldest.isBefore(today)
        ? 0
        : today.difference(oldest).inDays;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Gecikmiş aylar (opsiyonel)',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ödenmeyen ayları seç. Gecikme, seçilen en eski ayın ödeme gününden bugüne otomatik hesaplanır.',
            style: TextStyle(color: MizanTheme.muted),
          ),
          if (months.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final month in months)
                  InputChip(
                    label: Text(monthLabel(month)),
                    onDeleted: () => onRemove(month),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$overdueDays gün gecikme · En eski vade ${shortDate(oldest!)}',
              style: const TextStyle(
                color: MizanTheme.red,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Gecikmiş ay ekle'),
          ),
        ],
      ),
    );
  }
}

Future<DateTime?> _showMonthPickerDialog(
  BuildContext context, {
  required DateTime initial,
}) {
  var selectedYear = initial.year;
  var selectedMonth = initial.month;
  final currentYear = MizanClock.now().year;
  final years = [
    for (var year = currentYear - 15; year <= currentYear + 1; year++) year,
  ];
  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Ay ve yıl seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedMonth,
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Ay'),
              ),
              items: [
                for (var month = 1; month <= 12; month++)
                  DropdownMenuItem(
                    value: month,
                    child: Text(
                      monthLabel(DateTime(2026, month)).split(' ').first,
                    ),
                  ),
              ],
              onChanged: (value) =>
                  setDialogState(() => selectedMonth = value ?? selectedMonth),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedYear,
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Yıl'),
              ),
              items: [
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text('$year')),
              ],
              onChanged: (value) =>
                  setDialogState(() => selectedYear = value ?? selectedYear),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              DateTime(selectedYear, selectedMonth),
            ),
            child: const Text('Seç'),
          ),
        ],
      ),
    ),
  );
}

DateTime _dueDateForMonthDay(DateTime month, int requestedDay) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(
    month.year,
    month.month,
    requestedDay.clamp(1, lastDay).toInt(),
  );
}

class _BillForm extends StatefulWidget {
  const _BillForm({required this.controller, required this.person, this.bill});
  final MizanController controller;
  final PersonAccount person;
  final BillEntry? bill;
  @override
  State<_BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<_BillForm> {
  final key = GlobalKey<FormState>();
  late String currencyCode;
  late BillKind kind;
  late BillScheduleMode scheduleMode;
  late DateTime dueDate;
  late DateTime firstMonth;
  late DateTime periodMonth;
  bool firstMonthManuallySelected = false;
  late final TextEditingController institution,
      amount,
      periodAmount,
      paymentDay,
      subscriber,
      contract,
      description;

  @override
  void initState() {
    super.initState();
    final item = widget.bill;
    currencyCode =
        item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;
    kind = item?.kind ?? BillKind.electricity;
    scheduleMode = item?.scheduleMode ?? BillScheduleMode.monthly;
    final now = MizanClock.now();
    dueDate = item?.dueDate ?? dateOnly(now.add(const Duration(days: 7)));
    final initialDay = item?.paymentDay ?? dueDate.day;
    final currentCandidate = _dueDateForMonthDay(now, initialDay);
    firstMonth = item == null && currentCandidate.isBefore(dateOnly(now))
        ? DateTime(now.year, now.month + 1)
        : DateTime(dueDate.year, dueDate.month);
    periodMonth = item?.periodAmounts.isNotEmpty == true
        ? DateTime(
            item!.periodAmounts.last.month.year,
            item.periodAmounts.last.month.month,
          )
        : firstMonth;
    institution = TextEditingController(text: item?.institutionName ?? '');
    amount = TextEditingController(
      text: item == null ? '' : decimalText(item.amount),
    );
    periodAmount = TextEditingController(
      text: item == null ? '' : decimalText(item.amountForMonth(periodMonth)),
    );
    paymentDay = TextEditingController(
      text: (item?.paymentDay ?? dueDate.day).toString(),
    );
    subscriber = TextEditingController(text: item?.subscriberNumber ?? '');
    contract = TextEditingController(text: item?.contractNumber ?? '');
    description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      institution,
      amount,
      periodAmount,
      paymentDay,
      subscriber,
      contract,
      description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMonth({required bool first}) async {
    final picked = await _showMonthPickerDialog(
      context,
      initial: first ? firstMonth : periodMonth,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (first) {
        firstMonth = picked;
        firstMonthManuallySelected = true;
        if (widget.bill == null) {
          periodMonth = picked;
        }
      } else {
        periodMonth = picked;
        final item = widget.bill;
        if (item != null) {
          periodAmount.text = decimalText(item.amountForMonth(picked));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthly = scheduleMode == BillScheduleMode.monthly;
    return _DialogShell(
      title: widget.bill == null ? 'Fatura ekle' : 'Faturayı düzenle',
      formKey: key,
      children: [
        _RecordCurrencyField(
          currencyCode: currencyCode,
          onChanged: (value) => setState(() => currencyCode = value),
        ),
        DropdownButtonFormField<BillKind>(
          initialValue: kind,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Fatura türü'),
          ),
          items: [
            for (final item in BillKind.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (v) => setState(() => kind = v ?? kind),
        ),
        DropdownButtonFormField<BillScheduleMode>(
          key: const ValueKey('bill-schedule-mode'),
          initialValue: scheduleMode,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Fatura düzeni'),
          ),
          items: [
            for (final item in BillScheduleMode.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (v) => setState(() => scheduleMode = v ?? scheduleMode),
        ),
        TextFormField(
          controller: institution,
          maxLength: 100,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Kurum adı'),
          ),
          validator: (v) => _required(v, 'Kurum adı'),
        ),
        _MoneyField(
          controller: amount,
          currencyCode: currencyCode,
          label: monthly ? 'Varsayılan aylık tutar' : 'Fatura tutarı',
          validator: (v) => _moneyValidator(v, 'Fatura tutarı'),
        ),
        if (monthly) ...[
          TextFormField(
            key: const ValueKey('bill-payment-day'),
            controller: paymentDay,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: localizedInputDecoration(
              const InputDecoration(
                labelText: 'Her ayın kaçında ödenecek? (1-31)',
                helperText:
                    '29, 30 veya 31 seçildiğinde kısa aylarda ayın son geçerli günü kullanılır.',
              ),
            ),
            validator: (value) {
              final day = int.tryParse(value ?? '');
              return day == null || day < 1 || day > 31
                  ? '1 ile 31 arasında bir gün girin.'
                  : null;
            },
          ),
          _MonthChoiceField(
            label: 'İlk fatura ayı',
            value: firstMonth,
            onTap: () => _pickMonth(first: true),
          ),
          _MonthChoiceField(
            label: 'Girilen tutarın ait olduğu ay',
            value: periodMonth,
            onTap: () => _pickMonth(first: false),
          ),
          _MoneyField(
            key: const ValueKey('bill-period-amount'),
            controller: periodAmount,
            currencyCode: currencyCode,
            label: '${monthLabel(periodMonth)} gerçek fatura tutarı',
            validator: (v) => _moneyValidator(v, 'Dönem fatura tutarı'),
          ),
          const _FormInfoBox(
            text:
                'Elektrik, su, doğalgaz ve benzeri faturaların tutarı her ay ayrı kaydedilir. Geçmiş ayların tutarı değiştirilmeden raporlarda gerçek ödeme kayıtları kullanılır.',
          ),
        ] else
          _DateField(
            label: 'Son ödeme tarihi',
            value: dueDate,
            onChanged: (v) => setState(() => dueDate = v),
          ),
        TextFormField(
          controller: subscriber,
          maxLength: 60,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Abone numarası'),
          ),
        ),
        TextFormField(
          controller: contract,
          maxLength: 60,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Tesisat / sözleşme numarası'),
          ),
        ),
        TextFormField(
          controller: description,
          maxLength: 240,
          minLines: 2,
          maxLines: 5,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Açıklama'),
          ),
        ),
      ],
      onSave: () {
        final day = monthly ? int.parse(paymentDay.text) : dueDate.day;
        var effectiveMonth = firstMonth;
        if (monthly &&
            widget.bill == null &&
            !firstMonthManuallySelected &&
            _dueDateForMonthDay(
              effectiveMonth,
              day,
            ).isBefore(dateOnly(MizanClock.now()))) {
          effectiveMonth = DateTime(
            effectiveMonth.year,
            effectiveMonth.month + 1,
          );
        }
        final effectiveDue = monthly
            ? _dueDateForMonthDay(effectiveMonth, day)
            : dueDate;
        return widget.bill == null
            ? widget.controller.addBill(
                personId: widget.person.id,
                currencyCode: currencyCode,
                kind: kind,
                institutionName: institution.text,
                amount: parseMoney(amount.text),
                dueDate: effectiveDue,
                scheduleMode: scheduleMode,
                paymentDay: monthly ? day : null,
                periodMonth: monthly ? periodMonth : null,
                periodAmount: monthly ? parseMoney(periodAmount.text) : null,
                subscriberNumber: subscriber.text,
                contractNumber: contract.text,
                description: description.text,
              )
            : widget.controller.updateBill(
                personId: widget.person.id,
                currencyCode: currencyCode,
                billId: widget.bill!.id,
                kind: kind,
                institutionName: institution.text,
                amount: parseMoney(amount.text),
                dueDate: effectiveDue,
                scheduleMode: scheduleMode,
                paymentDay: monthly ? day : null,
                periodMonth: monthly ? periodMonth : null,
                periodAmount: monthly ? parseMoney(periodAmount.text) : null,
                subscriberNumber: subscriber.text,
                contractNumber: contract.text,
                description: description.text,
              );
      },
    );
  }
}

class _RentForm extends StatefulWidget {
  const _RentForm({required this.controller, required this.person, this.rent});
  final MizanController controller;
  final PersonAccount person;
  final RentEntry? rent;
  @override
  State<_RentForm> createState() => _RentFormState();
}

class _RentFormState extends State<_RentForm> {
  final key = GlobalKey<FormState>();
  late String currencyCode;
  late RentEntryKind kind;
  late DateTime firstPaymentMonth;
  late bool recurringMonthly;
  bool firstMonthManuallySelected = false;
  DateTime? contractStart, contractEnd, increaseDate;
  late final TextEditingController title,
      amount,
      paymentDay,
      receiver,
      iban,
      installmentCount,
      currentInstallment,
      description;

  @override
  void initState() {
    super.initState();
    final i = widget.rent;
    currencyCode =
        i?.currencyCode ?? widget.controller.state.defaultCurrencyCode;
    kind = i?.kind ?? RentEntryKind.homeRent;
    recurringMonthly = i?.recurringMonthly ?? true;
    final now = MizanClock.now();
    final due = i?.dueDate ?? now;
    final initialDay = i?.paymentDay ?? 15;
    final currentCandidate = _dueDateForMonthDay(now, initialDay);
    firstPaymentMonth = i == null && currentCandidate.isBefore(dateOnly(now))
        ? DateTime(now.year, now.month + 1)
        : DateTime(due.year, due.month);
    contractStart = i?.contractStart;
    contractEnd = i?.contractEnd;
    increaseDate = i?.increaseDate;
    title = TextEditingController(text: i?.title ?? '');
    amount = TextEditingController(
      text: i == null ? '' : decimalText(i.amount),
    );
    paymentDay = TextEditingController(text: i?.paymentDay.toString() ?? '15');
    receiver = TextEditingController(text: i?.receiverName ?? '');
    iban = TextEditingController(text: i?.iban ?? '');
    installmentCount = TextEditingController(
      text: i?.installmentCount?.toString() ?? '',
    );
    currentInstallment = TextEditingController(
      text: i?.installmentCount == null
          ? ''
          : i!.remainingInstallmentCount.toString(),
    );
    description = TextEditingController(text: i?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      title,
      amount,
      paymentDay,
      receiver,
      iban,
      installmentCount,
      currentInstallment,
      description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFirstMonth() async {
    final picked = await _showMonthPickerDialog(
      context,
      initial: firstPaymentMonth,
    );
    if (picked != null && mounted) {
      setState(() {
        firstPaymentMonth = picked;
        firstMonthManuallySelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProduct = kind == RentEntryKind.productInstallment;
    final isHome = kind == RentEntryKind.homeRent;
    return _DialogShell(
      title: widget.rent == null
          ? 'Kira / taksit ekle'
          : 'Kira / taksiti düzenle',
      formKey: key,
      children: [
        _RecordCurrencyField(
          currencyCode: currencyCode,
          onChanged: (value) => setState(() => currencyCode = value),
        ),
        DropdownButtonFormField<RentEntryKind>(
          key: const ValueKey('rent-entry-kind'),
          initialValue: kind,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Kayıt türü'),
          ),
          items: [
            for (final item in RentEntryKind.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() {
            kind = value ?? kind;
            if (kind == RentEntryKind.homeRent) recurringMonthly = true;
            if (kind == RentEntryKind.productInstallment) {
              recurringMonthly = true;
            }
          }),
        ),
        TextFormField(
          controller: title,
          maxLength: 100,
          decoration: localizedInputDecoration(
            InputDecoration(
              labelText: isHome
                  ? 'Kira başlığı'
                  : isProduct
                  ? 'Ürün / taksit başlığı'
                  : 'Başlık',
            ),
          ),
          validator: (v) => _required(v, 'Başlık'),
        ),
        _MoneyField(
          controller: amount,
          currencyCode: currencyCode,
          label: isHome
              ? 'Aylık kira tutarı'
              : isProduct
              ? 'Toplam ürün bedeli'
              : recurringMonthly
              ? 'Aylık ödeme tutarı'
              : 'Toplam tutar',
          validator: (v) => _moneyValidator(v, 'Tutar'),
        ),
        if (kind == RentEntryKind.custom)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Her ay tekrarlayan ödeme'),
            subtitle: const Text(
              'Kapalıysa kayıt tek ödeme olarak değerlendirilir.',
            ),
            value: recurringMonthly,
            onChanged: (value) => setState(() => recurringMonthly = value),
          ),
        TextFormField(
          key: const ValueKey('rent-payment-day'),
          controller: paymentDay,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: localizedInputDecoration(
            const InputDecoration(
              labelText: 'Her ayın kaçında ödenecek? (1-31)',
              helperText:
                  '15 veya 20 gibi yalnız gün numarasını yazın; MİZAN takvimi kendisi takip eder.',
            ),
          ),
          validator: (v) {
            final n = int.tryParse(v ?? '');
            return n == null || n < 1 || n > 31
                ? '1 ile 31 arasında bir gün girin.'
                : null;
          },
        ),
        _MonthChoiceField(
          label: 'İlk ödeme ayı',
          value: firstPaymentMonth,
          onTap: _pickFirstMonth,
        ),
        TextFormField(
          controller: receiver,
          maxLength: 100,
          decoration: localizedInputDecoration(
            InputDecoration(
              labelText: isHome ? 'Ev sahibi / alıcı' : 'Alıcı / satıcı adı',
            ),
          ),
          validator: (v) => _required(v, 'Alıcı adı'),
        ),
        TextFormField(
          controller: iban,
          maxLength: 40,
          textCapitalization: TextCapitalization.characters,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'IBAN (opsiyonel)'),
          ),
        ),
        if (!isProduct) ...[
          _OptionalDateField(
            label: 'Sözleşme başlangıcı (opsiyonel)',
            value: contractStart,
            onChanged: (v) => setState(() => contractStart = v),
          ),
          _OptionalDateField(
            label: 'Sözleşme bitişi (opsiyonel)',
            value: contractEnd,
            onChanged: (v) => setState(() => contractEnd = v),
          ),
          if (isHome)
            _OptionalDateField(
              label: 'Kira artış tarihi (opsiyonel)',
              value: increaseDate,
              onChanged: (v) => setState(() => increaseDate = v),
            ),
        ],
        if (isProduct || (!isHome && !recurringMonthly)) ...[
          _TwoColumn(
            left: TextFormField(
              controller: installmentCount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                InputDecoration(
                  labelText: isProduct
                      ? 'Toplam taksit'
                      : 'Toplam taksit (opsiyonel)',
                ),
              ),
              validator: isProduct
                  ? (value) {
                      final parsed = int.tryParse(value ?? '');
                      return parsed == null || parsed <= 0
                          ? 'Toplam taksit sayısını girin.'
                          : null;
                    }
                  : null,
            ),
            right: TextFormField(
              controller: currentInstallment,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Kalan taksit (opsiyonel)'),
              ),
            ),
          ),
          _RemainingInstallmentPreview(
            totalController: installmentCount,
            paidController: currentInstallment,
          ),
        ],
        const _FormInfoBox(
          text:
              'Son ödeme tarihi takvimden sabitlenmez. Girilen ödeme günü ve ilk ödeme ayı esas alınır; sonraki aylar gerçek takvime göre otomatik hesaplanır.',
        ),
        TextFormField(
          controller: description,
          maxLength: 240,
          minLines: 2,
          maxLines: 5,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Açıklama'),
          ),
        ),
      ],
      onSave: () {
        final day = int.parse(paymentDay.text);
        var effectiveMonth = firstPaymentMonth;
        if (widget.rent == null &&
            !firstMonthManuallySelected &&
            _dueDateForMonthDay(
              effectiveMonth,
              day,
            ).isBefore(dateOnly(MizanClock.now()))) {
          effectiveMonth = DateTime(
            effectiveMonth.year,
            effectiveMonth.month + 1,
          );
        }
        final dueDate = _dueDateForMonthDay(effectiveMonth, day);
        final totalInstallments = parseOptionalPositiveInt(
          installmentCount.text,
          fieldName: 'Toplam taksit',
        );
        final basePaid = _basePaidInstallmentFromRemaining(
          installmentCount.text,
          currentInstallment.text,
          recordedInstallmentPayments:
              widget.rent?.payments
                  .where(
                    (item) => item.entryType == PaymentEntryType.installment,
                  )
                  .length ??
              0,
        );
        return widget.rent == null
            ? widget.controller.addRent(
                personId: widget.person.id,
                currencyCode: currencyCode,
                kind: kind,
                title: title.text,
                amount: parseMoney(amount.text),
                paymentDay: day,
                receiverName: receiver.text,
                dueDate: dueDate,
                recurringMonthly: recurringMonthly,
                iban: iban.text,
                contractStart: isProduct ? null : contractStart,
                contractEnd: isProduct ? null : contractEnd,
                increaseDate: isProduct ? null : increaseDate,
                installmentCount: isHome ? null : totalInstallments,
                currentInstallment: isHome ? null : basePaid,
                description: description.text,
              )
            : widget.controller.updateRent(
                personId: widget.person.id,
                currencyCode: currencyCode,
                rentId: widget.rent!.id,
                kind: kind,
                title: title.text,
                amount: parseMoney(amount.text),
                paymentDay: day,
                receiverName: receiver.text,
                dueDate: dueDate,
                recurringMonthly: recurringMonthly,
                iban: iban.text,
                contractStart: isProduct ? null : contractStart,
                contractEnd: isProduct ? null : contractEnd,
                increaseDate: isProduct ? null : increaseDate,
                installmentCount: isHome ? null : totalInstallments,
                currentInstallment: isHome ? null : basePaid,
                description: description.text,
              );
      },
    );
  }
}

class _MonthChoiceField extends StatelessWidget {
  const _MonthChoiceField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
    ),
    child: Row(
      children: [
        const Icon(Icons.calendar_month_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                monthLabel(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FormInfoBox extends StatelessWidget {
  const _FormInfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MizanTheme.blue.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: MizanTheme.blue.withValues(alpha: .18)),
    ),
    child: Text(
      text,
      style: const TextStyle(color: MizanTheme.muted, height: 1.35),
    ),
  );
}

class _PersonalDebtForm extends StatefulWidget {
  const _PersonalDebtForm({
    required this.controller,
    required this.person,
    this.debt,
  });

  final MizanController controller;
  final PersonAccount person;
  final PersonalDebtEntry? debt;

  @override
  State<_PersonalDebtForm> createState() => _PersonalDebtFormState();
}

class _PersonalDebtFormState extends State<_PersonalDebtForm> {
  final key = GlobalKey<FormState>();
  late String currencyCode;
  late CreditorType creditorType;
  late PaymentFrequency frequency;
  late bool isInstallment;
  late DateTime debtDate;
  late DateTime dueDate;
  late final TextEditingController title;
  late final TextEditingController creditorName;
  late final TextEditingController totalAmount;
  late final TextEditingController installmentCount;
  late final TextEditingController currentInstallment;
  late final TextEditingController monthlyAmount;
  late final TextEditingController customFrequencyDays;
  late final TextEditingController description;
  late final TextEditingController chequeNumber;
  late final TextEditingController issuerName;
  late final TextEditingController bankInfo;
  late final TextEditingController promissoryNoteNumber;
  late final TextEditingController documentCount;
  late final TextEditingController currentDocument;

  @override
  void initState() {
    super.initState();
    final item = widget.debt;
    currencyCode =
        item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;
    creditorType = item?.creditorType ?? CreditorType.person;
    frequency = item?.frequency ?? PaymentFrequency.oneTime;
    isInstallment = item?.isInstallment ?? false;
    debtDate = item?.debtDate ?? dateOnly(MizanClock.now());
    dueDate =
        item?.dueDate ??
        dateOnly(MizanClock.now().add(const Duration(days: 7)));
    title = TextEditingController(text: item?.title ?? '');
    creditorName = TextEditingController(text: item?.creditorName ?? '');
    totalAmount = TextEditingController(
      text: item == null ? '' : decimalText(item.totalAmount),
    );
    installmentCount = TextEditingController(
      text: item?.installmentCount?.toString() ?? '',
    );
    currentInstallment = TextEditingController(
      text: item?.installmentCount == null
          ? ''
          : item!.remainingInstallmentCount.toString(),
    );
    monthlyAmount = TextEditingController(
      text: item == null || item.monthlyAmount <= 0
          ? ''
          : decimalText(item.monthlyAmount),
    );
    customFrequencyDays = TextEditingController(
      text: item?.customFrequencyDays?.toString() ?? '',
    );
    description = TextEditingController(text: item?.description ?? '');
    chequeNumber = TextEditingController(text: item?.chequeNumber ?? '');
    issuerName = TextEditingController(text: item?.issuerName ?? '');
    bankInfo = TextEditingController(text: item?.bankInfo ?? '');
    promissoryNoteNumber = TextEditingController(
      text: item?.promissoryNoteNumber ?? '',
    );
    documentCount = TextEditingController(
      text: item?.documentCount?.toString() ?? '',
    );
    currentDocument = TextEditingController(
      text: item?.currentDocument?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    for (final controller in [
      title,
      creditorName,
      totalAmount,
      installmentCount,
      currentInstallment,
      monthlyAmount,
      customFrequencyDays,
      description,
      chequeNumber,
      issuerName,
      bankInfo,
      promissoryNoteNumber,
      documentCount,
      currentDocument,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCheque = creditorType == CreditorType.cheque;
    final isPromissory = creditorType == CreditorType.promissoryNote;
    return _DialogShell(
      title: widget.debt == null
          ? 'Kişisel / kurumsal borç ekle'
          : 'Kişisel / kurumsal borcu düzenle',
      formKey: key,
      children: [
        _RecordCurrencyField(
          currencyCode: currencyCode,
          onChanged: (value) => setState(() => currencyCode = value),
        ),
        DropdownButtonFormField<CreditorType>(
          initialValue: creditorType,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Alacaklı türü'),
          ),
          items: [
            for (final item in CreditorType.values)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) =>
              setState(() => creditorType = value ?? creditorType),
        ),
        TextFormField(
          controller: title,
          maxLength: 100,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Borç başlığı'),
          ),
          validator: (value) => _required(value, 'Borç başlığı'),
        ),
        TextFormField(
          controller: creditorName,
          maxLength: 100,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Alacaklı adı'),
          ),
          validator: (value) => _required(value, 'Alacaklı adı'),
        ),
        _MoneyField(
          controller: totalAmount,
          currencyCode: currencyCode,
          label: 'Toplam borç',
          validator: (value) => _moneyValidator(value, 'Toplam borç'),
        ),
        _TwoColumn(
          left: _DateField(
            label: 'Borcun oluştuğu tarih',
            value: debtDate,
            onChanged: (value) => setState(() => debtDate = value),
          ),
          right: _DateField(
            label: 'Son ödeme tarihi',
            value: dueDate,
            onChanged: (value) => setState(() => dueDate = value),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Taksitli ödeme planı'),
          subtitle: const Text(
            'Açıksa taksit sayısı ve düzenli ödeme tutarı saklanır.',
          ),
          value: isInstallment,
          onChanged: (value) => setState(() {
            isInstallment = value;
            if (!value) {
              frequency = PaymentFrequency.oneTime;
            } else if (frequency == PaymentFrequency.oneTime) {
              frequency = PaymentFrequency.monthly;
            }
          }),
        ),
        DropdownButtonFormField<PaymentFrequency>(
          initialValue: frequency,
          isExpanded: true,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Ödeme sıklığı'),
          ),
          items: [
            for (final item in PaymentFrequency.values)
              if (isInstallment || item == PaymentFrequency.oneTime)
                DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          ],
          onChanged: (value) => setState(() => frequency = value ?? frequency),
        ),
        if (frequency == PaymentFrequency.custom)
          TextFormField(
            controller: customFrequencyDays,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Özel ödeme aralığı (gün)'),
            ),
            validator: (value) => int.tryParse(value ?? '') == null
                ? 'Gün sayısını girin.'
                : null,
          ),
        if (isInstallment)
          _TwoColumn(
            left: TextFormField(
              controller: installmentCount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Toplam taksit'),
              ),
              validator: (value) => int.tryParse(value ?? '') == null
                  ? 'Toplam taksiti girin.'
                  : null,
            ),
            right: TextFormField(
              controller: currentInstallment,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                const InputDecoration(
                  labelText: 'Kalan taksit sayısı (opsiyonel)',
                  helperText:
                      'Ödeme kaydı eklendikçe kalan taksit sayısı otomatik azalır.',
                ),
              ),
            ),
          ),
        if (isInstallment)
          _RemainingInstallmentPreview(
            totalController: installmentCount,
            paidController: currentInstallment,
          ),
        if (isInstallment)
          _MoneyField(
            controller: monthlyAmount,
            currencyCode: currencyCode,
            label: 'Düzenli ödeme tutarı',
            validator: (value) =>
                _moneyValidator(value, 'Düzenli ödeme tutarı'),
          ),
        if (isCheque) ...[
          TextFormField(
            controller: chequeNumber,
            maxLength: 80,
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Çek numarası'),
            ),
            validator: (value) => _required(value, 'Çek numarası'),
          ),
          TextFormField(
            controller: issuerName,
            maxLength: 100,
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Çeki düzenleyen kişi / kurum'),
            ),
          ),
          TextFormField(
            controller: bankInfo,
            maxLength: 100,
            decoration: localizedInputDecoration(
              const InputDecoration(
                labelText: 'Banka bilgisi (kullanıcı girişi)',
              ),
            ),
          ),
        ],
        if (isPromissory) ...[
          TextFormField(
            controller: promissoryNoteNumber,
            maxLength: 80,
            decoration: localizedInputDecoration(
              const InputDecoration(labelText: 'Senet numarası'),
            ),
            validator: (value) => _required(value, 'Senet numarası'),
          ),
          _TwoColumn(
            left: TextFormField(
              controller: documentCount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Senet adedi'),
              ),
            ),
            right: TextFormField(
              controller: currentDocument,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: localizedInputDecoration(
                const InputDecoration(labelText: 'Mevcut senet'),
              ),
            ),
          ),
          const Text(
            'Birden fazla senet varsa her biri ayrı vade satırı olarak oluşturulur.',
          ),
        ],
        TextFormField(
          controller: description,
          maxLength: 240,
          minLines: 2,
          maxLines: 5,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Açıklama'),
          ),
        ),
      ],
      onSave: () {
        final total = parseMoney(totalAmount.text);
        final installmentTotal = parseOptionalPositiveInt(
          installmentCount.text,
          fieldName: 'Toplam taksit',
        );
        final documentTotal = parseOptionalPositiveInt(
          documentCount.text,
          fieldName: 'Senet adedi',
        );
        final paymentAmount = monthlyAmount.text.trim().isEmpty
            ? 0.0
            : parseMoney(monthlyAmount.text);
        final scheduleCount = isPromissory
            ? documentTotal
            : isInstallment
            ? installmentTotal
            : null;
        final schedule = _createSchedule(
          existing: widget.debt?.schedule ?? const [],
          count: scheduleCount,
          firstDueDate: dueDate,
          totalAmount: total,
          regularAmount: paymentAmount,
          frequency: frequency,
          customDays: int.tryParse(customFrequencyDays.text),
          prefix: isPromissory ? 'Senet' : 'Taksit',
        );
        final args = (
          creditorType: creditorType,
          title: title.text,
          creditorName: creditorName.text,
          totalAmount: total,
          debtDate: debtDate,
          dueDate: dueDate,
          frequency: frequency,
          isInstallment: isInstallment,
          installmentCount: installmentTotal,
          currentInstallment: _basePaidInstallmentFromRemaining(
            installmentCount.text,
            currentInstallment.text,
            recordedInstallmentPayments:
                widget.debt?.payments
                    .where(
                      (item) => item.entryType == PaymentEntryType.installment,
                    )
                    .length ??
                0,
          ),
          monthlyAmount: paymentAmount,
          customFrequencyDays: int.tryParse(customFrequencyDays.text),
          description: description.text,
          chequeNumber: chequeNumber.text,
          issuerName: issuerName.text,
          bankInfo: bankInfo.text,
          promissoryNoteNumber: promissoryNoteNumber.text,
          documentCount: documentTotal,
          currentDocument: parseOptionalPositiveInt(
            currentDocument.text,
            fieldName: 'Mevcut senet',
          ),
          schedule: schedule,
        );
        return widget.debt == null
            ? widget.controller.addPersonalDebt(
                personId: widget.person.id,
                currencyCode: currencyCode,
                creditorType: args.creditorType,
                title: args.title,
                creditorName: args.creditorName,
                totalAmount: args.totalAmount,
                debtDate: args.debtDate,
                dueDate: args.dueDate,
                frequency: args.frequency,
                isInstallment: args.isInstallment,
                installmentCount: args.installmentCount,
                currentInstallment: args.currentInstallment,
                monthlyAmount: args.monthlyAmount,
                customFrequencyDays: args.customFrequencyDays,
                description: args.description,
                chequeNumber: args.chequeNumber,
                issuerName: args.issuerName,
                bankInfo: args.bankInfo,
                promissoryNoteNumber: args.promissoryNoteNumber,
                documentCount: args.documentCount,
                currentDocument: args.currentDocument,
                schedule: args.schedule,
              )
            : widget.controller.updatePersonalDebt(
                personId: widget.person.id,
                currencyCode: currencyCode,
                debtId: widget.debt!.id,
                creditorType: args.creditorType,
                title: args.title,
                creditorName: args.creditorName,
                totalAmount: args.totalAmount,
                debtDate: args.debtDate,
                dueDate: args.dueDate,
                frequency: args.frequency,
                isInstallment: args.isInstallment,
                installmentCount: args.installmentCount,
                currentInstallment: args.currentInstallment,
                monthlyAmount: args.monthlyAmount,
                customFrequencyDays: args.customFrequencyDays,
                description: args.description,
                chequeNumber: args.chequeNumber,
                issuerName: args.issuerName,
                bankInfo: args.bankInfo,
                promissoryNoteNumber: args.promissoryNoteNumber,
                documentCount: args.documentCount,
                currentDocument: args.currentDocument,
                schedule: args.schedule,
              );
      },
    );
  }

  List<DueScheduleItem> _createSchedule({
    required List<DueScheduleItem> existing,
    required int? count,
    required DateTime firstDueDate,
    required double totalAmount,
    required double regularAmount,
    required PaymentFrequency frequency,
    required int? customDays,
    required String prefix,
  }) {
    if (count == null || count <= 1) {
      return existing.length <= 1 ? existing : const [];
    }
    final result = <DueScheduleItem>[];
    var date = firstDueDate;
    var remaining = totalAmount;
    for (var index = 0; index < count; index++) {
      final amount = index == count - 1
          ? remaining
          : regularAmount > 0
          ? regularAmount.clamp(0.01, remaining).toDouble()
          : double.parse((totalAmount / count).toStringAsFixed(2));
      final existingItem = index < existing.length ? existing[index] : null;
      result.add(
        DueScheduleItem(
          id: existingItem?.id ?? newId('schedule'),
          label: '$prefix ${index + 1}/$count',
          amount: amount,
          dueDate: date,
          isCompleted: existingItem?.isCompleted ?? false,
        ),
      );
      remaining = double.parse(
        (remaining - amount).clamp(0, totalAmount).toStringAsFixed(2),
      );
      date = _nextScheduleDate(date, frequency, customDays);
    }
    return result;
  }

  DateTime _nextScheduleDate(
    DateTime source,
    PaymentFrequency frequency,
    int? customDays,
  ) {
    switch (frequency) {
      case PaymentFrequency.oneTime:
        return DateTime(source.year, source.month + 1, source.day);
      case PaymentFrequency.weekly:
        return source.add(const Duration(days: 7));
      case PaymentFrequency.biweekly:
        return source.add(const Duration(days: 14));
      case PaymentFrequency.monthly:
        return DateTime(source.year, source.month + 1, source.day);
      case PaymentFrequency.quarterly:
        return DateTime(source.year, source.month + 3, source.day);
      case PaymentFrequency.yearly:
        return DateTime(source.year + 1, source.month, source.day);
      case PaymentFrequency.custom:
        return source.add(Duration(days: customDays ?? 1));
    }
  }
}

class _SubscriptionForm extends StatefulWidget {
  const _SubscriptionForm({
    required this.controller,
    required this.person,
    this.subscription,
  });

  final MizanController controller;
  final PersonAccount person;
  final SubscriptionEntry? subscription;

  @override
  State<_SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<_SubscriptionForm> {
  final key = GlobalKey<FormState>();
  late String currencyCode;
  late SubscriptionKind kind;
  late PaymentFrequency frequency;
  late DateTime nextDueDate;
  late final TextEditingController title;
  late final TextEditingController provider;
  late final TextEditingController amount;
  late final TextEditingController customKind;
  late final TextEditingController customDays;
  late final TextEditingController subscriberNumber;
  late final TextEditingController contractNumber;
  late final TextEditingController description;

  @override
  void initState() {
    super.initState();
    final item = widget.subscription;
    currencyCode =
        item?.currencyCode ?? widget.controller.state.defaultCurrencyCode;
    kind = item?.kind ?? SubscriptionKind.digitalService;
    frequency = item?.frequency ?? PaymentFrequency.monthly;
    nextDueDate =
        item?.nextDueDate ??
        dateOnly(MizanClock.now().add(const Duration(days: 7)));
    title = TextEditingController(text: item?.title ?? '');
    provider = TextEditingController(text: item?.providerName ?? '');
    amount = TextEditingController(
      text: item == null ? '' : decimalText(item.amount),
    );
    customKind = TextEditingController(text: item?.customKindName ?? '');
    customDays = TextEditingController(
      text: item?.customFrequencyDays?.toString() ?? '',
    );
    subscriberNumber = TextEditingController(
      text: item?.subscriberNumber ?? '',
    );
    contractNumber = TextEditingController(text: item?.contractNumber ?? '');
    description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      title,
      provider,
      amount,
      customKind,
      customDays,
      subscriberNumber,
      contractNumber,
      description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogShell(
    title: widget.subscription == null ? 'Abonelik ekle' : 'Aboneliği düzenle',
    formKey: key,
    children: [
      _RecordCurrencyField(
        currencyCode: currencyCode,
        onChanged: (value) => setState(() => currencyCode = value),
      ),
      DropdownButtonFormField<SubscriptionKind>(
        initialValue: kind,
        isExpanded: true,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Abonelik türü'),
        ),
        items: [
          for (final item in SubscriptionKind.values)
            DropdownMenuItem(
              value: item,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) => setState(() => kind = value ?? kind),
      ),
      if (kind == SubscriptionKind.custom)
        TextFormField(
          controller: customKind,
          maxLength: 60,
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Özel tür adı'),
          ),
          validator: (value) => _required(value, 'Özel tür adı'),
        ),
      TextFormField(
        controller: title,
        maxLength: 100,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Abonelik başlığı'),
        ),
        validator: (value) => _required(value, 'Abonelik başlığı'),
      ),
      TextFormField(
        controller: provider,
        maxLength: 100,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Sağlayıcı adı'),
        ),
        validator: (value) => _required(value, 'Sağlayıcı adı'),
      ),
      _MoneyField(
        controller: amount,
        currencyCode: currencyCode,
        label: 'Dönem tutarı',
        validator: (value) => _moneyValidator(value, 'Dönem tutarı'),
      ),
      DropdownButtonFormField<PaymentFrequency>(
        initialValue: frequency,
        isExpanded: true,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Tekrar sıklığı'),
        ),
        items: [
          for (final item in PaymentFrequency.values)
            if (item != PaymentFrequency.oneTime)
              DropdownMenuItem(
                value: item,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        ],
        onChanged: (value) => setState(() => frequency = value ?? frequency),
      ),
      if (frequency == PaymentFrequency.custom)
        TextFormField(
          controller: customDays,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: localizedInputDecoration(
            const InputDecoration(labelText: 'Özel tekrar aralığı (gün)'),
          ),
          validator: (value) =>
              int.tryParse(value ?? '') == null ? 'Gün sayısını girin.' : null,
        ),
      _DateField(
        label: 'Sıradaki ödeme tarihi',
        value: nextDueDate,
        onChanged: (value) => setState(() => nextDueDate = value),
      ),
      TextFormField(
        controller: subscriberNumber,
        maxLength: 60,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Abone numarası'),
        ),
      ),
      TextFormField(
        controller: contractNumber,
        maxLength: 60,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Sözleşme numarası'),
        ),
      ),
      TextFormField(
        controller: description,
        maxLength: 240,
        minLines: 2,
        maxLines: 5,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Açıklama'),
        ),
      ),
    ],
    onSave: () => widget.subscription == null
        ? widget.controller.addSubscription(
            personId: widget.person.id,
            currencyCode: currencyCode,
            kind: kind,
            title: title.text,
            providerName: provider.text,
            amount: parseMoney(amount.text),
            frequency: frequency,
            nextDueDate: nextDueDate,
            customKindName: customKind.text,
            customFrequencyDays: int.tryParse(customDays.text),
            subscriberNumber: subscriberNumber.text,
            contractNumber: contractNumber.text,
            description: description.text,
          )
        : widget.controller.updateSubscription(
            personId: widget.person.id,
            currencyCode: currencyCode,
            subscriptionId: widget.subscription!.id,
            kind: kind,
            title: title.text,
            providerName: provider.text,
            amount: parseMoney(amount.text),
            frequency: frequency,
            nextDueDate: nextDueDate,
            customKindName: customKind.text,
            customFrequencyDays: int.tryParse(customDays.text),
            subscriberNumber: subscriberNumber.text,
            contractNumber: contractNumber.text,
            description: description.text,
          ),
  );
}

class _PaymentForm extends StatefulWidget {
  const _PaymentForm({
    required this.controller,
    required this.personId,
    required this.type,
    required this.sourceId,
    required this.remainingAmount,
    required this.currencyCode,
    required this.suggestedInstallmentAmount,
    required this.allowInstallmentPayment,
    this.payment,
  });
  final MizanController controller;
  final String personId;
  final RecordType type;
  final String sourceId;
  final double remainingAmount;
  final String currencyCode;
  final double suggestedInstallmentAmount;
  final bool allowInstallmentPayment;
  final PaymentRecord? payment;
  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final key = GlobalKey<FormState>();
  late DateTime paidAt;
  late PaymentEntryType entryType;
  late final TextEditingController amount, note, method;

  @override
  void initState() {
    super.initState();
    paidAt = widget.payment?.paidAt ?? dateOnly(MizanClock.now());
    entryType =
        widget.payment?.entryType ??
        (widget.allowInstallmentPayment
            ? PaymentEntryType.installment
            : PaymentEntryType.partial);
    amount = TextEditingController();
    note = TextEditingController(text: widget.payment?.note ?? '');
    method = TextEditingController(text: widget.payment?.method ?? '');
    if (widget.payment != null) {
      amount.text = decimalText(widget.payment!.amount);
    } else {
      _applySuggestedAmount(clearPartial: true);
    }
  }

  Iterable<PaymentEntryType> get availableTypes sync* {
    if (widget.allowInstallmentPayment ||
        widget.payment?.entryType == PaymentEntryType.installment) {
      yield PaymentEntryType.installment;
    }
    yield PaymentEntryType.debtClosure;
    yield PaymentEntryType.partial;
  }

  bool get amountIsAutomatic => entryType != PaymentEntryType.partial;

  double get installmentAmount {
    final suggested = widget.suggestedInstallmentAmount;
    if (suggested <= 0) return widget.remainingAmount;
    return suggested > widget.remainingAmount
        ? widget.remainingAmount
        : suggested;
  }

  void _applySuggestedAmount({bool clearPartial = false}) {
    if (entryType == PaymentEntryType.installment) {
      amount.text = decimalText(installmentAmount);
      return;
    }
    if (entryType == PaymentEntryType.debtClosure) {
      amount.text = decimalText(widget.remainingAmount);
      return;
    }
    if (clearPartial) {
      amount.clear();
    }
  }

  String get typeExplanation => switch (entryType) {
    PaymentEntryType.installment =>
      'Bu kaydın planlanan taksit/dönem tutarı otomatik kullanılır.',
    PaymentEntryType.debtClosure =>
      'Kalan borcun tamamı ödeme tutarı olarak otomatik kullanılır.',
    PaymentEntryType.partial =>
      'Kalan borcu aşmayacak ödeme tutarını kendin girebilirsin.',
  };

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    method.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DialogShell(
    title: widget.payment == null ? 'Ödeme ekle' : 'Ödemeyi düzenle',
    formKey: key,
    children: [
      Text(
        'Kalan tutar: ${money(widget.remainingAmount, currencyCode: widget.currencyCode)}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      DropdownButtonFormField<PaymentEntryType>(
        initialValue: entryType,
        isExpanded: true,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Ödeme türü'),
        ),
        items: [
          for (final type in availableTypes)
            DropdownMenuItem(value: type, child: Text(type.label)),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            entryType = value;
            _applySuggestedAmount(clearPartial: true);
          });
        },
      ),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(typeExplanation),
      ),
      _MoneyField(
        controller: amount,
        currencyCode: widget.currencyCode,
        label: 'Ödeme tutarı',
        readOnly: amountIsAutomatic,
        validator: (v) {
          final error = _moneyValidator(v, 'Ödeme tutarı');
          if (error != null) return error;
          final parsed = parseMoney(v ?? '');
          if (parsed > widget.remainingAmount + 0.001) {
            return 'Ödeme tutarı kalan borçtan büyük olamaz.';
          }
          return null;
        },
      ),
      if (amountIsAutomatic)
        const Text(
          'Otomatik tutar ödeme türüne göre hesaplandı. Kısmi ödeme seçilirse elle değiştirilebilir.',
          style: TextStyle(fontSize: 12),
        ),
      _DateField(
        label: 'Ödeme tarihi',
        value: paidAt,
        onChanged: (v) => setState(() => paidAt = v),
      ),
      TextFormField(
        controller: method,
        maxLength: 80,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Ödeme yöntemi (opsiyonel)'),
        ),
      ),
      TextFormField(
        controller: note,
        maxLength: 240,
        minLines: 2,
        maxLines: 5,
        decoration: localizedInputDecoration(
          const InputDecoration(labelText: 'Ödeme notu (opsiyonel)'),
        ),
      ),
    ],
    onSave: () => widget.payment == null
        ? widget.controller.addPayment(
            personId: widget.personId,
            type: widget.type,
            sourceId: widget.sourceId,
            amount: parseMoney(amount.text),
            paidAt: paidAt,
            entryType: entryType,
            note: note.text,
            method: method.text,
          )
        : widget.controller.updatePayment(
            personId: widget.personId,
            type: widget.type,
            sourceId: widget.sourceId,
            paymentId: widget.payment!.id,
            amount: parseMoney(amount.text),
            paidAt: paidAt,
            entryType: entryType,
            note: note.text,
            method: method.text,
          ),
  );
}

class _RemainingInstallmentPreview extends StatelessWidget {
  const _RemainingInstallmentPreview({
    required this.totalController,
    required this.paidController,
  });

  final TextEditingController totalController;
  final TextEditingController paidController;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([totalController, paidController]),
    builder: (context, child) {
      final total = int.tryParse(totalController.text.trim());
      final remaining = int.tryParse(paidController.text.trim());
      if (total == null || total <= 0) {
        return const SizedBox.shrink();
      }
      final safeRemaining = (remaining ?? total).clamp(0, total).toInt();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.format_list_numbered_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kalan taksit: $safeRemaining',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _RecordCurrencyField extends StatelessWidget {
  const _RecordCurrencyField({
    required this.currencyCode,
    required this.onChanged,
  });

  final String currencyCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    GlobalCatalog? catalog;
    try {
      catalog = GlobalCatalogRepository.current;
    } on StateError {
      catalog = null;
    }
    final option = catalog?.currency(currencyCode);
    final subtitle = option == null
        ? currencyCode
        : '${option.code} · ${option.nameFor(MizanI18n.languageTag)} · ${option.primarySymbol}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Para birimi seç'),
      subtitle: Text.user(subtitle),
      leading: const Icon(Icons.currency_exchange_outlined),
      trailing: const Icon(Icons.chevron_right),
      enabled: catalog != null,
      onTap: catalog == null
          ? null
          : () async {
              final selected = await showCurrencyPicker(
                context,
                catalog: catalog!,
                selectedCode: currencyCode,
              );
              if (selected != null) onChanged(selected.code);
            },
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    super.key,
    required this.controller,
    required this.currencyCode,
    required this.label,
    this.validator,
    this.requiredValue = true,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final String currencyCode;
  final String label;
  final String? Function(String?)? validator;
  final bool requiredValue;
  final bool readOnly;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    readOnly: readOnly,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]'))],
    decoration: localizedInputDecoration(
      InputDecoration(labelText: label, suffixText: currencyCode),
    ),
    validator:
        validator ??
        (requiredValue
            ? (v) => _moneyValidator(v, label)
            : (v) {
                if (v == null || v.trim().isEmpty) return null;
                return _moneyValidator(v, label, allowZero: true);
              }),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (selected != null) onChanged(selected);
    },
    borderRadius: BorderRadius.circular(14),
    child: InputDecorator(
      decoration: localizedInputDecoration(
        InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
      ),
      child: Text(
        shortDate(value),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _OptionalDateField extends StatelessWidget {
  const _OptionalDateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: value ?? MizanClock.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selected != null) onChanged(selected);
          },
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: localizedInputDecoration(
              InputDecoration(
                labelText: label,
                suffixIcon: const Icon(Icons.calendar_month_outlined),
              ),
            ),
            child: Text(
              value == null ? 'Seçilmedi' : shortDate(value!),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
      if (value != null)
        IconButton(
          tooltip: MizanI18n.text('Tarihi temizle'),
          onPressed: () => onChanged(null),
          icon: const Icon(Icons.clear),
        ),
    ],
  );
}

class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) {
      final narrow =
          MediaQuery.sizeOf(context).width < 600 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3;
      if (narrow) {
        return Column(children: [left, const SizedBox(height: 12), right]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      );
    },
  );
}
