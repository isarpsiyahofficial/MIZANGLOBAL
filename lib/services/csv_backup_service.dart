import 'dart:convert';

import 'package:csv/csv.dart';

import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';

class CsvMergeResult {
  const CsvMergeResult({
    required this.state,
    required this.addedCount,
    required this.mergedCount,
    required this.duplicateCount,
  });

  final MizanState state;
  final int addedCount;
  final int mergedCount;
  final int duplicateCount;
}

class _MergeTracker {
  int added = 0;
  int merged = 0;
  int duplicate = 0;
}

class CsvBackupService {
  const CsvBackupService();

  static const formatName = 'MIZAN_CSV_BACKUP';
  static final CsvCodec _codec = CsvCodec();

  String exportState(MizanState state) {
    final safeState = state.copyWith(schemaVersion: currentSchemaVersion);
    final now = DateTime.now();
    final rows = <List<dynamic>>[
      const [
        'format',
        'schema_version',
        'entity_type',
        'entity_id',
        'person_id',
        'bank_id',
        'record_type',
        'record_id',
        'name',
        'amount',
        'date',
        'data_json',
      ],
      [
        formatName,
        currentSchemaVersion,
        'snapshot',
        'state',
        '',
        '',
        '',
        '',
        MizanI18n.text('MİZAN tam yedek'),
        '',
        DateTime.now().toUtc().toIso8601String(),
        jsonEncode(safeState.toJson()),
      ],
    ];

    for (final person in safeState.people) {
      rows.add(
        _row(
          'person',
          person.id,
          person.name,
          person.toJson(),
          personId: person.id,
        ),
      );
      for (final bank in person.banks) {
        rows.add(
          _row(
            'bank_group',
            bank.id,
            bank.userWrittenName,
            bank.toJson(),
            personId: person.id,
            bankId: bank.id,
            amount: bank.totalDebt,
          ),
        );
        for (final debt in bank.products) {
          rows.add(
            _row(
              'bank_debt',
              debt.id,
              debt.title,
              debt.toJson(),
              personId: person.id,
              bankId: bank.id,
              recordType: RecordType.debt.name,
              recordId: debt.id,
              amount: debt.remainingAmount,
              date: debt.dueDate,
            ),
          );
          _children(
            rows,
            person.id,
            bank.id,
            RecordType.debt.name,
            debt.id,
            debt.payments,
            debt.notes,
          );
        }
      }
      for (final debt in person.personalDebts) {
        rows.add(
          _row(
            'personal_corporate_debt',
            debt.id,
            debt.title,
            debt.toJson(),
            personId: person.id,
            recordType: RecordType.personalDebt.name,
            recordId: debt.id,
            amount: debt.remainingAmount,
            date: debt.effectiveDueDate,
          ),
        );
        _children(
          rows,
          person.id,
          '',
          RecordType.personalDebt.name,
          debt.id,
          debt.payments,
          debt.notes,
        );
      }
      for (final bill in person.bills) {
        rows.add(
          _row(
            'bill',
            bill.id,
            '${bill.kind.label} - ${bill.institutionName}',
            bill.toJson(),
            personId: person.id,
            recordType: RecordType.bill.name,
            recordId: bill.id,
            amount: bill.outstandingAmountAt(now),
            date: bill.effectiveDueDateAt(now),
          ),
        );
        _children(
          rows,
          person.id,
          '',
          RecordType.bill.name,
          bill.id,
          bill.payments,
          bill.notes,
        );
      }
      for (final subscription in person.subscriptions) {
        rows.add(
          _row(
            'subscription',
            subscription.id,
            subscription.title,
            subscription.toJson(),
            personId: person.id,
            recordType: RecordType.subscription.name,
            recordId: subscription.id,
            amount: subscription.remainingAmount,
            date: subscription.nextDueDate,
          ),
        );
        _children(
          rows,
          person.id,
          '',
          RecordType.subscription.name,
          subscription.id,
          subscription.payments,
          subscription.notes,
        );
      }
      for (final rent in person.rents) {
        rows.add(
          _row(
            'rent_installment',
            rent.id,
            rent.title,
            rent.toJson(),
            personId: person.id,
            recordType: RecordType.rent.name,
            recordId: rent.id,
            amount: rent.outstandingAmountAt(now),
            date: rent.effectiveDueDateAt(now),
          ),
        );
        _children(
          rows,
          person.id,
          '',
          RecordType.rent.name,
          rent.id,
          rent.payments,
          rent.notes,
        );
      }
    }
    for (final slot in safeState.paymentNotificationSlots) {
      rows.add(
        _row('payment_notification_slot', slot.id, slot.label, slot.toJson()),
      );
    }
    for (final income in safeState.incomes) {
      rows.add(
        _row(
          'income',
          income.id,
          income.title,
          income.toJson(),
          amount: income.amount,
          date: income.startDate,
        ),
      );
    }
    for (final category in safeState.expenseCategories) {
      rows.add(
        _row('expense_category', category.id, category.name, category.toJson()),
      );
    }
    for (final expense in safeState.expenses) {
      rows.add(
        _row(
          'expense',
          expense.id,
          expense.name,
          expense.toJson(),
          recordId: expense.categoryId,
          amount: expense.totalAmount,
          date: expense.spentAt,
        ),
      );
    }
    return _codec.encode(rows);
  }

