import '../l10n/mizan_i18n.dart';
const int currentSchemaVersion = 13;

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _dayOfMonth(DateTime month, int requestedDay) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  final day = requestedDay.clamp(1, lastDay).toInt();
  return DateTime(month.year, month.month, day);
}

int _daysUntil(DateTime dueDate, DateTime reference) =>
    _dateOnly(dueDate).difference(_dateOnly(reference)).inDays;

double _safeAmount(num? value) {
  final parsed = value?.toDouble() ?? 0;
  if (!parsed.isFinite || parsed < 0) {
    return 0;
  }
  return double.parse(parsed.toStringAsFixed(2));
}

String _string(dynamic value, {String fallback = ''}) =>
    value is String ? value : fallback;

int? _intOrNull(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

DateTime _date(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return fallback ?? DateTime.now();
}

DateTime? _dateOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

enum PaymentStatus {
  active('Aktif'),
  upcoming('Yaklaşıyor'),
  overdue('Gecikmede'),
  completed('Tamamlandı'),
  passive('Pasif');

  const PaymentStatus(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum DebtKind {
  overdraft('KMH hesabı'),
  creditCard('Kredi kartı'),
  loan('Kredi'),
  vehicleLoan('Araç kredisi'),
  mortgage('Ev kredisi'),
  cashAdvance('Nakit avans'),
  installmentCashAdvance('Taksitli nakit avans'),
  custom('Özel borç türü');

  const DebtKind(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum DebtDueMode {
  fixedDate('Son ödeme tarihi'),
  monthlyDay('Her ayın belirli günü');

  const DebtDueMode(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum PaymentEntryType {
  installment('Taksit ödemesi'),
  debtClosure('Borç kapama'),
  partial('Kısmi ödeme');

  const PaymentEntryType(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum PaymentReminderFrequency {
  onceDaily('Günde 1 kez'),
  twiceDaily('Günde 2 kez'),
  threeTimesDaily('Günde 3 kez');

  const PaymentReminderFrequency(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum NotificationSoundMode {
  system('Cihazın varsayılan bildirim sesi'),
  silent('Sessiz');

  const NotificationSoundMode(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum IncomeFrequency {
  oneTime('Tek seferlik'),
  daily('Günlük'),
  weekly('Haftalık'),
  monthly('Aylık');

  const IncomeFrequency(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum BillKind {
  electricity('Elektrik'),
  water('Su'),
  phone('Telefon'),
  internet('İnternet'),
  naturalGas('Doğalgaz'),
  custom('Özel fatura');

  const BillKind(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum BillScheduleMode {
  oneTime('Tek dönem faturası'),
  monthly('Her ay tekrarlayan fatura');

  const BillScheduleMode(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum RentEntryKind {
  homeRent('Ev kirası'),
  productInstallment('Ürün taksiti'),
  custom('Özel oluştur');

  const RentEntryKind(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum CreditorType {
  person('Kişi'),
  companyInstitution('Şirket / Kurum'),
  cheque('Çek'),
  promissoryNote('Senet'),
  merchantBusiness('Esnaf / İşletme'),
  familyRelative('Aile / Yakın'),
  other('Diğer');

  const CreditorType(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum PaymentFrequency {
  oneTime('Tek ödeme'),
  weekly('Haftalık'),
  biweekly('İki haftada bir'),
  monthly('Aylık'),
  quarterly('Üç aylık'),
  yearly('Yıllık'),
  custom('Özel aralık');

  const PaymentFrequency(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum SubscriptionKind {
  digitalService('Dijital hizmet'),
  membership('Üyelik'),
  insurance('Sigorta'),
  education('Eğitim'),
  maintenance('Bakım / servis'),
  custom('Diğer abonelik');

  const SubscriptionKind(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

enum RecordType {
  debt('Banka borcu'),
  personalDebt('Kişisel / kurumsal borç'),
  bill('Fatura'),
  subscription('Abonelik'),
  rent('Kira / taksit');

  const RecordType(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.amount,
    required this.paidAt,
    this.note = '',
    this.method = '',
    this.entryType = PaymentEntryType.partial,
    this.appliesToDueDate,
  });

  final String id;
  final double amount;
  final DateTime paidAt;
  final String note;
  final String method;
  final PaymentEntryType entryType;
  final DateTime? appliesToDueDate;

  PaymentRecord copyWith({
    double? amount,
    DateTime? paidAt,
    String? note,
    String? method,
    PaymentEntryType? entryType,
    DateTime? appliesToDueDate,
    bool clearAppliesToDueDate = false,
  }) {
    return PaymentRecord(
      id: id,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
      method: method ?? this.method,
      entryType: entryType ?? this.entryType,
      appliesToDueDate: clearAppliesToDueDate
          ? null
          : appliesToDueDate ?? this.appliesToDueDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'paidAt': paidAt.toIso8601String(),
    'note': note,
    'method': method,
    'entryType': entryType.name,
    'appliesToDueDate': appliesToDueDate?.toIso8601String(),
  };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: _string(json['id']),
      amount: _safeAmount(json['amount'] as num?),
      paidAt: _date(json['paidAt']),
      note: _string(json['note']),
      method: _string(json['method']),
      entryType: PaymentEntryType.values.firstWhere(
        (item) => item.name == _string(json['entryType']),
        orElse: () => PaymentEntryType.partial,
      ),
      appliesToDueDate: _dateOrNull(json['appliesToDueDate']),
    );
  }
}

class RecordNote {
  const RecordNote({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RecordNote.fromJson(Map<String, dynamic> json) {
    return RecordNote(
      id: _string(json['id']),
      text: _string(json['text']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class DebtProduct {
  const DebtProduct({
    required this.id,
    required this.kind,
    required this.title,
    required this.totalAmount,
    required this.monthlyAmount,
    required this.dueDate,
    this.dueMode = DebtDueMode.fixedDate,
    this.dueDayOfMonth,
    this.customKindName = '',
    this.installmentCount,
    this.currentInstallment,
    this.manualOverdueDays,
    this.manualOverdueRecordedAt,
    this.manualOverdueSince,
    this.manualOverduePeriods = const [],
    this.limit,
    this.usedLimit,
    this.description = '',
    this.isArchived = false,
    this.payments = const [],
    this.notes = const [],
  });

  final String id;
  final DebtKind kind;
  final String title;
  final String customKindName;
  final double totalAmount;
  final double monthlyAmount;
  final DateTime dueDate;
  final DebtDueMode dueMode;
  final int? dueDayOfMonth;
  final int? installmentCount;
  final int? currentInstallment;
  final int? manualOverdueDays;
  final DateTime? manualOverdueRecordedAt;
  final DateTime? manualOverdueSince;
  final List<DateTime> manualOverduePeriods;
  final double? limit;
  final double? usedLimit;
  final String description;
  final bool isArchived;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;

  double get paidAmount =>
      payments.fold<double>(0.0, (sum, item) => sum + item.amount);

  double get remainingAmount {
    final value = totalAmount - paidAmount;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  int get paidInstallmentCount {
    final total = installmentCount;
    if (total == null || total <= 0) return 0;
    if (remainingAmount <= 0) return total;
    final base = (currentInstallment ?? 0).clamp(0, total).toInt();
    final recorded = payments
        .where((item) => item.entryType == PaymentEntryType.installment)
        .length;
    return (base + recorded).clamp(0, total).toInt();
  }

  int get remainingInstallmentCount {
    final total = installmentCount;
    if (total == null || total <= 0) return 0;
    return (total - paidInstallmentCount).clamp(0, total).toInt();
  }

  double get scheduledPaymentAmount {
    if (remainingAmount <= 0) return 0;
    final planned = monthlyAmount > 0 ? monthlyAmount : remainingAmount;
    return planned > remainingAmount ? remainingAmount : planned;
  }

  double paidInMonth(DateTime month) => payments
      .where(
        (item) =>
            item.paidAt.year == month.year && item.paidAt.month == month.month,
      )
      .fold<double>(0.0, (sum, item) => sum + item.amount);

  DateTime get firstScheduledDueDate => _dateOnly(dueDate);

  DateTime dueDateForMonth(DateTime month) =>
      _dayOfMonth(month, dueDayOfMonth ?? dueDate.day);

  List<DateTime> get normalizedManualOverduePeriods {
    final seen = <int>{};
    final result = <DateTime>[];
    for (final month in manualOverduePeriods) {
      final key = month.year * 100 + month.month;
      if (seen.add(key)) {
        result.add(DateTime(month.year, month.month));
      }
    }
    result.sort();
    return result;
  }

  List<DateTime> selectedOverdueDueDatesThrough(DateTime reference) =>
      normalizedManualOverduePeriods
          .map(dueDateForMonth)
          .where((due) => !due.isAfter(_dateOnly(reference)))
          .toList(growable: false);

  DateTime? _legacyManualOverdueSince() {
    if (manualOverdueSince != null) return _dateOnly(manualOverdueSince!);
    final days = manualOverdueDays;
    final recorded = manualOverdueRecordedAt;
    if (days == null || days <= 0 || recorded == null) return null;
    return _dateOnly(recorded).subtract(Duration(days: days));
  }

  DateTime? _manualOverdueSinceAfterPayments(DateTime reference) {
    var anchor = _legacyManualOverdueSince();
    if (anchor == null || remainingAmount <= 0) return null;
    if (dueMode != DebtDueMode.monthlyDay || scheduledPaymentAmount <= 0) {
      return anchor;
    }
    final recordedAt = _dateOnly(manualOverdueRecordedAt ?? anchor);
    final paidAfterAnchor = payments
        .where(
          (item) =>
              !_dateOnly(item.paidAt).isBefore(recordedAt) &&
              !_dateOnly(item.paidAt).isAfter(_dateOnly(reference)),
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    final completedPeriods = (paidAfterAnchor / scheduledPaymentAmount).floor();
    for (var index = 0; index < completedPeriods; index++) {
      final currentAnchor = anchor!;
      anchor = dueDateForMonth(
        DateTime(currentAnchor.year, currentAnchor.month + 1),
      );
    }
    return anchor;
  }

  List<DateTime> scheduledDueDatesThrough(DateTime reference) {
    final selected = selectedOverdueDueDatesThrough(reference);
    final result = <DateTime>{...selected};
    if (dueMode == DebtDueMode.fixedDate) {
      if (!_dateOnly(dueDate).isAfter(_dateOnly(reference))) {
        result.add(_dateOnly(dueDate));
      }
    } else {
      final first = firstScheduledDueDate;
      if (!first.isAfter(_dateOnly(reference))) {
        var cursor = DateTime(first.year, first.month);
        final last = DateTime(reference.year, reference.month);
        while (!cursor.isAfter(last)) {
          final due = dueDateForMonth(cursor);
          if (!due.isBefore(first) && !due.isAfter(_dateOnly(reference))) {
            result.add(due);
          }
          cursor = DateTime(cursor.year, cursor.month + 1);
        }
      }
    }
    final sorted = result.toList(growable: false)..sort();
    return sorted;
  }

  Map<DateTime, double> _periodPaymentsThrough(DateTime reference) {
    final dueDates = scheduledDueDatesThrough(reference);
    final result = <DateTime, double>{for (final due in dueDates) due: 0};
    if (dueDates.isEmpty) return result;
    final unassigned = <PaymentRecord>[];
    for (final payment in payments.where(
      (item) => !_dateOnly(item.paidAt).isAfter(_dateOnly(reference)),
    )) {
      final target = payment.appliesToDueDate == null
          ? null
          : _dateOnly(payment.appliesToDueDate!);
      if (target != null && result.containsKey(target)) {
        result[target] = (result[target] ?? 0) + payment.amount;
      } else {
        unassigned.add(payment);
      }
    }
    unassigned.sort((a, b) => a.paidAt.compareTo(b.paidAt));
    for (final payment in unassigned) {
      var left = payment.amount;
      for (final due in dueDates) {
        if (left <= 0.001) break;
        final needed = scheduledPaymentAmount - (result[due] ?? 0);
        if (needed <= 0.001) continue;
        final allocated = left < needed ? left : needed;
        result[due] = (result[due] ?? 0) + allocated;
        left -= allocated;
      }
    }
    return result;
  }

  List<DateTime> unpaidDueDatesAt(DateTime reference) {
    if (remainingAmount <= 0) return const [];
    if (dueMode == DebtDueMode.fixedDate) {
      return _dateOnly(dueDate).isBefore(_dateOnly(reference))
          ? [_dateOnly(dueDate)]
          : const [];
    }
    final paidByPeriod = _periodPaymentsThrough(reference);
    return paidByPeriod.entries
        .where((entry) => entry.value + 0.001 < scheduledPaymentAmount)
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  List<DateTime> missedDuePeriodsAt(DateTime reference) {
    final today = _dateOnly(reference);
    final byMonth = <int, DateTime>{};

    void addPeriod(DateTime value) {
      final normalized = _dateOnly(value);
      if (!normalized.isBefore(today)) return;
      final key = normalized.year * 100 + normalized.month;
      final current = byMonth[key];
      if (current == null || normalized.isBefore(current)) {
        byMonth[key] = normalized;
      }
    }

    for (final due in unpaidDueDatesAt(reference)) {
      addPeriod(due);
    }

    final anchor = _manualOverdueSinceAfterPayments(reference);
    if (anchor != null && anchor.isBefore(today)) {
      addPeriod(anchor);
      if (dueMode == DebtDueMode.monthlyDay) {
        var cursor = DateTime(anchor.year, anchor.month + 1);
        final lastMonth = DateTime(today.year, today.month);
        while (!cursor.isAfter(lastMonth)) {
          final due = dueDateForMonth(cursor);
          if (due.isBefore(today)) addPeriod(due);
          cursor = DateTime(cursor.year, cursor.month + 1);
        }
      }
    }

    final result = byMonth.values.toList(growable: false)..sort();
    return result;
  }

  double overdueInstallmentPrincipalAt(DateTime reference) {
    final periods = missedDuePeriodsAt(reference);
    if (periods.isEmpty) return scheduledPaymentAmount;
    final paidByPeriod = _periodPaymentsThrough(reference);
    var value = 0.0;
    for (final due in periods) {
      final paid = paidByPeriod[_dateOnly(due)] ?? 0;
      final remaining = scheduledPaymentAmount - paid;
      if (remaining > 0) value += remaining;
    }
    if (value <= 0) value = scheduledPaymentAmount;
    return value > remainingAmount ? remainingAmount : value;
  }

  DateTime? _earliestOverdueAnchorAt(DateTime reference) {
    final today = _dateOnly(reference);
    final candidates = <DateTime>[];
    final unpaid = unpaidDueDatesAt(reference);
    if (unpaid.isNotEmpty && unpaid.first.isBefore(today)) {
      candidates.add(_dateOnly(unpaid.first));
    }
    final manualAnchor = _manualOverdueSinceAfterPayments(reference);
    if (manualAnchor != null && manualAnchor.isBefore(today)) {
      candidates.add(_dateOnly(manualAnchor));
    }
    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.first;
  }

  int currentManualOverdueDaysAt(DateTime reference) {
    final today = _dateOnly(reference);
    final anchor = _manualOverdueSinceAfterPayments(reference);
    if (anchor == null || !anchor.isBefore(today)) return 0;
    return today.difference(_dateOnly(anchor)).inDays;
  }

  DateTime? oldestUnpaidDueDateAt(DateTime reference) {
    final overdueAnchor = _earliestOverdueAnchorAt(reference);
    if (overdueAnchor != null) return overdueAnchor;
    if (dueMode == DebtDueMode.fixedDate) return dueDate;
    final first = firstScheduledDueDate;
    if (_dateOnly(reference).isBefore(first)) return first;
    return dueDateForMonth(DateTime(reference.year, reference.month + 1));
  }

  double dueAmountAt(DateTime reference) {
    if (remainingAmount <= 0) return 0;
    if (missedDuePeriodsAt(reference).isNotEmpty) {
      return dueMode == DebtDueMode.monthlyDay
          ? overdueInstallmentPrincipalAt(reference)
          : scheduledPaymentAmount;
    }
    if (dueMode == DebtDueMode.fixedDate) return scheduledPaymentAmount;
    final due = effectiveDueDateAt(reference);
    final paid = _periodPaymentsThrough(reference)[due] ?? 0;
    final cycleRemaining = scheduledPaymentAmount - paid;
    final result = cycleRemaining <= 0
        ? scheduledPaymentAmount
        : cycleRemaining;
    return result > remainingAmount ? remainingAmount : result;
  }

  DateTime effectiveDueDateAt(DateTime reference) {
    final overdueAnchor = _earliestOverdueAnchorAt(reference);
    if (overdueAnchor != null) return overdueAnchor;
    if (dueMode == DebtDueMode.fixedDate) return dueDate;
    final first = firstScheduledDueDate;
    if (_dateOnly(reference).isBefore(first)) return first;
    return dueDateForMonth(DateTime(reference.year, reference.month + 1));
  }

  int overdueDaysAt(DateTime reference) {
    if (remainingAmount <= 0) return 0;
    final effectiveDueDate = effectiveDueDateAt(reference);
    if (!_dateOnly(effectiveDueDate).isBefore(_dateOnly(reference))) return 0;
    return _dateOnly(reference).difference(_dateOnly(effectiveDueDate)).inDays;
  }

  PaymentStatus statusAt(DateTime reference) {
    if (isArchived) return PaymentStatus.passive;
    if (remainingAmount <= 0) return PaymentStatus.completed;
    if (overdueDaysAt(reference) > 0) return PaymentStatus.overdue;
    final days = _daysUntil(effectiveDueDateAt(reference), reference);
    if (days <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.active;
  }

  PaymentStatus get status => statusAt(DateTime.now());

  String get displayKind =>
      kind == DebtKind.custom && customKindName.trim().isNotEmpty
      ? customKindName.trim()
      : kind.label;

  String get dueRuleLabel => dueMode == DebtDueMode.monthlyDay
      ? 'Her ayın ${dueDayOfMonth ?? dueDate.day}. günü'
      : 'Son ödeme ${_dateOnly(dueDate).day.toString().padLeft(2, '0')}.${_dateOnly(dueDate).month.toString().padLeft(2, '0')}.${dueDate.year}';

  bool isDueInMonth(DateTime month) =>
      remainingAmount > 0 &&
      (dueMode == DebtDueMode.monthlyDay ||
          (dueDate.year == month.year && dueDate.month == month.month));

  DebtProduct copyWith({
    DebtKind? kind,
    String? title,
    String? customKindName,
    double? totalAmount,
    double? monthlyAmount,
    DateTime? dueDate,
    DebtDueMode? dueMode,
    int? dueDayOfMonth,
    bool clearDueDayOfMonth = false,
    int? installmentCount,
    int? currentInstallment,
    int? manualOverdueDays,
    bool clearManualOverdueDays = false,
    DateTime? manualOverdueRecordedAt,
    bool clearManualOverdueRecordedAt = false,
    DateTime? manualOverdueSince,
    bool clearManualOverdueSince = false,
    List<DateTime>? manualOverduePeriods,
    double? limit,
    double? usedLimit,
    String? description,
    bool? isArchived,
    List<PaymentRecord>? payments,
    List<RecordNote>? notes,
  }) {
    return DebtProduct(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      customKindName: customKindName ?? this.customKindName,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      dueDate: dueDate ?? this.dueDate,
      dueMode: dueMode ?? this.dueMode,
      dueDayOfMonth: clearDueDayOfMonth
          ? null
          : dueDayOfMonth ?? this.dueDayOfMonth,
      installmentCount: installmentCount ?? this.installmentCount,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      manualOverdueDays: clearManualOverdueDays
          ? null
          : manualOverdueDays ?? this.manualOverdueDays,
      manualOverdueRecordedAt: clearManualOverdueRecordedAt
          ? null
          : manualOverdueRecordedAt ?? this.manualOverdueRecordedAt,
      manualOverdueSince: clearManualOverdueSince
          ? null
          : manualOverdueSince ?? this.manualOverdueSince,
      manualOverduePeriods: manualOverduePeriods ?? this.manualOverduePeriods,
      limit: limit ?? this.limit,
      usedLimit: usedLimit ?? this.usedLimit,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'customKindName': customKindName,
    'totalAmount': totalAmount,
    'monthlyAmount': monthlyAmount,
    'dueDate': dueDate.toIso8601String(),
    'dueMode': dueMode.name,
    'dueDayOfMonth': dueDayOfMonth,
    'installmentCount': installmentCount,
    'currentInstallment': currentInstallment,
    'manualOverdueDays': manualOverdueDays,
    'manualOverdueRecordedAt': manualOverdueRecordedAt?.toIso8601String(),
    'manualOverdueSince': manualOverdueSince?.toIso8601String(),
    'manualOverduePeriods': normalizedManualOverduePeriods
        .map((item) => item.toIso8601String())
        .toList(),
    'limit': limit,
    'usedLimit': usedLimit,
    'description': description,
    'isArchived': isArchived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'notes': notes.map((item) => item.toJson()).toList(),
  };

  factory DebtProduct.fromJson(Map<String, dynamic> json) {
    final kindName = _string(json['kind'], fallback: DebtKind.custom.name);
    final dueModeName = _string(
      json['dueMode'],
      fallback: DebtDueMode.fixedDate.name,
    );
    return DebtProduct(
      id: _string(json['id']),
      kind: DebtKind.values.firstWhere(
        (item) => item.name == kindName,
        orElse: () => DebtKind.custom,
      ),
      title: _string(json['title']),
      customKindName: _string(json['customKindName']),
      totalAmount: _safeAmount(json['totalAmount'] as num?),
      monthlyAmount: _safeAmount(json['monthlyAmount'] as num?),
      dueDate: _date(json['dueDate']),
      dueMode: DebtDueMode.values.firstWhere(
        (item) => item.name == dueModeName,
        orElse: () => DebtDueMode.fixedDate,
      ),
      dueDayOfMonth: _intOrNull(json['dueDayOfMonth']),
      installmentCount: _intOrNull(json['installmentCount']),
      currentInstallment: _intOrNull(json['currentInstallment']),
      manualOverdueDays: _intOrNull(json['manualOverdueDays']),
      manualOverdueRecordedAt: _dateOrNull(json['manualOverdueRecordedAt']),
      manualOverdueSince: _dateOrNull(json['manualOverdueSince']),
      manualOverduePeriods:
          ((json['manualOverduePeriods'] as List?) ?? const [])
              .map(_dateOrNull)
              .whereType<DateTime>()
              .map((item) => DateTime(item.year, item.month))
              .toList(growable: false),
      limit: json['limit'] is num ? _safeAmount(json['limit'] as num) : null,
      usedLimit: json['usedLimit'] is num
          ? _safeAmount(json['usedLimit'] as num)
          : null,
      description: _string(
        json['description'],
        fallback: _string(json['note']),
      ),
      isArchived: json['isArchived'] as bool? ?? false,
      payments: _paymentList(json['payments']),
      notes: _noteList(json['notes']),
    );
  }
}

class BankGroup {
  const BankGroup({
    required this.id,
    required this.userWrittenName,
    this.products = const [],
  });

  final String id;
  final String userWrittenName;
  final List<DebtProduct> products;

  double get totalDebt => products
      .where((product) => !product.isArchived)
      .fold<double>(0.0, (sum, product) => sum + product.remainingAmount);

  double monthlyLoadFor(DateTime month) => products
      .where(
        (product) =>
            !product.isArchived &&
            product.remainingAmount > 0 &&
            product.isDueInMonth(month),
      )
      .fold<double>(
        0.0,
        (sum, product) => sum + product.scheduledPaymentAmount,
      );

  BankGroup copyWith({String? userWrittenName, List<DebtProduct>? products}) {
    return BankGroup(
      id: id,
      userWrittenName: userWrittenName ?? this.userWrittenName,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userWrittenName': userWrittenName,
    'products': products.map((item) => item.toJson()).toList(),
  };

  factory BankGroup.fromJson(Map<String, dynamic> json) {
    return BankGroup(
      id: _string(json['id']),
      userWrittenName: _string(json['userWrittenName']),
      products: ((json['products'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => DebtProduct.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class BillPeriodAmount {
  const BillPeriodAmount({required this.month, required this.amount});

  final DateTime month;
  final double amount;

  Map<String, dynamic> toJson() => {
    'month': DateTime(month.year, month.month).toIso8601String(),
    'amount': amount,
  };

  factory BillPeriodAmount.fromJson(Map<String, dynamic> json) =>
      BillPeriodAmount(
        month: _date(json['month']),
        amount: _safeAmount(json['amount'] as num?),
      );
}

class BillEntry {
  const BillEntry({
    required this.id,
    required this.kind,
    required this.institutionName,
    required this.amount,
    required this.dueDate,
    this.scheduleMode = BillScheduleMode.oneTime,
    this.paymentDay,
    this.periodAmounts = const [],
    this.subscriberNumber = '',
    this.contractNumber = '',
    this.description = '',
    this.isArchived = false,
    this.payments = const [],
    this.notes = const [],
  });

  final String id;
  final BillKind kind;
  final String institutionName;
  final String subscriberNumber;
  final String contractNumber;
  final double amount;
  final DateTime dueDate;
  final BillScheduleMode scheduleMode;
  final int? paymentDay;
  final List<BillPeriodAmount> periodAmounts;
  final String description;
  final bool isArchived;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;

  bool get isMonthly => scheduleMode == BillScheduleMode.monthly;

  DateTime get firstScheduledDueDate => _dateOnly(dueDate);

  DateTime dueDateForMonth(DateTime month) =>
      _dayOfMonth(month, paymentDay ?? dueDate.day);

  List<BillPeriodAmount> get normalizedPeriodAmounts {
    final byMonth = <int, BillPeriodAmount>{};
    for (final item in periodAmounts) {
      byMonth[item.month.year * 100 + item.month.month] = BillPeriodAmount(
        month: DateTime(item.month.year, item.month.month),
        amount: item.amount,
      );
    }
    final result = byMonth.values.toList(growable: false)
      ..sort((a, b) => a.month.compareTo(b.month));
    return result;
  }

  double amountForMonth(DateTime month) {
    for (final item in normalizedPeriodAmounts.reversed) {
      if (item.month.year == month.year && item.month.month == month.month) {
        return item.amount;
      }
    }
    return amount;
  }

  double get paidAmount =>
      payments.fold<double>(0.0, (sum, item) => sum + item.amount);

  List<DateTime> _dueDatesThroughMonth(DateTime reference) {
    if (!isMonthly) return [_dateOnly(dueDate)];
    final first = firstScheduledDueDate;
    final lastMonth = DateTime(reference.year, reference.month);
    final result = <DateTime>[];
    var cursor = DateTime(first.year, first.month);
    while (!cursor.isAfter(lastMonth)) {
      final due = dueDateForMonth(cursor);
      if (!due.isBefore(first)) result.add(due);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return result;
  }

  Map<DateTime, double> _periodPaymentsThrough(DateTime reference) {
    final dueDates = _dueDatesThroughMonth(reference);
    final result = <DateTime, double>{for (final due in dueDates) due: 0};
    if (dueDates.isEmpty) return result;
    final unassigned = <PaymentRecord>[];
    for (final payment in payments.where(
      (item) => !_dateOnly(item.paidAt).isAfter(_dateOnly(reference)),
    )) {
      final target = payment.appliesToDueDate == null
          ? null
          : _dateOnly(payment.appliesToDueDate!);
      if (target != null && result.containsKey(target)) {
        result[target] = (result[target] ?? 0) + payment.amount;
      } else {
        unassigned.add(payment);
      }
    }
    unassigned.sort((a, b) => a.paidAt.compareTo(b.paidAt));
    for (final payment in unassigned) {
      var left = payment.amount;
      for (final due in dueDates) {
        if (left <= 0.001) break;
        final needed = amountForMonth(due) - (result[due] ?? 0);
        if (needed <= 0.001) continue;
        final allocated = left < needed ? left : needed;
        result[due] = (result[due] ?? 0) + allocated;
        left -= allocated;
      }
    }
    return result;
  }

  double dueAmountAt(DateTime reference) {
    if (!isMonthly) {
      final value = amount - paidAmount;
      return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
    }
    final due = effectiveDueDateAt(reference);
    final paid = _periodPaymentsThrough(reference)[due] ?? 0;
    final value = amountForMonth(due) - paid;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  double outstandingAmountAt(DateTime reference) {
    if (!isMonthly) return dueAmountAt(reference);
    final paidByPeriod = _periodPaymentsThrough(reference);
    var total = 0.0;
    for (final due in _dueDatesThroughMonth(reference)) {
      final left = amountForMonth(due) - (paidByPeriod[due] ?? 0);
      if (left > 0) total += left;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get remainingAmount => outstandingAmountAt(DateTime.now());

  List<DateTime> unpaidDueDatesAt(DateTime reference) {
    if (!isMonthly) {
      return dueAmountAt(reference) > 0 &&
              _dateOnly(dueDate).isBefore(_dateOnly(reference))
          ? [_dateOnly(dueDate)]
          : const [];
    }
    final paidByPeriod = _periodPaymentsThrough(reference);
    return _dueDatesThroughMonth(reference)
        .where(
          (due) =>
              due.isBefore(_dateOnly(reference)) &&
              (paidByPeriod[due] ?? 0) + 0.001 < amountForMonth(due),
        )
        .toList(growable: false);
  }

  DateTime effectiveDueDateAt(DateTime reference) {
    if (!isMonthly) return _dateOnly(dueDate);
    final today = _dateOnly(reference);
    final first = firstScheduledDueDate;
    if (today.isBefore(first)) return first;
    final paidByPeriod = _periodPaymentsThrough(reference);
    for (final due in _dueDatesThroughMonth(reference)) {
      if ((paidByPeriod[due] ?? 0) + 0.001 < amountForMonth(due)) {
        return due;
      }
    }
    return dueDateForMonth(DateTime(reference.year, reference.month + 1));
  }

  int overdueDaysAt(DateTime reference) {
    if (dueAmountAt(reference) <= 0) return 0;
    final due = effectiveDueDateAt(reference);
    return due.isBefore(_dateOnly(reference))
        ? _dateOnly(reference).difference(due).inDays
        : 0;
  }

  PaymentStatus statusAt(DateTime reference) {
    if (isArchived) return PaymentStatus.passive;
    if (!isMonthly && remainingAmount <= 0) return PaymentStatus.completed;
    final due = effectiveDueDateAt(reference);
    final days = _daysUntil(due, reference);
    if (dueAmountAt(reference) > 0 && days < 0) return PaymentStatus.overdue;
    if (days <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.active;
  }

  PaymentStatus get status => statusAt(DateTime.now());

  bool isDueInMonth(DateTime month) {
    if (!isMonthly) {
      return dueDate.year == month.year && dueDate.month == month.month;
    }
    final candidate = dueDateForMonth(month);
    return !candidate.isBefore(firstScheduledDueDate);
  }

  BillEntry copyWith({
    BillKind? kind,
    String? institutionName,
    String? subscriberNumber,
    String? contractNumber,
    double? amount,
    DateTime? dueDate,
    BillScheduleMode? scheduleMode,
    int? paymentDay,
    bool clearPaymentDay = false,
    List<BillPeriodAmount>? periodAmounts,
    String? description,
    bool? isArchived,
    List<PaymentRecord>? payments,
    List<RecordNote>? notes,
  }) {
    return BillEntry(
      id: id,
      kind: kind ?? this.kind,
      institutionName: institutionName ?? this.institutionName,
      subscriberNumber: subscriberNumber ?? this.subscriberNumber,
      contractNumber: contractNumber ?? this.contractNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      paymentDay: clearPaymentDay ? null : paymentDay ?? this.paymentDay,
      periodAmounts: periodAmounts ?? this.periodAmounts,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'institutionName': institutionName,
    'subscriberNumber': subscriberNumber,
    'contractNumber': contractNumber,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'scheduleMode': scheduleMode.name,
    'paymentDay': paymentDay,
    'periodAmounts': periodAmounts.map((item) => item.toJson()).toList(),
    'description': description,
    'isArchived': isArchived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'notes': notes.map((item) => item.toJson()).toList(),
  };

  factory BillEntry.fromJson(Map<String, dynamic> json) {
    final kindName = _string(json['kind'], fallback: BillKind.custom.name);
    final legacyPaidAt = _dateOrNull(json['paidAt']);
    final payments = _paymentList(json['payments']).toList();
    if (legacyPaidAt != null && payments.isEmpty) {
      payments.add(
        PaymentRecord(
          id: 'legacy-${_string(json['id'])}',
          amount: _safeAmount(json['amount'] as num?),
          paidAt: legacyPaidAt,
          note: 'Eski kayıttan aktarıldı',
        ),
      );
    }
    final due = _date(json['dueDate']);
    final scheduleMode = BillScheduleMode.values.firstWhere(
      (item) => item.name == _string(json['scheduleMode']),
      orElse: () => BillScheduleMode.oneTime,
    );
    return BillEntry(
      id: _string(json['id']),
      kind: BillKind.values.firstWhere(
        (item) => item.name == kindName,
        orElse: () => BillKind.custom,
      ),
      institutionName: _string(json['institutionName']),
      subscriberNumber: _string(json['subscriberNumber']),
      contractNumber: _string(json['contractNumber']),
      amount: _safeAmount(json['amount'] as num?),
      dueDate: due,
      scheduleMode: scheduleMode,
      paymentDay: scheduleMode == BillScheduleMode.monthly
          ? (_intOrNull(json['paymentDay']) ?? due.day).clamp(1, 31).toInt()
          : null,
      periodAmounts: ((json['periodAmounts'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                BillPeriodAmount.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.amount > 0)
          .toList(growable: false),
      description: _string(json['description']),
      isArchived: json['isArchived'] as bool? ?? false,
      payments: payments,
      notes: _noteList(json['notes']),
    );
  }
}

class RentEntry {
  const RentEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.paymentDay,
    required this.receiverName,
    required this.dueDate,
    this.kind = RentEntryKind.custom,
    this.recurringMonthly = false,
    this.iban = '',
    this.contractStart,
    this.contractEnd,
    this.increaseDate,
    this.installmentCount,
    this.currentInstallment,
    this.description = '',
    this.isArchived = false,
    this.payments = const [],
    this.notes = const [],
  });

  final String id;
  final RentEntryKind kind;
  final String title;
  final double amount;
  final int paymentDay;
  final String receiverName;
  final String iban;
  final DateTime dueDate;
  final bool recurringMonthly;
  final DateTime? contractStart;
  final DateTime? contractEnd;
  final DateTime? increaseDate;
  final int? installmentCount;
  final int? currentInstallment;
  final String description;
  final bool isArchived;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;

  bool get isMonthlySchedule =>
      kind == RentEntryKind.homeRent ||
      kind == RentEntryKind.productInstallment ||
      recurringMonthly ||
      installmentCount != null;

  DateTime get firstScheduledDueDate => _dateOnly(dueDate);

  DateTime dueDateForMonth(DateTime month) => _dayOfMonth(month, paymentDay);

  double get paidAmount =>
      payments.fold<double>(0.0, (sum, item) => sum + item.amount);

  bool get isCompleted {
    if (kind == RentEntryKind.homeRent ||
        (kind == RentEntryKind.custom &&
            recurringMonthly &&
            installmentCount == null)) {
      return false;
    }
    return paidAmount + 0.001 >= amount ||
        (installmentCount != null &&
            installmentCount! > 0 &&
            paidInstallmentCount >= installmentCount!);
  }

  int get paidInstallmentCount {
    final total = installmentCount;
    if (total == null || total <= 0) return 0;
    if (paidAmount + 0.001 >= amount) return total;
    final base = (currentInstallment ?? 0).clamp(0, total).toInt();
    final recorded = payments
        .where((item) => item.entryType == PaymentEntryType.installment)
        .length;
    return (base + recorded).clamp(0, total).toInt();
  }

  int get remainingInstallmentCount {
    final total = installmentCount;
    if (total == null || total <= 0) return 0;
    return (total - paidInstallmentCount).clamp(0, total).toInt();
  }

  double get plannedCycleAmount {
    if (installmentCount != null && installmentCount! > 0) {
      final remainingCount = remainingInstallmentCount;
      final remainingValue = amount - paidAmount;
      if (remainingCount <= 0 || remainingValue <= 0) return 0;
      return double.parse((remainingValue / remainingCount).toStringAsFixed(2));
    }
    if (isMonthlySchedule) return amount;
    final remaining = amount - paidAmount;
    return remaining <= 0 ? 0 : double.parse(remaining.toStringAsFixed(2));
  }

  List<DateTime> _dueDatesThroughMonth(DateTime reference) {
    if (!isMonthlySchedule) return [_dateOnly(dueDate)];
    final first = firstScheduledDueDate;
    final lastMonth = DateTime(reference.year, reference.month);
    final result = <DateTime>[];
    var cursor = DateTime(first.year, first.month);
    var index = 0;
    while (!cursor.isAfter(lastMonth)) {
      if (installmentCount != null && index >= installmentCount!) {
        break;
      }
      final due = dueDateForMonth(cursor);
      if (!due.isBefore(first)) result.add(due);
      cursor = DateTime(cursor.year, cursor.month + 1);
      index += 1;
    }
    return result;
  }

  Map<DateTime, double> _periodPaymentsThrough(DateTime reference) {
    final dueDates = _dueDatesThroughMonth(reference);
    final result = <DateTime, double>{for (final due in dueDates) due: 0};
    if (dueDates.isEmpty) return result;
    final unassigned = <PaymentRecord>[];
    for (final payment in payments.where(
      (item) => !_dateOnly(item.paidAt).isAfter(_dateOnly(reference)),
    )) {
      final target = payment.appliesToDueDate == null
          ? null
          : _dateOnly(payment.appliesToDueDate!);
      if (target != null && result.containsKey(target)) {
        result[target] = (result[target] ?? 0) + payment.amount;
      } else {
        unassigned.add(payment);
      }
    }
    unassigned.sort((a, b) => a.paidAt.compareTo(b.paidAt));
    for (final payment in unassigned) {
      var left = payment.amount;
      for (final due in dueDates) {
        if (left <= 0.001) break;
        final needed = plannedCycleAmount - (result[due] ?? 0);
        if (needed <= 0.001) continue;
        final allocated = left < needed ? left : needed;
        result[due] = (result[due] ?? 0) + allocated;
        left -= allocated;
      }
    }
    return result;
  }

  DateTime effectiveDueDateAt(DateTime reference) {
    if (!isMonthlySchedule) return _dateOnly(dueDate);
    final today = _dateOnly(reference);
    final first = firstScheduledDueDate;
    if (today.isBefore(first)) return first;
    final paidByPeriod = _periodPaymentsThrough(reference);
    for (final due in _dueDatesThroughMonth(reference)) {
      if ((paidByPeriod[due] ?? 0) + 0.001 < plannedCycleAmount) {
        return due;
      }
    }
    final nextMonth = DateTime(reference.year, reference.month + 1);
    if (installmentCount != null) {
      final firstMonthIndex = first.year * 12 + first.month;
      final nextIndex = nextMonth.year * 12 + nextMonth.month;
      if (nextIndex - firstMonthIndex >= installmentCount!) {
        return dueDateForMonth(
          DateTime(first.year, first.month + installmentCount! - 1),
        );
      }
    }
    return dueDateForMonth(nextMonth);
  }

  double dueAmountAt(DateTime reference) {
    if (!isMonthlySchedule) {
      final value = amount - paidAmount;
      return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
    }
    if (isCompleted) return 0;
    final due = effectiveDueDateAt(reference);
    final paid = _periodPaymentsThrough(reference)[due] ?? 0;
    final value = plannedCycleAmount - paid;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  double outstandingAmountAt(DateTime reference) {
    if (!isMonthlySchedule) return dueAmountAt(reference);
    if (isCompleted) return 0;
    final paidByPeriod = _periodPaymentsThrough(reference);
    var total = 0.0;
    for (final due in _dueDatesThroughMonth(reference)) {
      final left = plannedCycleAmount - (paidByPeriod[due] ?? 0);
      if (left > 0) total += left;
    }
    if (total <= 0 &&
        effectiveDueDateAt(reference).isAfter(_dateOnly(reference))) {
      total = plannedCycleAmount;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get remainingAmount {
    if (kind == RentEntryKind.homeRent ||
        (kind == RentEntryKind.custom &&
            recurringMonthly &&
            installmentCount == null)) {
      return amount;
    }
    final value = amount - paidAmount;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  double get scheduledPaymentAmount => dueAmountAt(DateTime.now());

  List<DateTime> unpaidDueDatesAt(DateTime reference) {
    if (!isMonthlySchedule) {
      return dueAmountAt(reference) > 0 &&
              _dateOnly(dueDate).isBefore(_dateOnly(reference))
          ? [_dateOnly(dueDate)]
          : const [];
    }
    final paidByPeriod = _periodPaymentsThrough(reference);
    return _dueDatesThroughMonth(reference)
        .where(
          (due) =>
              due.isBefore(_dateOnly(reference)) &&
              (paidByPeriod[due] ?? 0) + 0.001 < plannedCycleAmount,
        )
        .toList(growable: false);
  }

  int overdueDaysAt(DateTime reference) {
    if (dueAmountAt(reference) <= 0) return 0;
    final due = effectiveDueDateAt(reference);
    return due.isBefore(_dateOnly(reference))
        ? _dateOnly(reference).difference(due).inDays
        : 0;
  }

  PaymentStatus statusAt(DateTime reference) {
    if (isArchived) return PaymentStatus.passive;
    if (isCompleted) return PaymentStatus.completed;
    final due = effectiveDueDateAt(reference);
    final days = _daysUntil(due, reference);
    if (dueAmountAt(reference) > 0 && days < 0) return PaymentStatus.overdue;
    if (days <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.active;
  }

  PaymentStatus get status => statusAt(DateTime.now());

  bool isDueInMonth(DateTime month) {
    if (!isMonthlySchedule) {
      return dueDate.year == month.year && dueDate.month == month.month;
    }
    final first = firstScheduledDueDate;
    if (first.year == month.year && first.month == month.month) return true;
    final due = dueDateForMonth(month);
    if (due.isBefore(firstScheduledDueDate)) return false;
    if (installmentCount != null) {
      final firstIndex =
          firstScheduledDueDate.year * 12 + firstScheduledDueDate.month;
      final index = month.year * 12 + month.month;
      return index - firstIndex < installmentCount!;
    }
    return true;
  }

  RentEntry copyWith({
    RentEntryKind? kind,
    String? title,
    double? amount,
    int? paymentDay,
    String? receiverName,
    String? iban,
    DateTime? dueDate,
    bool? recurringMonthly,
    DateTime? contractStart,
    bool clearContractStart = false,
    DateTime? contractEnd,
    bool clearContractEnd = false,
    DateTime? increaseDate,
    bool clearIncreaseDate = false,
    int? installmentCount,
    bool clearInstallmentCount = false,
    int? currentInstallment,
    bool clearCurrentInstallment = false,
    String? description,
    bool? isArchived,
    List<PaymentRecord>? payments,
    List<RecordNote>? notes,
  }) {
    return RentEntry(
      id: id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paymentDay: paymentDay ?? this.paymentDay,
      receiverName: receiverName ?? this.receiverName,
      iban: iban ?? this.iban,
      dueDate: dueDate ?? this.dueDate,
      recurringMonthly: recurringMonthly ?? this.recurringMonthly,
      contractStart: clearContractStart
          ? null
          : contractStart ?? this.contractStart,
      contractEnd: clearContractEnd ? null : contractEnd ?? this.contractEnd,
      increaseDate: clearIncreaseDate
          ? null
          : increaseDate ?? this.increaseDate,
      installmentCount: clearInstallmentCount
          ? null
          : installmentCount ?? this.installmentCount,
      currentInstallment: clearCurrentInstallment
          ? null
          : currentInstallment ?? this.currentInstallment,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      payments: payments ?? this.payments,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'amount': amount,
    'paymentDay': paymentDay,
    'receiverName': receiverName,
    'iban': iban,
    'dueDate': dueDate.toIso8601String(),
    'recurringMonthly': recurringMonthly,
    'contractStart': contractStart?.toIso8601String(),
    'contractEnd': contractEnd?.toIso8601String(),
    'increaseDate': increaseDate?.toIso8601String(),
    'installmentCount': installmentCount,
    'currentInstallment': currentInstallment,
    'description': description,
    'isArchived': isArchived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'notes': notes.map((item) => item.toJson()).toList(),
  };

  factory RentEntry.fromJson(Map<String, dynamic> json) {
    final kind = RentEntryKind.values.firstWhere(
      (item) => item.name == _string(json['kind']),
      orElse: () => RentEntryKind.custom,
    );
    return RentEntry(
      id: _string(json['id']),
      kind: kind,
      title: _string(json['title']),
      amount: _safeAmount(json['amount'] as num?),
      paymentDay: (_intOrNull(json['paymentDay']) ?? 1).clamp(1, 31).toInt(),
      receiverName: _string(json['receiverName']),
      iban: _string(json['iban']),
      dueDate: _date(json['dueDate']),
      recurringMonthly:
          json['recurringMonthly'] as bool? ?? kind == RentEntryKind.homeRent,
      contractStart: _dateOrNull(json['contractStart']),
      contractEnd: _dateOrNull(json['contractEnd']),
      increaseDate: _dateOrNull(json['increaseDate']),
      installmentCount: _intOrNull(json['installmentCount']),
      currentInstallment: _intOrNull(json['currentInstallment']),
      description: _string(json['description']),
      isArchived: json['isArchived'] as bool? ?? false,
      payments: _paymentList(json['payments']),
      notes: _noteList(json['notes']),
    );
  }
}

class DueScheduleItem {
  const DueScheduleItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.dueDate,
    this.isCompleted = false,
  });

  final String id;
  final String label;
  final double amount;
  final DateTime dueDate;
  final bool isCompleted;

  DueScheduleItem copyWith({
    String? label,
    double? amount,
    DateTime? dueDate,
    bool? isCompleted,
  }) => DueScheduleItem(
    id: id,
    label: label ?? this.label,
    amount: amount ?? this.amount,
    dueDate: dueDate ?? this.dueDate,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory DueScheduleItem.fromJson(Map<String, dynamic> json) =>
      DueScheduleItem(
        id: _string(json['id']),
        label: _string(json['label']),
        amount: _safeAmount(json['amount'] as num?),
        dueDate: _date(json['dueDate']),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class PersonalDebtEntry {
  const PersonalDebtEntry({
    required this.id,
    required this.creditorType,
    required this.title,
    required this.creditorName,
    required this.totalAmount,
    required this.debtDate,
    required this.dueDate,
    required this.frequency,
    this.isInstallment = false,
    this.installmentCount,
    this.currentInstallment,
    this.monthlyAmount = 0,
    this.customFrequencyDays,
    this.description = '',
    this.chequeNumber = '',
    this.issuerName = '',
    this.bankInfo = '',
    this.promissoryNoteNumber = '',
    this.documentCount,
    this.currentDocument,
    this.schedule = const [],
    this.isArchived = false,
    this.payments = const [],
    this.notes = const [],
  });

  final String id;
  final CreditorType creditorType;
  final String title;
  final String creditorName;
  final double totalAmount;
  final DateTime debtDate;
  final DateTime dueDate;
  final PaymentFrequency frequency;
  final bool isInstallment;
  final int? installmentCount;
  final int? currentInstallment;
  final double monthlyAmount;
  final int? customFrequencyDays;
  final String description;
  final String chequeNumber;
  final String issuerName;
  final String bankInfo;
  final String promissoryNoteNumber;
  final int? documentCount;
  final int? currentDocument;
  final List<DueScheduleItem> schedule;
  final bool isArchived;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;

  double get paidAmount =>
      payments.fold<double>(0, (sum, item) => sum + item.amount);
  double get remainingAmount {
    final value = totalAmount - paidAmount;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  int get paidInstallmentCount {
    final total = installmentCount;
    if (!isInstallment || total == null || total <= 0) return 0;
    if (remainingAmount <= 0) return total;
    final base = (currentInstallment ?? 0).clamp(0, total).toInt();
    final recorded = payments
        .where((item) => item.entryType == PaymentEntryType.installment)
        .length;
    return (base + recorded).clamp(0, total).toInt();
  }

  int get remainingInstallmentCount {
    final total = installmentCount;
    if (!isInstallment || total == null || total <= 0) return 0;
    return (total - paidInstallmentCount).clamp(0, total).toInt();
  }

  PaymentStatus statusAt(DateTime reference) {
    if (isArchived) return PaymentStatus.passive;
    if (remainingAmount <= 0) return PaymentStatus.completed;
    final days = _daysUntil(effectiveDueDate, reference);
    if (days < 0) return PaymentStatus.overdue;
    if (days <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.active;
  }

  PaymentStatus get status => statusAt(DateTime.now());

  List<DueScheduleItem> get resolvedSchedule {
    var unallocatedPayment = paidAmount;
    return schedule
        .map((item) {
          final completed = unallocatedPayment + 0.001 >= item.amount;
          unallocatedPayment = (unallocatedPayment - item.amount)
              .clamp(0.0, double.infinity)
              .toDouble();
          return item.copyWith(isCompleted: completed);
        })
        .toList(growable: false);
  }

  DateTime get effectiveDueDate {
    final openItems =
        resolvedSchedule.where((item) => !item.isCompleted).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return openItems.isEmpty ? dueDate : openItems.first.dueDate;
  }

  double get effectiveDueAmount {
    if (remainingAmount <= 0) return 0;
    if (schedule.isEmpty) {
      final planned = monthlyAmount > 0 ? monthlyAmount : remainingAmount;
      return planned > remainingAmount ? remainingAmount : planned;
    }
    var unallocatedPayment = paidAmount;
    final sorted = [...schedule]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    for (final item in sorted) {
      final openAmount = item.amount - unallocatedPayment;
      if (openAmount > 0.001) {
        return openAmount > remainingAmount ? remainingAmount : openAmount;
      }
      unallocatedPayment = (unallocatedPayment - item.amount)
          .clamp(0.0, double.infinity)
          .toDouble();
    }
    return remainingAmount;
  }

  String get displayCreditor =>
      creditorName.trim().isEmpty ? creditorType.label : creditorName.trim();

  bool isDueInMonth(DateTime month) =>
      effectiveDueDate.year == month.year &&
      effectiveDueDate.month == month.month;

  PersonalDebtEntry copyWith({
    CreditorType? creditorType,
    String? title,
    String? creditorName,
    double? totalAmount,
    DateTime? debtDate,
    DateTime? dueDate,
    PaymentFrequency? frequency,
    bool? isInstallment,
    int? installmentCount,
    int? currentInstallment,
    double? monthlyAmount,
    int? customFrequencyDays,
    String? description,
    String? chequeNumber,
    String? issuerName,
    String? bankInfo,
    String? promissoryNoteNumber,
    int? documentCount,
    int? currentDocument,
    List<DueScheduleItem>? schedule,
    bool? isArchived,
    List<PaymentRecord>? payments,
    List<RecordNote>? notes,
  }) => PersonalDebtEntry(
    id: id,
    creditorType: creditorType ?? this.creditorType,
    title: title ?? this.title,
    creditorName: creditorName ?? this.creditorName,
    totalAmount: totalAmount ?? this.totalAmount,
    debtDate: debtDate ?? this.debtDate,
    dueDate: dueDate ?? this.dueDate,
    frequency: frequency ?? this.frequency,
    isInstallment: isInstallment ?? this.isInstallment,
    installmentCount: installmentCount ?? this.installmentCount,
    currentInstallment: currentInstallment ?? this.currentInstallment,
    monthlyAmount: monthlyAmount ?? this.monthlyAmount,
    customFrequencyDays: customFrequencyDays ?? this.customFrequencyDays,
    description: description ?? this.description,
    chequeNumber: chequeNumber ?? this.chequeNumber,
    issuerName: issuerName ?? this.issuerName,
    bankInfo: bankInfo ?? this.bankInfo,
    promissoryNoteNumber: promissoryNoteNumber ?? this.promissoryNoteNumber,
    documentCount: documentCount ?? this.documentCount,
    currentDocument: currentDocument ?? this.currentDocument,
    schedule: schedule ?? this.schedule,
    isArchived: isArchived ?? this.isArchived,
    payments: payments ?? this.payments,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'creditorType': creditorType.name,
    'title': title,
    'creditorName': creditorName,
    'totalAmount': totalAmount,
    'debtDate': debtDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'frequency': frequency.name,
    'isInstallment': isInstallment,
    'installmentCount': installmentCount,
    'currentInstallment': currentInstallment,
    'monthlyAmount': monthlyAmount,
    'customFrequencyDays': customFrequencyDays,
    'description': description,
    'chequeNumber': chequeNumber,
    'issuerName': issuerName,
    'bankInfo': bankInfo,
    'promissoryNoteNumber': promissoryNoteNumber,
    'documentCount': documentCount,
    'currentDocument': currentDocument,
    'schedule': schedule.map((item) => item.toJson()).toList(),
    'isArchived': isArchived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'notes': notes.map((item) => item.toJson()).toList(),
  };

  factory PersonalDebtEntry.fromJson(Map<String, dynamic> json) {
    final creditorName = _string(
      json['creditorType'],
      fallback: CreditorType.other.name,
    );
    final frequencyName = _string(
      json['frequency'],
      fallback: PaymentFrequency.oneTime.name,
    );
    return PersonalDebtEntry(
      id: _string(json['id']),
      creditorType: CreditorType.values.firstWhere(
        (item) => item.name == creditorName,
        orElse: () => CreditorType.other,
      ),
      title: _string(json['title']),
      creditorName: _string(json['creditorName']),
      totalAmount: _safeAmount(json['totalAmount'] as num?),
      debtDate: _date(json['debtDate']),
      dueDate: _date(json['dueDate']),
      frequency: PaymentFrequency.values.firstWhere(
        (item) => item.name == frequencyName,
        orElse: () => PaymentFrequency.oneTime,
      ),
      isInstallment: json['isInstallment'] as bool? ?? false,
      installmentCount: _intOrNull(json['installmentCount']),
      currentInstallment: _intOrNull(json['currentInstallment']),
      monthlyAmount: _safeAmount(json['monthlyAmount'] as num?),
      customFrequencyDays: _intOrNull(json['customFrequencyDays']),
      description: _string(json['description']),
      chequeNumber: _string(json['chequeNumber']),
      issuerName: _string(json['issuerName']),
      bankInfo: _string(json['bankInfo']),
      promissoryNoteNumber: _string(json['promissoryNoteNumber']),
      documentCount: _intOrNull(json['documentCount']),
      currentDocument: _intOrNull(json['currentDocument']),
      schedule: ((json['schedule'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => DueScheduleItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      isArchived: json['isArchived'] as bool? ?? false,
      payments: _paymentList(json['payments']),
      notes: _noteList(json['notes']),
    );
  }
}

class SubscriptionEntry {
  const SubscriptionEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.providerName,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.customKindName = '',
    this.customFrequencyDays,
    this.subscriberNumber = '',
    this.contractNumber = '',
    this.description = '',
    this.isArchived = false,
    this.payments = const [],
    this.notes = const [],
  });

  final String id;
  final SubscriptionKind kind;
  final String title;
  final String providerName;
  final double amount;
  final PaymentFrequency frequency;
  final DateTime nextDueDate;
  final String customKindName;
  final int? customFrequencyDays;
  final String subscriberNumber;
  final String contractNumber;
  final String description;
  final bool isArchived;
  final List<PaymentRecord> payments;
  final List<RecordNote> notes;

  double get paidAmount =>
      payments.fold<double>(0.0, (sum, item) => sum + item.amount);

  double get currentCyclePaid => payments
      .where(
        (item) =>
            item.appliesToDueDate != null &&
            _dateOnly(item.appliesToDueDate!) == _dateOnly(nextDueDate),
      )
      .fold<double>(0.0, (sum, item) => sum + item.amount);

  double get remainingAmount {
    if (isArchived) return 0;
    final value = amount - currentCyclePaid;
    return value <= 0 ? 0 : double.parse(value.toStringAsFixed(2));
  }

  PaymentStatus statusAt(DateTime reference) {
    if (isArchived) return PaymentStatus.passive;
    if (remainingAmount <= 0) return PaymentStatus.completed;
    final days = _daysUntil(nextDueDate, reference);
    if (days < 0) return PaymentStatus.overdue;
    if (days <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.active;
  }

  PaymentStatus get status => statusAt(DateTime.now());
  bool isDueInMonth(DateTime month) =>
      nextDueDate.year == month.year && nextDueDate.month == month.month;
  String get displayKind =>
      kind == SubscriptionKind.custom && customKindName.trim().isNotEmpty
      ? customKindName.trim()
      : kind.label;

  SubscriptionEntry copyWith({
    SubscriptionKind? kind,
    String? title,
    String? providerName,
    double? amount,
    PaymentFrequency? frequency,
    DateTime? nextDueDate,
    String? customKindName,
    int? customFrequencyDays,
    String? subscriberNumber,
    String? contractNumber,
    String? description,
    bool? isArchived,
    List<PaymentRecord>? payments,
    List<RecordNote>? notes,
  }) => SubscriptionEntry(
    id: id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    providerName: providerName ?? this.providerName,
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    customKindName: customKindName ?? this.customKindName,
    customFrequencyDays: customFrequencyDays ?? this.customFrequencyDays,
    subscriberNumber: subscriberNumber ?? this.subscriberNumber,
    contractNumber: contractNumber ?? this.contractNumber,
    description: description ?? this.description,
    isArchived: isArchived ?? this.isArchived,
    payments: payments ?? this.payments,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'providerName': providerName,
    'amount': amount,
    'frequency': frequency.name,
    'nextDueDate': nextDueDate.toIso8601String(),
    'customKindName': customKindName,
    'customFrequencyDays': customFrequencyDays,
    'subscriberNumber': subscriberNumber,
    'contractNumber': contractNumber,
    'description': description,
    'isArchived': isArchived,
    'payments': payments.map((item) => item.toJson()).toList(),
    'notes': notes.map((item) => item.toJson()).toList(),
  };

  factory SubscriptionEntry.fromJson(Map<String, dynamic> json) {
    final kindName = _string(
      json['kind'],
      fallback: SubscriptionKind.custom.name,
    );
    final frequencyName = _string(
      json['frequency'],
      fallback: PaymentFrequency.monthly.name,
    );
    return SubscriptionEntry(
      id: _string(json['id']),
      kind: SubscriptionKind.values.firstWhere(
        (item) => item.name == kindName,
        orElse: () => SubscriptionKind.custom,
      ),
      title: _string(json['title']),
      providerName: _string(json['providerName']),
      amount: _safeAmount(json['amount'] as num?),
      frequency: PaymentFrequency.values.firstWhere(
        (item) => item.name == frequencyName,
        orElse: () => PaymentFrequency.monthly,
      ),
      nextDueDate: _date(json['nextDueDate']),
      customKindName: _string(json['customKindName']),
      customFrequencyDays: _intOrNull(json['customFrequencyDays']),
      subscriberNumber: _string(json['subscriberNumber']),
      contractNumber: _string(json['contractNumber']),
      description: _string(json['description']),
      isArchived: json['isArchived'] as bool? ?? false,
      payments: _paymentList(json['payments']),
      notes: _noteList(json['notes']),
    );
  }
}

class PersonAccount {
  const PersonAccount({
    required this.id,
    required this.name,
    this.banks = const [],
    this.personalDebts = const [],
    this.bills = const [],
    this.subscriptions = const [],
    this.rents = const [],
  });

  final String id;
  final String name;
  final List<BankGroup> banks;
  final List<PersonalDebtEntry> personalDebts;
  final List<BillEntry> bills;
  final List<SubscriptionEntry> subscriptions;
  final List<RentEntry> rents;

  double get totalDebt {
    final bankTotal = banks.fold<double>(
      0.0,
      (sum, bank) => sum + bank.totalDebt,
    );
    final personalTotal = personalDebts
        .where((debt) => !debt.isArchived)
        .fold<double>(0.0, (sum, debt) => sum + debt.remainingAmount);
    final billTotal = bills
        .where((bill) => !bill.isArchived)
        .fold<double>(0.0, (sum, bill) => sum + bill.remainingAmount);
    final subscriptionTotal = subscriptions
        .where((subscription) => !subscription.isArchived)
        .fold<double>(
          0.0,
          (sum, subscription) => sum + subscription.remainingAmount,
        );
    final rentTotal = rents
        .where((rent) => !rent.isArchived)
        .fold<double>(0.0, (sum, rent) => sum + rent.remainingAmount);
    return bankTotal +
        personalTotal +
        billTotal +
        subscriptionTotal +
        rentTotal;
  }

  double monthlyLoadFor(DateTime month) {
    final bankTotal = banks.fold<double>(
      0.0,
      (sum, bank) => sum + bank.monthlyLoadFor(month),
    );
    final personalTotal = personalDebts
        .where(
          (item) =>
              !item.isArchived &&
              item.remainingAmount > 0 &&
              item.isDueInMonth(month),
        )
        .fold<double>(0.0, (sum, item) => sum + item.effectiveDueAmount);
    final billTotal = bills
        .where((bill) => !bill.isArchived && bill.isDueInMonth(month))
        .fold<double>(0.0, (sum, bill) => sum + bill.amountForMonth(month));
    final subscriptionTotal = subscriptions
        .where((item) => !item.isArchived && item.isDueInMonth(month))
        .fold<double>(0.0, (sum, item) => sum + item.amount);
    final rentTotal = rents
        .where((rent) => !rent.isArchived && rent.isDueInMonth(month))
        .fold<double>(0.0, (sum, rent) => sum + rent.plannedCycleAmount);
    return bankTotal +
        personalTotal +
        billTotal +
        subscriptionTotal +
        rentTotal;
  }

  int overdueCountAt(DateTime reference) {
    final debtCount = banks
        .expand((bank) => bank.products)
        .where(
          (product) => product.statusAt(reference) == PaymentStatus.overdue,
        )
        .length;
    final personalCount = personalDebts
        .where((item) => item.statusAt(reference) == PaymentStatus.overdue)
        .length;
    final billCount = bills
        .where((bill) => bill.statusAt(reference) == PaymentStatus.overdue)
        .length;
    final subscriptionCount = subscriptions
        .where((item) => item.statusAt(reference) == PaymentStatus.overdue)
        .length;
    final rentCount = rents
        .where((rent) => rent.statusAt(reference) == PaymentStatus.overdue)
        .length;
    return debtCount +
        personalCount +
        billCount +
        subscriptionCount +
        rentCount;
  }

  PersonAccount copyWith({
    String? name,
    List<BankGroup>? banks,
    List<PersonalDebtEntry>? personalDebts,
    List<BillEntry>? bills,
    List<SubscriptionEntry>? subscriptions,
    List<RentEntry>? rents,
  }) {
    return PersonAccount(
      id: id,
      name: name ?? this.name,
      banks: banks ?? this.banks,
      personalDebts: personalDebts ?? this.personalDebts,
      bills: bills ?? this.bills,
      subscriptions: subscriptions ?? this.subscriptions,
      rents: rents ?? this.rents,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'banks': banks.map((item) => item.toJson()).toList(),
    'personalDebts': personalDebts.map((item) => item.toJson()).toList(),
    'bills': bills.map((item) => item.toJson()).toList(),
    'subscriptions': subscriptions.map((item) => item.toJson()).toList(),
    'rents': rents.map((item) => item.toJson()).toList(),
  };

  factory PersonAccount.fromJson(Map<String, dynamic> json) {
    return PersonAccount(
      id: _string(json['id']),
      name: _string(json['name']),
      banks: ((json['banks'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => BankGroup.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      personalDebts: ((json['personalDebts'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                PersonalDebtEntry.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      bills: ((json['bills'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => BillEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      subscriptions: ((json['subscriptions'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                SubscriptionEntry.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      rents: ((json['rents'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => RentEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
    );
  }
}

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    this.colorValue = 0xFF1F7A5A,
  });

  final String id;
  final String name;
  final int colorValue;

  ExpenseCategory copyWith({String? name, int? colorValue}) {
    return ExpenseCategory(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
  };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: _string(json['id']),
      name: _string(json['name']),
      colorValue: _intOrNull(json['colorValue']) ?? 0xFF1F7A5A,
    );
  }
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.spentAt,
    this.note = '',
  });

  final String id;
  final String categoryId;
  final String name;
  final double quantity;
  final double unitPrice;
  final DateTime spentAt;
  final String note;

  double get totalAmount =>
      double.parse((quantity * unitPrice).toStringAsFixed(2));

  ExpenseItem copyWith({
    String? categoryId,
    String? name,
    double? quantity,
    double? unitPrice,
    DateTime? spentAt,
    String? note,
  }) {
    return ExpenseItem(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'spentAt': spentAt.toIso8601String(),
    'note': note,
  };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: _string(json['id']),
      categoryId: _string(json['categoryId']),
      name: _string(json['name']),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: _safeAmount(json['unitPrice'] as num?),
      spentAt: _date(json['spentAt']),
      note: _string(json['note']),
    );
  }
}

class IncomeReceipt {
  const IncomeReceipt({
    required this.id,
    required this.scheduledDate,
    required this.receivedDate,
  });

  final String id;
  final DateTime scheduledDate;
  final DateTime receivedDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'scheduledDate': scheduledDate.toIso8601String(),
    'receivedDate': receivedDate.toIso8601String(),
  };

  factory IncomeReceipt.fromJson(Map<String, dynamic> json) => IncomeReceipt(
    id: _string(json['id']),
    scheduledDate: _date(json['scheduledDate']),
    receivedDate: _date(json['receivedDate']),
  );
}

class IncomeEntry {
  const IncomeEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.isArchived = false,
    this.note = '',
    this.scheduleTrackingEnabled = false,
    this.scheduledWeekday,
    this.scheduledDayOfMonth,
    this.trackingStartedAt,
    this.receipts = const [],
  });

  final String id;
  final String title;
  final double amount;
  final IncomeFrequency frequency;
  final DateTime startDate;
  final bool isArchived;
  final String note;
  final bool scheduleTrackingEnabled;
  final int? scheduledWeekday;
  final int? scheduledDayOfMonth;
  final DateTime? trackingStartedAt;
  final List<IncomeReceipt> receipts;

  bool get supportsScheduleTracking =>
      frequency == IncomeFrequency.weekly ||
      frequency == IncomeFrequency.monthly;

  int get effectiveScheduledWeekday =>
      (scheduledWeekday ?? startDate.weekday).clamp(1, 7).toInt();

  int get effectiveScheduledDayOfMonth =>
      (scheduledDayOfMonth ?? startDate.day).clamp(1, 31).toInt();

  DateTime get effectiveTrackingStart =>
      _dateOnly(trackingStartedAt ?? startDate);

  DateTime _monthlyOccurrence(int year, int month) =>
      _dayOfMonth(DateTime(year, month), startDate.day);

  DateTime _trackedMonthlyOccurrence(int year, int month) =>
      _dayOfMonth(DateTime(year, month), effectiveScheduledDayOfMonth);

  DateTime _firstTrackedOccurrenceOnOrAfter(DateTime value) {
    final from = _dateOnly(value);
    if (frequency == IncomeFrequency.weekly) {
      final offset = (effectiveScheduledWeekday - from.weekday + 7) % 7;
      return from.add(Duration(days: offset));
    }
    var occurrence = _trackedMonthlyOccurrence(from.year, from.month);
    if (occurrence.isBefore(from)) {
      occurrence = _trackedMonthlyOccurrence(from.year, from.month + 1);
    }
    return occurrence;
  }

  DateTime _trackedOccurrenceAfter(DateTime occurrence) {
    if (frequency == IncomeFrequency.weekly) {
      return _dateOnly(occurrence).add(const Duration(days: 7));
    }
    return _trackedMonthlyOccurrence(occurrence.year, occurrence.month + 1);
  }

  bool hasReceiptFor(DateTime scheduledDate) {
    final target = _dateOnly(scheduledDate);
    return receipts.any(
      (receipt) => _dateOnly(receipt.scheduledDate) == target,
    );
  }

  IncomeReceipt? receiptFor(DateTime scheduledDate) {
    final target = _dateOnly(scheduledDate);
    for (final receipt in receipts) {
      if (_dateOnly(receipt.scheduledDate) == target) return receipt;
    }
    return null;
  }

  DateTime? trackedOccurrenceAt(DateTime reference) {
    if (isArchived || !scheduleTrackingEnabled || !supportsScheduleTracking) {
      return null;
    }
    final today = _dateOnly(reference);
    var occurrence = _firstTrackedOccurrenceOnOrAfter(effectiveTrackingStart);
    while (!occurrence.isAfter(today)) {
      if (!hasReceiptFor(occurrence)) return occurrence;
      occurrence = _trackedOccurrenceAfter(occurrence);
    }
    return occurrence;
  }

  int? daysUntilTrackedOccurrence(DateTime reference) {
    final occurrence = trackedOccurrenceAt(reference);
    return occurrence == null ? null : _daysUntil(occurrence, reference);
  }

  IncomeReceipt? get latestReceipt {
    if (receipts.isEmpty) return null;
    return receipts.reduce(
      (left, right) =>
          left.receivedDate.isAfter(right.receivedDate) ? left : right,
    );
  }

  int occurrenceCount(DateTime start, DateTime endInclusive) {
    if (isArchived || amount <= 0) return 0;
    final rangeStart = _dateOnly(start);
    final rangeEnd = _dateOnly(endInclusive);
    final first = _dateOnly(startDate);
    if (rangeEnd.isBefore(first) || rangeEnd.isBefore(rangeStart)) return 0;
    final effectiveStart = rangeStart.isAfter(first) ? rangeStart : first;
    switch (frequency) {
      case IncomeFrequency.oneTime:
        return !first.isBefore(rangeStart) && !first.isAfter(rangeEnd) ? 1 : 0;
      case IncomeFrequency.daily:
        return rangeEnd.difference(effectiveStart).inDays + 1;
      case IncomeFrequency.weekly:
        final offset = (first.weekday - effectiveStart.weekday + 7) % 7;
        final firstOccurrence = effectiveStart.add(Duration(days: offset));
        if (firstOccurrence.isAfter(rangeEnd)) return 0;
        return (rangeEnd.difference(firstOccurrence).inDays ~/ 7) + 1;
      case IncomeFrequency.monthly:
        var cursor = DateTime(effectiveStart.year, effectiveStart.month);
        var count = 0;
        while (!cursor.isAfter(DateTime(rangeEnd.year, rangeEnd.month))) {
          final occurrence = _monthlyOccurrence(cursor.year, cursor.month);
          if (!occurrence.isBefore(effectiveStart) &&
              !occurrence.isAfter(rangeEnd) &&
              !occurrence.isBefore(first)) {
            count++;
          }
          cursor = DateTime(cursor.year, cursor.month + 1);
        }
        return count;
    }
  }

  double totalForRange(DateTime start, DateTime endInclusive) => double.parse(
    (amount * occurrenceCount(start, endInclusive)).toStringAsFixed(2),
  );

  IncomeEntry copyWith({
    String? title,
    double? amount,
    IncomeFrequency? frequency,
    DateTime? startDate,
    bool? isArchived,
    String? note,
    bool? scheduleTrackingEnabled,
    int? scheduledWeekday,
    int? scheduledDayOfMonth,
    DateTime? trackingStartedAt,
    List<IncomeReceipt>? receipts,
  }) => IncomeEntry(
    id: id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    startDate: startDate ?? this.startDate,
    isArchived: isArchived ?? this.isArchived,
    note: note ?? this.note,
    scheduleTrackingEnabled:
        scheduleTrackingEnabled ?? this.scheduleTrackingEnabled,
    scheduledWeekday: scheduledWeekday ?? this.scheduledWeekday,
    scheduledDayOfMonth: scheduledDayOfMonth ?? this.scheduledDayOfMonth,
    trackingStartedAt: trackingStartedAt ?? this.trackingStartedAt,
    receipts: receipts ?? this.receipts,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'frequency': frequency.name,
    'startDate': startDate.toIso8601String(),
    'isArchived': isArchived,
    'note': note,
    'scheduleTrackingEnabled': scheduleTrackingEnabled,
    'scheduledWeekday': scheduledWeekday,
    'scheduledDayOfMonth': scheduledDayOfMonth,
    'trackingStartedAt': trackingStartedAt?.toIso8601String(),
    'receipts': receipts.map((item) => item.toJson()).toList(),
  };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
    id: _string(json['id']),
    title: _string(json['title']),
    amount: _safeAmount(json['amount'] as num?),
    frequency: IncomeFrequency.values.firstWhere(
      (item) => item.name == _string(json['frequency']),
      orElse: () => IncomeFrequency.monthly,
    ),
    startDate: _date(json['startDate']),
    isArchived: json['isArchived'] as bool? ?? false,
    note: _string(json['note']),
    scheduleTrackingEnabled: json['scheduleTrackingEnabled'] as bool? ?? false,
    scheduledWeekday: _intOrNull(json['scheduledWeekday']),
    scheduledDayOfMonth: _intOrNull(json['scheduledDayOfMonth']),
    trackingStartedAt: _dateOrNull(json['trackingStartedAt']),
    receipts: ((json['receipts'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => IncomeReceipt.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false),
  );
}

class NotificationSlot {
  const NotificationSlot({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.message,
    this.enabled = true,
  });

  final String id;
  final String label;
  final int hour;
  final int minute;
  final String message;
  final bool enabled;

  NotificationSlot copyWith({
    String? label,
    int? hour,
    int? minute,
    String? message,
    bool? enabled,
  }) {
    return NotificationSlot(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute,
    'message': message,
    'enabled': enabled,
  };

  factory NotificationSlot.fromJson(Map<String, dynamic> json) {
    return NotificationSlot(
      id: _string(json['id']),
      label: _string(json['label']),
      hour: (_intOrNull(json['hour']) ?? 7).clamp(0, 23).toInt(),
      minute: (_intOrNull(json['minute']) ?? 0).clamp(0, 59).toInt(),
      message: _string(json['message']),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class RecordReference {
  const RecordReference({
    required this.type,
    required this.personId,
    required this.sourceId,
    this.bankId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.overdueDays = 0,
  });

  final RecordType type;
  final String personId;
  final String sourceId;
  final String? bankId;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final int overdueDays;
}

class MizanState {
  const MizanState({
    required this.people,
    required this.expenseCategories,
    required this.expenses,
    required this.notificationSlots,
    this.paymentNotificationSlots = defaultPaymentNotificationSlots,
    this.incomes = const [],
    this.notificationsEnabled = true,
    this.paymentReminderFrequency = PaymentReminderFrequency.twiceDaily,
    this.notificationSoundMode = NotificationSoundMode.system,
    this.notificationVibrationEnabled = true,
    this.setupCompleted = true,
    this.appLanguageTag = 'tr',
    this.debtRegionCountryCode = 'TR',
    this.defaultCurrencyCode = 'TRY',
    this.recentCurrencyCodes = const [],
    this.schemaVersion = currentSchemaVersion,
  });

  final int schemaVersion;
  final List<PersonAccount> people;
  final List<ExpenseCategory> expenseCategories;
  final List<ExpenseItem> expenses;
  final List<NotificationSlot> notificationSlots;
  final List<NotificationSlot> paymentNotificationSlots;
  final List<IncomeEntry> incomes;
  final bool notificationsEnabled;
  final PaymentReminderFrequency paymentReminderFrequency;
  final NotificationSoundMode notificationSoundMode;
  final bool notificationVibrationEnabled;
  final bool setupCompleted;
  final String appLanguageTag;
  final String debtRegionCountryCode;
  final String defaultCurrencyCode;
  final List<String> recentCurrencyCodes;

  bool get usesTurkeyDebtCatalog => debtRegionCountryCode == 'TR';

  bool get hasIncomeInformation => incomes.any((item) => !item.isArchived);

  double incomeTotalForRange(DateTime start, DateTime endInclusive) => incomes
      .where((item) => !item.isArchived)
      .fold<double>(
        0.0,
        (sum, item) => sum + item.totalForRange(start, endInclusive),
      );

  double incomeTotalForMonth(DateTime month) => incomeTotalForRange(
    DateTime(month.year, month.month),
    DateTime(month.year, month.month + 1, 0),
  );

  List<DateTime> availableReportMonths(DateTime reference) {
    final keys = <int>{};
    void add(DateTime date) => keys.add(date.year * 100 + date.month);
    for (final expense in expenses) {
      add(expense.spentAt);
    }
    for (final income in incomes) {
      add(income.startDate);
      for (final receipt in income.receipts) {
        add(receipt.receivedDate);
      }
      if (!income.isArchived && income.frequency != IncomeFrequency.oneTime) {
        var month = DateTime(income.startDate.year, income.startDate.month);
        final last = DateTime(reference.year, reference.month);
        while (!month.isAfter(last)) {
          add(month);
          month = DateTime(month.year, month.month + 1);
        }
      }
    }
    for (final person in people) {
      for (final bank in person.banks) {
        for (final debt in bank.products) {
          if (debt.dueMode == DebtDueMode.monthlyDay) {
            for (final due in debt.scheduledDueDatesThrough(reference)) {
              add(due);
            }
          } else {
            add(debt.dueDate);
          }
          for (final payment in debt.payments) {
            add(payment.paidAt);
          }
        }
      }
      for (final debt in person.personalDebts) {
        add(debt.debtDate);
        add(debt.dueDate);
        for (final payment in debt.payments) {
          add(payment.paidAt);
        }
      }
      for (final bill in person.bills) {
        if (bill.isMonthly) {
          var month = DateTime(
            bill.firstScheduledDueDate.year,
            bill.firstScheduledDueDate.month,
          );
          final last = DateTime(reference.year, reference.month);
          while (!month.isAfter(last)) {
            add(bill.dueDateForMonth(month));
            month = DateTime(month.year, month.month + 1);
          }
          for (final period in bill.periodAmounts) {
            add(period.month);
          }
        } else {
          add(bill.dueDate);
        }
        for (final payment in bill.payments) {
          add(payment.paidAt);
        }
      }
      for (final subscription in person.subscriptions) {
        add(subscription.nextDueDate);
        for (final payment in subscription.payments) {
          add(payment.paidAt);
        }
      }
      for (final rent in person.rents) {
        if (rent.isMonthlySchedule) {
          var month = DateTime(
            rent.firstScheduledDueDate.year,
            rent.firstScheduledDueDate.month,
          );
          final last = DateTime(reference.year, reference.month);
          while (!month.isAfter(last) && rent.isDueInMonth(month)) {
            add(rent.dueDateForMonth(month));
            month = DateTime(month.year, month.month + 1);
          }
        } else {
          add(rent.dueDate);
        }
        for (final payment in rent.payments) {
          add(payment.paidAt);
        }
      }
    }
    final result = keys
        .map((key) => DateTime(key ~/ 100, key % 100))
        .toList(growable: false);
    result.sort((a, b) => b.compareTo(a));
    return result;
  }

  double get totalDebt =>
      people.fold<double>(0.0, (sum, person) => sum + person.totalDebt);

  double get bankDebtTotal => allDebtProducts
      .where((item) => !item.isArchived)
      .fold<double>(0.0, (sum, item) => sum + item.remainingAmount);

  double get personalCorporateDebtTotal => allPersonalDebts
      .where((item) => !item.isArchived)
      .fold<double>(0.0, (sum, item) => sum + item.remainingAmount);

  double get billTotal => allBills
      .where((item) => !item.isArchived)
      .fold<double>(0.0, (sum, item) => sum + item.remainingAmount);

  double get subscriptionTotal => allSubscriptions
      .where((item) => !item.isArchived)
      .fold<double>(0.0, (sum, item) => sum + item.remainingAmount);

  double get rentInstallmentTotal => allRents
      .where((item) => !item.isArchived)
      .fold<double>(0.0, (sum, item) => sum + item.remainingAmount);

  double overdueTotalAt(DateTime reference) => recordReferencesAt(reference)
      .where((item) => item.status == PaymentStatus.overdue)
      .fold<double>(0.0, (sum, item) => sum + item.amount);

  double dueWithinDaysTotal(DateTime reference, int days) {
    final end = _dateOnly(reference).add(Duration(days: days));
    return recordReferencesAt(reference)
        .where(
          (item) =>
              item.amount > 0 &&
              item.status != PaymentStatus.completed &&
              item.status != PaymentStatus.passive &&
              !_dateOnly(item.dueDate).isBefore(_dateOnly(reference)) &&
              !_dateOnly(item.dueDate).isAfter(end),
        )
        .fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  double monthlyDebtLoadFor(DateTime month) => people.fold<double>(
    0.0,
    (sum, person) => sum + person.monthlyLoadFor(month),
  );

  Map<RecordType, double> actualPaymentTotals({
    DateTime? month,
    DateTime? day,
    String? personId,
  }) {
    final totals = <RecordType, double>{
      for (final type in RecordType.values) type: 0,
    };
    bool included(PaymentRecord payment) {
      if (day != null) {
        return payment.paidAt.year == day.year &&
            payment.paidAt.month == day.month &&
            payment.paidAt.day == day.day;
      }
      return month == null ||
          (payment.paidAt.year == month.year &&
              payment.paidAt.month == month.month);
    }

    for (final person in people) {
      if (personId != null && person.id != personId) continue;
      for (final bank in person.banks) {
        for (final debt in bank.products) {
          totals[RecordType.debt] =
              (totals[RecordType.debt] ?? 0) +
              debt.payments
                  .where(included)
                  .fold<double>(0.0, (sum, item) => sum + item.amount);
        }
      }
      for (final debt in person.personalDebts) {
        totals[RecordType.personalDebt] =
            (totals[RecordType.personalDebt] ?? 0) +
            debt.payments
                .where(included)
                .fold<double>(0.0, (sum, item) => sum + item.amount);
      }
      for (final bill in person.bills) {
        totals[RecordType.bill] =
            (totals[RecordType.bill] ?? 0) +
            bill.payments
                .where(included)
                .fold<double>(0.0, (sum, item) => sum + item.amount);
      }
      for (final subscription in person.subscriptions) {
        totals[RecordType.subscription] =
            (totals[RecordType.subscription] ?? 0) +
            subscription.payments
                .where(included)
                .fold<double>(0.0, (sum, item) => sum + item.amount);
      }
      for (final rent in person.rents) {
        totals[RecordType.rent] =
            (totals[RecordType.rent] ?? 0) +
            rent.payments
                .where(included)
                .fold<double>(0.0, (sum, item) => sum + item.amount);
      }
    }
    return totals;
  }

  double actualPaymentTotal({
    DateTime? month,
    DateTime? day,
    String? personId,
  }) => actualPaymentTotals(
    month: month,
    day: day,
    personId: personId,
  ).values.fold<double>(0.0, (sum, item) => sum + item);

  double actualPaymentTotalForDay(DateTime day, {String? personId}) =>
      actualPaymentTotal(day: day, personId: personId);

  double actualPaymentTotalForMonth(DateTime month, {String? personId}) =>
      actualPaymentTotal(month: month, personId: personId);

  double totalOutflowForDay(DateTime day, {String? personId}) =>
      expenseTotalForDay(day) +
      actualPaymentTotalForDay(day, personId: personId);

  double totalOutflowForMonth(DateTime month, {String? personId}) =>
      expenseTotalForMonth(month) +
      actualPaymentTotalForMonth(month, personId: personId);

  double expenseTotalForDay(DateTime day) => expenses
      .where(
        (item) =>
            item.spentAt.year == day.year &&
            item.spentAt.month == day.month &&
            item.spentAt.day == day.day,
      )
      .fold<double>(0.0, (sum, item) => sum + item.totalAmount);

  double expenseTotalForMonth(DateTime month) => expenses
      .where(
        (item) =>
            item.spentAt.year == month.year &&
            item.spentAt.month == month.month,
      )
      .fold<double>(0.0, (sum, item) => sum + item.totalAmount);

  double expenseTotalForRange(DateTime start, DateTime endInclusive) => expenses
      .where((item) {
        final day = _dateOnly(item.spentAt);
        return !day.isBefore(_dateOnly(start)) &&
            !day.isAfter(_dateOnly(endInclusive));
      })
      .fold<double>(0.0, (sum, item) => sum + item.totalAmount);

  List<DebtProduct> get allDebtProducts => people
      .expand((person) => person.banks)
      .expand((bank) => bank.products)
      .toList(growable: false);

  List<PersonalDebtEntry> get allPersonalDebts =>
      people.expand((person) => person.personalDebts).toList(growable: false);

  List<BillEntry> get allBills =>
      people.expand((person) => person.bills).toList(growable: false);

  List<SubscriptionEntry> get allSubscriptions =>
      people.expand((person) => person.subscriptions).toList(growable: false);

  List<RentEntry> get allRents =>
      people.expand((person) => person.rents).toList(growable: false);

  List<RecordReference> recordReferencesAt(DateTime reference) {
    final items = <RecordReference>[];
    for (final person in people) {
      for (final bank in person.banks) {
        for (final product in bank.products) {
          items.add(
            RecordReference(
              type: RecordType.debt,
              personId: person.id,
              sourceId: product.id,
              bankId: bank.id,
              title: product.title,
              subtitle:
                  '${person.name} · ${bank.userWrittenName} · ${product.displayKind}',
              amount: product.dueAmountAt(reference),
              dueDate: product.effectiveDueDateAt(reference),
              status: product.statusAt(reference),
              overdueDays: product.overdueDaysAt(reference),
            ),
          );
        }
      }
      for (final debt in person.personalDebts) {
        items.add(
          RecordReference(
            type: RecordType.personalDebt,
            personId: person.id,
            sourceId: debt.id,
            title: debt.title,
            subtitle:
                '${person.name} · ${debt.creditorType.label} · ${debt.displayCreditor}',
            amount: debt.effectiveDueAmount,
            dueDate: debt.effectiveDueDate,
            status: debt.statusAt(reference),
            overdueDays: debt.statusAt(reference) == PaymentStatus.overdue
                ? _dateOnly(
                    reference,
                  ).difference(_dateOnly(debt.effectiveDueDate)).inDays
                : 0,
          ),
        );
      }
      for (final bill in person.bills) {
        items.add(
          RecordReference(
            type: RecordType.bill,
            personId: person.id,
            sourceId: bill.id,
            title: bill.kind.label,
            subtitle: '${person.name} · ${bill.institutionName}',
            amount: bill.statusAt(reference) == PaymentStatus.overdue
                ? bill.outstandingAmountAt(reference)
                : bill.dueAmountAt(reference),
            dueDate: bill.effectiveDueDateAt(reference),
            status: bill.statusAt(reference),
            overdueDays: bill.overdueDaysAt(reference),
          ),
        );
      }
      for (final subscription in person.subscriptions) {
        items.add(
          RecordReference(
            type: RecordType.subscription,
            personId: person.id,
            sourceId: subscription.id,
            title: subscription.title,
            subtitle: '${person.name} · ${subscription.providerName}',
            amount: subscription.remainingAmount,
            dueDate: subscription.nextDueDate,
            status: subscription.statusAt(reference),
            overdueDays:
                subscription.statusAt(reference) == PaymentStatus.overdue
                ? _dateOnly(
                    reference,
                  ).difference(_dateOnly(subscription.nextDueDate)).inDays
                : 0,
          ),
        );
      }
      for (final rent in person.rents) {
        items.add(
          RecordReference(
            type: RecordType.rent,
            personId: person.id,
            sourceId: rent.id,
            title: rent.title,
            subtitle: '${person.name} · ${rent.receiverName}',
            amount: rent.statusAt(reference) == PaymentStatus.overdue
                ? rent.outstandingAmountAt(reference)
                : rent.dueAmountAt(reference),
            dueDate: rent.effectiveDueDateAt(reference),
            status: rent.statusAt(reference),
            overdueDays: rent.overdueDaysAt(reference),
          ),
        );
      }
    }
    return items;
  }

  double expenseTotalForCategory(
    String categoryId, {
    Iterable<ExpenseItem>? source,
  }) {
    return (source ?? expenses)
        .where((item) => item.categoryId == categoryId)
        .fold<double>(0.0, (sum, item) => sum + item.totalAmount);
  }

  List<ExpenseItem> expensesForCategory(String categoryId) {
    final result = expenses
        .where((item) => item.categoryId == categoryId)
        .toList(growable: false);
    return result..sort((a, b) => b.spentAt.compareTo(a.spentAt));
  }

  MizanState copyWith({
    List<PersonAccount>? people,
    List<ExpenseCategory>? expenseCategories,
    List<ExpenseItem>? expenses,
    List<NotificationSlot>? notificationSlots,
    List<NotificationSlot>? paymentNotificationSlots,
    List<IncomeEntry>? incomes,
    bool? notificationsEnabled,
    PaymentReminderFrequency? paymentReminderFrequency,
    NotificationSoundMode? notificationSoundMode,
    bool? notificationVibrationEnabled,
    bool? setupCompleted,
    String? appLanguageTag,
    String? debtRegionCountryCode,
    String? defaultCurrencyCode,
    List<String>? recentCurrencyCodes,
    int? schemaVersion,
  }) {
    return MizanState(
      people: people ?? this.people,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      expenses: expenses ?? this.expenses,
      notificationSlots: notificationSlots ?? this.notificationSlots,
      paymentNotificationSlots:
          paymentNotificationSlots ??
          (paymentReminderFrequency == null
              ? this.paymentNotificationSlots
              : defaultPaymentNotificationSlotsFor(paymentReminderFrequency)),
      incomes: incomes ?? this.incomes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      paymentReminderFrequency:
          paymentReminderFrequency ?? this.paymentReminderFrequency,
      notificationSoundMode:
          notificationSoundMode ?? this.notificationSoundMode,
      notificationVibrationEnabled:
          notificationVibrationEnabled ?? this.notificationVibrationEnabled,
      setupCompleted: setupCompleted ?? this.setupCompleted,
      appLanguageTag: appLanguageTag ?? this.appLanguageTag,
      debtRegionCountryCode:
          debtRegionCountryCode ?? this.debtRegionCountryCode,
      defaultCurrencyCode: defaultCurrencyCode ?? this.defaultCurrencyCode,
      recentCurrencyCodes: recentCurrencyCodes ?? this.recentCurrencyCodes,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'people': people.map((item) => item.toJson()).toList(),
    'expenseCategories': expenseCategories
        .map((item) => item.toJson())
        .toList(),
    'expenses': expenses.map((item) => item.toJson()).toList(),
    'notificationSlots': notificationSlots
        .map((item) => item.toJson())
        .toList(),
    'paymentNotificationSlots': paymentNotificationSlots
        .map((item) => item.toJson())
        .toList(),
    'incomes': incomes.map((item) => item.toJson()).toList(),
    'notificationsEnabled': notificationsEnabled,
    'paymentReminderFrequency': paymentReminderFrequency.name,
    'notificationSoundMode': notificationSoundMode.name,
    'notificationVibrationEnabled': notificationVibrationEnabled,
    'setupCompleted': setupCompleted,
    'appLanguageTag': appLanguageTag,
    'debtRegionCountryCode': debtRegionCountryCode,
    'defaultCurrencyCode': defaultCurrencyCode,
    'recentCurrencyCodes': recentCurrencyCodes,
  };

  factory MizanState.fromJson(Map<String, dynamic> json) {
    final slots = ((json['notificationSlots'] as List?) ?? const [])
        .whereType<Map>()
        .map(
          (item) => NotificationSlot.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final paymentSlots =
        ((json['paymentNotificationSlots'] as List?) ?? const [])
            .whereType<Map>()
            .map(
              (item) =>
                  NotificationSlot.fromJson(Map<String, dynamic>.from(item)),
            )
            .take(10)
            .toList(growable: false);
    final legacyFrequency = PaymentReminderFrequency.values.firstWhere(
      (item) => item.name == _string(json['paymentReminderFrequency']),
      orElse: () => PaymentReminderFrequency.twiceDaily,
    );
    final hasGlobalProfile =
        json.containsKey('setupCompleted') ||
        json.containsKey('appLanguageTag') ||
        json.containsKey('debtRegionCountryCode') ||
        json.containsKey('defaultCurrencyCode');
    final recentCurrencies =
        ((json['recentCurrencyCodes'] as List?) ?? const [])
            .map((item) => item.toString().trim().toUpperCase())
            .where((item) => item.length == 3)
            .toSet()
            .take(8)
            .toList(growable: false);
    return MizanState(
      schemaVersion: _intOrNull(json['schemaVersion']) ?? 1,
      people: ((json['people'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => PersonAccount.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      expenseCategories: ((json['expenseCategories'] as List?) ?? const [])
          .whereType<Map>()
          .map(
            (item) => ExpenseCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      expenses: ((json['expenses'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => ExpenseItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      notificationSlots: slots.isEmpty ? defaultNotificationSlots : slots,
      paymentNotificationSlots: paymentSlots.isEmpty
          ? defaultPaymentNotificationSlotsFor(legacyFrequency)
          : paymentSlots,
      incomes: ((json['incomes'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => IncomeEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      paymentReminderFrequency: legacyFrequency,
      notificationSoundMode: NotificationSoundMode.values.firstWhere(
        (item) => item.name == _string(json['notificationSoundMode']),
        orElse: () => NotificationSoundMode.system,
      ),
      notificationVibrationEnabled:
          json['notificationVibrationEnabled'] as bool? ?? true,
      setupCompleted: hasGlobalProfile
          ? json['setupCompleted'] as bool? ?? false
          : true,
      appLanguageTag: hasGlobalProfile
          ? MizanI18n.normalizeLanguageTag(_string(json['appLanguageTag']))
          : 'tr',
      debtRegionCountryCode: _string(
        json['debtRegionCountryCode'],
        fallback: hasGlobalProfile ? '' : 'TR',
      ).toUpperCase(),
      defaultCurrencyCode: _string(
        json['defaultCurrencyCode'],
        fallback: hasGlobalProfile ? '' : 'TRY',
      ).toUpperCase(),
      recentCurrencyCodes: recentCurrencies,
    ).copyWith(schemaVersion: currentSchemaVersion);
  }

  factory MizanState.empty() => const MizanState(
    people: [],
    expenseCategories: [],
    expenses: [],
    notificationSlots: defaultNotificationSlots,
    paymentNotificationSlots: defaultPaymentNotificationSlots,
    incomes: [],
  );

  factory MizanState.freshInstall() => const MizanState(
    people: [],
    expenseCategories: [],
    expenses: [],
    notificationSlots: defaultNotificationSlots,
    paymentNotificationSlots: defaultPaymentNotificationSlots,
    incomes: [],
    setupCompleted: false,
    appLanguageTag: '',
    debtRegionCountryCode: '',
    defaultCurrencyCode: '',
  );

  factory MizanState.seed() => MizanState.empty();
}

const List<NotificationSlot> defaultNotificationSlots = [
  NotificationSlot(
    id: 'morning',
    label: 'Sabah gider',
    hour: 7,
    minute: 0,
    message: 'Bugünkü giderlerini işlemeyi unutma.',
  ),
  NotificationSlot(
    id: 'noon',
    label: 'Öğlen gider',
    hour: 12,
    minute: 0,
    message: 'Öğlene kadar yaptığın harcamaları ekleyebilirsin.',
  ),
  NotificationSlot(
    id: 'evening',
    label: 'Akşam gider',
    hour: 21,
    minute: 0,
    message: 'Günü kapatmadan giderlerini kontrol et.',
  ),
];

const List<NotificationSlot> defaultPaymentNotificationSlots = [
  NotificationSlot(
    id: 'payment-1',
    label: 'Ödeme hatırlatması 1',
    hour: 9,
    minute: 0,
    message: 'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
  ),
  NotificationSlot(
    id: 'payment-2',
    label: 'Ödeme hatırlatması 2',
    hour: 18,
    minute: 0,
    message: 'Günün ödeme planını gözden geçir.',
  ),
];

List<NotificationSlot> defaultPaymentNotificationSlotsFor(
  PaymentReminderFrequency frequency,
) {
  final hours = switch (frequency) {
    PaymentReminderFrequency.onceDaily => const [10],
    PaymentReminderFrequency.twiceDaily => const [9, 18],
    PaymentReminderFrequency.threeTimesDaily => const [9, 14, 20],
  };
  return [
    for (var index = 0; index < hours.length; index++)
      NotificationSlot(
        id: 'payment-${index + 1}',
        label: 'Ödeme hatırlatması ${index + 1}',
        hour: hours[index],
        minute: 0,
        message: 'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
      ),
  ];
}

List<PaymentRecord> _paymentList(dynamic value) =>
    ((value as List?) ?? const [])
        .whereType<Map>()
        .map((item) => PaymentRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

List<RecordNote> _noteList(dynamic value) => ((value as List?) ?? const [])
    .whereType<Map>()
    .map((item) => RecordNote.fromJson(Map<String, dynamic>.from(item)))
    .toList(growable: false);

MizanState hydrateLegacyOverdueAnchors(MizanState state, DateTime recordedAt) {
  final anchorDate = DateTime(
    recordedAt.year,
    recordedAt.month,
    recordedAt.day,
  );
  return state.copyWith(
    schemaVersion: currentSchemaVersion,
    people: state.people
        .map(
          (person) => person.copyWith(
            banks: person.banks
                .map(
                  (bank) => bank.copyWith(
                    products: bank.products
                        .map((debt) {
                          final days = debt.manualOverdueDays;
                          if (days == null ||
                              days <= 0 ||
                              debt.manualOverdueSince != null) {
                            return debt;
                          }
                          return debt.copyWith(
                            manualOverdueRecordedAt: anchorDate,
                            manualOverdueSince: anchorDate.subtract(
                              Duration(days: days),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false),
  );
}