  MizanState importState(String content) {
    final rows = _codec.decode(content);
    if (rows.length < 2) {
      throw FormatException(MizanI18n.text('CSV yedeği boş veya eksik.'));
    }
    final header = rows.first.map((value) => value.toString()).toList();
    final formatIndex = header.indexOf('format');
    final typeIndex = header.indexOf('entity_type');
    final dataIndex = header.indexOf('data_json');
    final dateIndex = header.indexOf('date');
    if (formatIndex < 0 || typeIndex < 0 || dataIndex < 0) {
      throw FormatException(MizanI18n.text('Bu dosya MİZAN CSV yedeği değil.'));
    }
    for (final row in rows.skip(1)) {
      if (row.length <= dataIndex) {
        continue;
      }
      if (row[formatIndex].toString() != formatName ||
          row[typeIndex].toString() != 'snapshot') {
        continue;
      }
      final decoded = jsonDecode(row[dataIndex].toString());
      if (decoded is! Map) {
        throw FormatException(MizanI18n.text('CSV tam yedek verisi geçersiz.'));
      }
      final backupCreatedAt = dateIndex >= 0 && row.length > dateIndex
          ? DateTime.tryParse(row[dateIndex].toString())?.toLocal()
          : null;
      return hydrateLegacyOverdueAnchors(
        MizanState.fromJson(Map<String, dynamic>.from(decoded)),
        backupCreatedAt ?? DateTime.now(),
      );
    }
    throw FormatException(
      MizanI18n.text('CSV içinde tam MİZAN yedeği bulunamadı.'),
    );
  }

  CsvMergeResult mergeStates(MizanState current, MizanState imported) {
    final tracker = _MergeTracker();
    var userDuplicateCount = 0;
    final currentJson = _cloneMap(current.toJson());
    final importedJson = _cloneMap(imported.toJson());

    if (!current.setupCompleted && imported.setupCompleted) {
      currentJson['setupCompleted'] = true;
      currentJson['appLanguageTag'] = imported.appLanguageTag;
      currentJson['debtRegionCountryCode'] = imported.debtRegionCountryCode;
      currentJson['defaultCurrencyCode'] = imported.defaultCurrencyCode;
      currentJson['recentCurrencyCodes'] = imported.recentCurrencyCodes;
    }

    var duplicateCheckpoint = tracker.duplicate;
    currentJson['people'] = _mergeEntities(
      _maps(currentJson['people']),
      _maps(importedJson['people']),
      tracker,
      fingerprint: (item) => _normalize(item['name']),
      merge: _mergePerson,
    );
    userDuplicateCount += tracker.duplicate - duplicateCheckpoint;

    final categoryIdMap = <String, String>{};
    final currentCategories = _maps(
      currentJson['expenseCategories'],
    ).map(_cloneMap).toList(growable: true);
    for (final importedCategory in _maps(importedJson['expenseCategories'])) {
      final importedId = _text(importedCategory['id']);
      final importedName = _normalize(importedCategory['name']);
      final matchIndex = currentCategories.indexWhere((item) {
        final sameId = importedId.isNotEmpty && _text(item['id']) == importedId;
        final sameName =
            importedName.isNotEmpty && _normalize(item['name']) == importedName;
        return sameId || sameName;
      });
      if (matchIndex >= 0) {
        categoryIdMap[importedId] = _text(currentCategories[matchIndex]['id']);
        tracker.duplicate++;
      } else {
        final added = _cloneMap(importedCategory);
        currentCategories.add(added);
        categoryIdMap[importedId] = _text(added['id']);
        tracker.added++;
      }
    }
    currentJson['expenseCategories'] = currentCategories;

    final importedExpenses = _maps(importedJson['expenses']).map((item) {
      final copy = _cloneMap(item);
      final importedCategoryId = _text(copy['categoryId']);
      copy['categoryId'] =
          categoryIdMap[importedCategoryId] ?? importedCategoryId;
      return copy;
    }).toList(growable: false);
    duplicateCheckpoint = tracker.duplicate;
    currentJson['expenses'] = _mergeEntities(
      _maps(currentJson['expenses']),
      importedExpenses,
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'categoryId',
        'name',
        'quantity',
        'unitPrice',
        'spentAt',
        'note',
      ]),
    );
    userDuplicateCount += tracker.duplicate - duplicateCheckpoint;

    duplicateCheckpoint = tracker.duplicate;
    currentJson['incomes'] = _mergeEntities(
      _maps(currentJson['incomes']),
      _maps(importedJson['incomes']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'title',
        'amount',
        'frequency',
        'startDate',
        'note',
      ]),
      merge: _mergeIncome,
    );
    userDuplicateCount += tracker.duplicate - duplicateCheckpoint;

    currentJson['notificationSlots'] = _mergeEntities(
      _maps(currentJson['notificationSlots']),
      _maps(importedJson['notificationSlots']),
      tracker,
      fingerprint: _slotFingerprint,
    );
    final mergedPaymentSlots = _mergeEntities(
      _maps(currentJson['paymentNotificationSlots']),
      _maps(importedJson['paymentNotificationSlots']),
      tracker,
      fingerprint: _slotFingerprint,
    );
    if (mergedPaymentSlots.length > 10) {
      final overflow = mergedPaymentSlots.length - 10;
      tracker.added =
          (tracker.added - overflow).clamp(0, tracker.added).toInt();
      tracker.duplicate += overflow;
    }
    currentJson['paymentNotificationSlots'] =
        mergedPaymentSlots.take(10).toList(growable: false);

    currentJson['schemaVersion'] = currentSchemaVersion;
    final mergedState = MizanState.fromJson(
      currentJson,
    ).copyWith(schemaVersion: currentSchemaVersion);
    return CsvMergeResult(
      state: mergedState,
      addedCount: tracker.added,
      mergedCount: tracker.merged,
      duplicateCount: userDuplicateCount,
    );
  }

  Map<String, dynamic> _mergePerson(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _cloneMap(current);
    result['banks'] = _mergeEntities(
      _maps(current['banks']),
      _maps(imported['banks']),
      tracker,
      fingerprint: (item) => _normalize(item['userWrittenName']),
      merge: _mergeBank,
    );
    result['personalDebts'] = _mergeEntities(
      _maps(current['personalDebts']),
      _maps(imported['personalDebts']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'creditorType',
        'title',
        'creditorName',
        'totalAmount',
        'debtDate',
        'dueDate',
        'frequency',
      ]),
      merge: _mergePersonalDebt,
    );
    result['bills'] = _mergeEntities(
      _maps(current['bills']),
      _maps(imported['bills']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'kind',
        'institutionName',
        'subscriberNumber',
        'amount',
        'dueDate',
      ]),
      merge: _mergeRecordChildren,
    );
    result['subscriptions'] = _mergeEntities(
      _maps(current['subscriptions']),
      _maps(imported['subscriptions']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'kind',
        'title',
        'providerName',
        'amount',
        'frequency',
        'nextDueDate',
      ]),
      merge: _mergeRecordChildren,
    );
    result['rents'] = _mergeEntities(
      _maps(current['rents']),
      _maps(imported['rents']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'title',
        'receiverName',
        'amount',
        'paymentDay',
        'dueDate',
      ]),
      merge: _mergeRecordChildren,
    );
    return result;
  }

  Map<String, dynamic> _mergeBank(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _cloneMap(current);
    result['products'] = _mergeEntities(
      _maps(current['products']),
      _maps(imported['products']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'kind',
        'title',
        'customKindName',
        'totalAmount',
        'monthlyAmount',
        'dueDate',
        'dueMode',
        'dueDayOfMonth',
      ]),
      merge: _mergeDebt,
    );
    return result;
  }

  Map<String, dynamic> _mergeDebt(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _mergeRecordChildren(current, imported, tracker);
    final months = <String, String>{};
    for (final value in [
      ...((current['manualOverduePeriods'] as List?) ?? const []),
      ...((imported['manualOverduePeriods'] as List?) ?? const []),
    ]) {
      final parsed = DateTime.tryParse(value.toString());
      if (parsed == null) continue;
      final month = DateTime(parsed.year, parsed.month);
      months['${month.year}-${month.month}'] = month.toIso8601String();
    }
    result['manualOverduePeriods'] = months.values.toList()..sort();

    final currentSince = DateTime.tryParse(
      _text(current['manualOverdueSince']),
    );
    final importedSince = DateTime.tryParse(
      _text(imported['manualOverdueSince']),
    );
    if ((currentSince == null && importedSince != null) ||
        (currentSince != null &&
            importedSince != null &&
            importedSince.isBefore(currentSince))) {
      result['manualOverdueSince'] = imported['manualOverdueSince'];
      result['manualOverdueRecordedAt'] = imported['manualOverdueRecordedAt'];
      result['manualOverdueDays'] = imported['manualOverdueDays'];
    } else {
      result['manualOverdueSince'] = current['manualOverdueSince'];
      result['manualOverdueRecordedAt'] = current['manualOverdueRecordedAt'];
      result['manualOverdueDays'] = current['manualOverdueDays'];
    }
    return result;
  }

  Map<String, dynamic> _mergePersonalDebt(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _mergeRecordChildren(current, imported, tracker);
    result['schedule'] = _mergeEntities(
      _maps(current['schedule']),
      _maps(imported['schedule']),
      tracker,
      fingerprint: (item) =>
          _fingerprint(item, const ['label', 'amount', 'dueDate']),
    );
    return result;
  }

  Map<String, dynamic> _mergeIncome(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _cloneMap(current);
    result['receipts'] = _mergeEntities(
      _maps(current['receipts']),
      _maps(imported['receipts']),
      tracker,
      fingerprint: (item) =>
          _fingerprint(item, const ['scheduledDate', 'receivedDate']),
    );
    return result;
  }

  Map<String, dynamic> _mergeRecordChildren(
    Map<String, dynamic> current,
    Map<String, dynamic> imported,
    _MergeTracker tracker,
  ) {
    final result = _cloneMap(current);
    result['payments'] = _mergeEntities(
      _maps(current['payments']),
      _maps(imported['payments']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const [
        'amount',
        'paidAt',
        'method',
        'entryType',
        'appliesToDueDate',
        'note',
      ]),
    );
    result['notes'] = _mergeEntities(
      _maps(current['notes']),
      _maps(imported['notes']),
      tracker,
      fingerprint: (item) => _fingerprint(item, const ['text', 'createdAt']),
    );
    return result;
  }

  List<Map<String, dynamic>> _mergeEntities(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> imported,
    _MergeTracker tracker, {
    required String Function(Map<String, dynamic>) fingerprint,
    Map<String, dynamic> Function(
      Map<String, dynamic>,
      Map<String, dynamic>,
      _MergeTracker,
    )? merge,
  }) {
    final result = current.map(_cloneMap).toList(growable: true);
    for (final importedItem in imported) {
      final importedId = _text(importedItem['id']);
      var matchIndex = importedId.isEmpty
          ? -1
          : result.indexWhere((item) => _text(item['id']) == importedId);
      if (matchIndex < 0 && importedId.isEmpty) {
        final importedFingerprint = fingerprint(importedItem);
        if (importedFingerprint.isNotEmpty) {
          matchIndex = result.indexWhere(
            (item) => fingerprint(item) == importedFingerprint,
          );
        }
      }
      if (matchIndex < 0) {
        result.add(_cloneMap(importedItem));
        tracker.added++;
        continue;
      }
      if (merge == null) {
        tracker.duplicate++;
        continue;
      }
      final before = jsonEncode(result[matchIndex]);
      final combined = merge(result[matchIndex], importedItem, tracker);
      result[matchIndex] = combined;
      if (jsonEncode(combined) == before) {
        tracker.duplicate++;
      } else {
        tracker.merged++;
      }
    }
    return result;
  }

  String _slotFingerprint(Map<String, dynamic> item) => _fingerprint(
        item,
        const ['label', 'hour', 'minute', 'message', 'presentationMode'],
      );

  String _fingerprint(Map<String, dynamic> item, List<String> keys) =>
      keys.map((key) => _normalize(item[key])).join('|');

  String _normalize(dynamic value) =>
      value?.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ??
      '';

  String _text(dynamic value) => value?.toString() ?? '';

  List<Map<String, dynamic>> _maps(dynamic value) =>
      ((value as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);

  Map<String, dynamic> _cloneMap(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);

  void _children(
    List<List<dynamic>> rows,
    String personId,
    String bankId,
    String type,
    String sourceId,
    List<PaymentRecord> payments,
    List<RecordNote> notes,
  ) {
    for (final payment in payments) {
      rows.add(
        _row(
          'payment',
          payment.id,
          payment.method.isEmpty ? 'Ödeme' : payment.method,
          payment.toJson(),
          personId: personId,
          bankId: bankId,
          recordType: type,
          recordId: sourceId,
          amount: payment.amount,
          date: payment.paidAt,
        ),
      );
    }
    for (final note in notes) {
      rows.add(
        _row(
          'note',
          note.id,
          note.text,
          note.toJson(),
          personId: personId,
          bankId: bankId,
          recordType: type,
          recordId: sourceId,
          date: note.createdAt,
        ),
      );
    }
  }

  List<dynamic> _row(
    String type,
    String id,
    String name,
    Map<String, dynamic> data, {
    String personId = '',
    String bankId = '',
    String recordType = '',
    String recordId = '',
    double? amount,
    DateTime? date,
  }) =>
      [
        formatName,
        currentSchemaVersion,
        type,
        id,
        personId,
        bankId,
        recordType,
        recordId,
        name,
        amount ?? '',
        date?.toIso8601String() ?? '',
        jsonEncode(data),
      ];
}
