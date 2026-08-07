import 'package:flutter/foundation.dart';

import '../core/formatters.dart';
import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';
import '../services/local_store.dart';
import '../services/notification_service.dart';

class MizanController extends ChangeNotifier {
  MizanController(
    this._store, {
    this._scheduler = const NoopReminderScheduler(),
    this.onLanguageChanged,
  });

  final MizanStore _store;
  final ReminderScheduler _scheduler;

  /// Called only after a changed language preference has been validated and
  /// durably saved. The UI uses this signal to rebuild the full app tree.
  VoidCallback? onLanguageChanged;

  MizanState _state = MizanState.empty();
  bool _isReady = false;
  bool _isBusy = false;
  bool _storageReady = false;
  String? _lastError;
  String? _loadMessage;
  NotificationHealth _notificationHealth = const NotificationHealth();
  Future<void> _notificationSyncQueue = Future<void>.value();
  final Expando<int> _notificationFingerprintCache = Expando<int>(
    'mizan-notification-fingerprint',
  );

  MizanState get state => _state;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  bool get storageReady => _storageReady;
  String? get lastError => _lastError;
  String? get loadMessage => _loadMessage;
  NotificationHealth get notificationHealth => _notificationHealth;

  Future<void> load() async {
    _isBusy = true;
    notifyListeners();

    String? notificationWarning;
    try {
      await _scheduler.initialize();
      _notificationHealth = await _scheduler.requestPermissions();
    } on Object catch (error) {
      notificationWarning =
          'Bildirim izni veya zamanlama servisi açılamadı: ${_friendlyError(error)}';
    }

    try {
      final result = await _store.load();
      _state = result.state;
      MizanI18n.setProfile(
        languageTag: _state.appLanguageTag,
        currencyCode: _state.defaultCurrencyCode,
      );
      _storageReady = true;
      _loadMessage = result.message;
      _lastError = notificationWarning;

      await _synchronizeNotifications(
        _state,
        requestMissingPermissions: false,
        surfaceErrors: true,
      );
    } on Object catch (error) {
      _storageReady = false;
      _state = MizanState.empty();
      _lastError =
          '${_friendlyError(error)} Mevcut kayıt dosyaları korunuyor; CSV yedeği geri yüklenmeden yeni kayıt yazılmayacak.';
    } finally {
      _isBusy = false;
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> _commit(
    MizanState next, {
    bool reschedule = true,
    bool requestMissingNotificationPermissions = false,
    bool allowStorageRecovery = false,
  }) async {
    if (!_storageReady && !allowStorageRecovery) {
      throw StateError(
        'Yerel kayıt alanı güvenli biçimde açılamadı. Mevcut dosyaları korumak için yeni veri yazımı durduruldu.',
      );
    }
    final notificationPlanChanged =
        reschedule &&
        _notificationFingerprint(_state) != _notificationFingerprint(next);
    _isBusy = true;
    _lastError = null;
    notifyListeners();
    try {
      _validateState(next);
      await _store.save(next);
      _state = next;
      MizanI18n.setProfile(
        languageTag: _state.appLanguageTag,
        currencyCode: _state.defaultCurrencyCode,
      );
      _storageReady = true;
      if (reschedule && notificationPlanChanged) {
        await _synchronizeNotifications(
          next,
          requestMissingPermissions: requestMissingNotificationPermissions,
          surfaceErrors: true,
        );
      }
    } on Object catch (error) {
      _lastError = _friendlyError(error);
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  int _notificationFingerprint(MizanState state) {
    final cached = _notificationFingerprintCache[state];
    if (cached != null) return cached;

    var hash = Object.hash(
      state.notificationsEnabled,
      state.notificationSoundMode,
      state.notificationVibrationEnabled,
      MizanI18n.normalizeLanguageTag(state.appLanguageTag),
    );
    for (final slot in <NotificationSlot>[
      ...state.notificationSlots,
      ...state.paymentNotificationSlots,
    ]) {
      hash = Object.hash(
        hash,
        slot.id,
        slot.enabled,
        slot.hour,
        slot.minute,
        slot.label,
        slot.message,
      );
    }
    final records = state.recordReferencesAt(DateTime.now())
      ..sort((a, b) {
        final typeOrder = a.type.index.compareTo(b.type.index);
        if (typeOrder != 0) return typeOrder;
        final personOrder = a.personId.compareTo(b.personId);
        if (personOrder != 0) return personOrder;
        final bankOrder = (a.bankId ?? '').compareTo(b.bankId ?? '');
        if (bankOrder != 0) return bankOrder;
        return a.sourceId.compareTo(b.sourceId);
      });
    for (final record in records) {
      hash = Object.hash(
        hash,
        record.type,
        record.personId,
        record.bankId,
        record.sourceId,
        record.amount.toStringAsFixed(2),
        record.dueDate.millisecondsSinceEpoch,
        record.status,
        record.title,
        record.subtitle,
      );
    }
    _notificationFingerprintCache[state] = hash;
    return hash;
  }

  Future<void> _synchronizeNotifications(
    MizanState state, {
    required bool requestMissingPermissions,
    required bool surfaceErrors,
  }) {
    _notificationSyncQueue = _notificationSyncQueue.then((_) async {
      try {
        var health = await _scheduler.health();
        if (state.notificationsEnabled &&
            requestMissingPermissions &&
            (!health.permissionGranted || !health.preciseTimingGranted)) {
          health = await _scheduler.requestPermissions();
        }
        _notificationHealth = health;
        if (state.notificationsEnabled && !health.permissionGranted) {
          if (surfaceErrors) {
            _lastError =
                'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.';
          }
          return;
        }
        await _scheduler.reschedule(state);
        _notificationHealth = await _scheduler.health();
        if (surfaceErrors) _lastError = null;
      } on Object catch (error) {
        if (surfaceErrors) {
          _lastError =
              'Kayıt yapıldı ancak bildirimler otomatik senkronize edilemedi: ${_friendlyError(error)}';
        }
      }
    });
    return _notificationSyncQueue;
  }

  Future<void> synchronizeNotificationsAfterSystemResume() async {
    await _synchronizeNotifications(
      _state,
      requestMissingPermissions: false,
      surfaceErrors: true,
    );
    notifyListeners();
  }

  void clearMessages() {
    _lastError = null;
    _loadMessage = null;
    notifyListeners();
  }

  Future<void> completeGlobalSetup({
    required String appLanguageTag,
    required String debtRegionCountryCode,
    required String defaultCurrencyCode,
  }) async {
    await updateGlobalPreferences(
      appLanguageTag: appLanguageTag,
      debtRegionCountryCode: debtRegionCountryCode,
      defaultCurrencyCode: defaultCurrencyCode,
      markSetupCompleted: true,
    );
  }

  Future<void> updateGlobalPreferences({
    required String appLanguageTag,
    required String debtRegionCountryCode,
    required String defaultCurrencyCode,
    bool markSetupCompleted = false,
  }) async {
    final previousLanguage = MizanI18n.normalizeLanguageTag(
      _state.appLanguageTag,
    );
    final language = MizanI18n.normalizeLanguageTag(appLanguageTag);
    final country = debtRegionCountryCode.trim().toUpperCase();
    final currency = defaultCurrencyCode.trim().toUpperCase();
    if (!MizanI18n.supportedLanguageTags.contains(language)) {
      throw ArgumentError(
        'Yalnızca tamamen entegre edilmiş bir dil seçilebilir.',
      );
    }
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      throw ArgumentError('Ülke kodu geçersiz.');
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw ArgumentError('Para birimi kodu geçersiz.');
    }
    final recent = <String>[
      currency,
      ..._state.recentCurrencyCodes.where((item) => item != currency),
    ].take(8).toList(growable: false);
    await _commit(
      _state.copyWith(
        setupCompleted: markSetupCompleted || _state.setupCompleted,
        appLanguageTag: language,
        debtRegionCountryCode: country,
        defaultCurrencyCode: currency,
        recentCurrencyCodes: recent,
      ),
      reschedule: language != previousLanguage,
    );
    if (language != previousLanguage) {
      onLanguageChanged?.call();
    }
  }

  Future<void> addPerson(String name) async {
    final clean = _requiredText(name, 'Kişi adı', 80);
    await _commit(
      _state.copyWith(
        people: [
          ..._state.people,
          PersonAccount(id: newId('person'), name: clean),
        ],
      ),
    );
  }

  Future<void> updatePerson({
    required String personId,
    required String name,
  }) async {
    final clean = _requiredText(name, 'Kişi adı', 80);
    _person(personId);
    await _commit(
      _state.copyWith(
        people: _state.people
            .map(
              (person) =>
                  person.id == personId ? person.copyWith(name: clean) : person,
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> deletePerson(String personId) async {
    _person(personId);
    await _commit(
      _state.copyWith(
        people: _state.people.where((person) => person.id != personId).toList(),
      ),
    );
  }

  Future<void> addBankGroup({
    required String personId,
    required String userWrittenName,
  }) async {
    final clean = _requiredText(userWrittenName, 'Banka adı', 100);
    final person = _person(personId);
    _ensureUniqueBankName(person, clean);
    await _commit(
      _replacePerson(
        person.copyWith(
          banks: [
            ...person.banks,
            BankGroup(id: newId('bank'), userWrittenName: clean),
          ],
        ),
      ),
    );
  }

  Future<void> updateBankGroup({
    required String personId,
    required String bankId,
    required String userWrittenName,
  }) async {
    final clean = _requiredText(userWrittenName, 'Banka adı', 100);
    final person = _person(personId);
    _bank(person, bankId);
    _ensureUniqueBankName(person, clean, excludingId: bankId);
    await _commit(
      _replacePerson(
        person.copyWith(
          banks: person.banks
              .map(
                (bank) => bank.id == bankId
                    ? bank.copyWith(userWrittenName: clean)
                    : bank,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deleteBankGroup({
    required String personId,
    required String bankId,
  }) async {
    final person = _person(personId);
    _bank(person, bankId);
    await _commit(
      _replacePerson(
        person.copyWith(
          banks: person.banks.where((bank) => bank.id != bankId).toList(),
        ),
      ),
    );
  }

  Future<void> addDebtProduct({
    required String personId,
    required String bankId,
    required DebtKind kind,
    required String title,
    required double totalAmount,
    required double monthlyAmount,
    required DateTime dueDate,
    DebtDueMode dueMode = DebtDueMode.fixedDate,
    int? dueDayOfMonth,
    String customKindName = '',
    int? installmentCount,
    int? currentInstallment,
    int? manualOverdueDays,
    List<DateTime> manualOverduePeriods = const [],
    double? limit,
    double? usedLimit,
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final bank = _bank(person, bankId);
    final now = DateTime.now();
    final normalizedDueDate = dueMode == DebtDueMode.monthlyDay
        ? _nextMonthlyDueDate(now, dueDayOfMonth!)
        : dueDate;
    final hasManualDays = (manualOverdueDays ?? 0) > 0;
    final debt = _buildDebt(
      id: newId('debt'),
      currencyCode: _recordCurrency(currencyCode),
      kind: kind,
      title: title,
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      dueDate: normalizedDueDate,
      dueMode: dueMode,
      dueDayOfMonth: dueDayOfMonth,
      customKindName: customKindName,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      manualOverdueDays: manualOverdueDays,
      manualOverdueRecordedAt: hasManualDays ? dateOnly(now) : null,
      manualOverdueSince: hasManualDays
          ? dateOnly(now).subtract(Duration(days: manualOverdueDays!))
          : null,
      manualOverduePeriods: manualOverduePeriods,
      limit: limit,
      usedLimit: usedLimit,
      description: description,
    );
    await _commit(
      _replaceBank(person, bank.copyWith(products: [...bank.products, debt])),
    );
  }

  Future<void> updateDebtProduct({
    required String personId,
    required String bankId,
    required String debtId,
    required DebtKind kind,
    required String title,
    required double totalAmount,
    required double monthlyAmount,
    required DateTime dueDate,
    DebtDueMode dueMode = DebtDueMode.fixedDate,
    int? dueDayOfMonth,
    String customKindName = '',
    int? installmentCount,
    int? currentInstallment,
    int? manualOverdueDays,
    bool replaceManualOverdueDays = false,
    List<DateTime> manualOverduePeriods = const [],
    double? limit,
    double? usedLimit,
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final bank = _bank(person, bankId);
    final existing = _debt(bank, debtId);
    final now = DateTime.now();
    final normalizedDueDate = dueMode == DebtDueMode.monthlyDay
        ? existing.dueMode == DebtDueMode.monthlyDay
              ? _dateWithDay(existing.dueDate, dueDayOfMonth!)
              : _nextMonthlyDueDate(now, dueDayOfMonth!)
        : dueDate;
    final effectiveManualDays = replaceManualOverdueDays
        ? manualOverdueDays
        : existing.manualOverdueDays;
    final hasManualDays = (effectiveManualDays ?? 0) > 0;
    final manualRecordedAt = replaceManualOverdueDays
        ? hasManualDays
              ? dateOnly(now)
              : null
        : existing.manualOverdueRecordedAt;
    final manualSince = replaceManualOverdueDays
        ? hasManualDays
              ? dateOnly(now).subtract(Duration(days: effectiveManualDays!))
              : null
        : existing.manualOverdueSince;
    final replacement = _buildDebt(
      id: existing.id,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      kind: kind,
      title: title,
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      dueDate: normalizedDueDate,
      dueMode: dueMode,
      dueDayOfMonth: dueDayOfMonth,
      customKindName: customKindName,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      manualOverdueDays: effectiveManualDays,
      manualOverdueRecordedAt: manualRecordedAt,
      manualOverdueSince: manualSince,
      manualOverduePeriods: manualOverduePeriods,
      limit: limit,
      usedLimit: usedLimit,
      description: description,
      isArchived: existing.isArchived,
      payments: existing.payments,
      notes: existing.notes,
    );
    if (replacement.totalAmount < replacement.paidAmount) {
      throw ArgumentError(
        'Toplam borç, daha önce ödenen tutardan düşük olamaz.',
      );
    }
    await _commit(
      _replaceBank(
        person,
        bank.copyWith(
          products: bank.products
              .map((item) => item.id == debtId ? replacement : item)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deleteDebtProduct({
    required String personId,
    required String bankId,
    required String debtId,
  }) async {
    final person = _person(personId);
    final bank = _bank(person, bankId);
    _debt(bank, debtId);
    await _commit(
      _replaceBank(
        person,
        bank.copyWith(
          products: bank.products.where((item) => item.id != debtId).toList(),
        ),
      ),
    );
  }

  Future<void> setDebtArchived({
    required String personId,
    required String bankId,
    required String debtId,
    required bool archived,
  }) async {
    final person = _person(personId);
    final bank = _bank(person, bankId);
    _debt(bank, debtId);
    await _commit(
      _replaceBank(
        person,
        bank.copyWith(
          products: bank.products
              .map(
                (item) => item.id == debtId
                    ? item.copyWith(isArchived: archived)
                    : item,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> addPersonalDebt({
    required String personId,
    required CreditorType creditorType,
    required String title,
    required String creditorName,
    required double totalAmount,
    required DateTime debtDate,
    required DateTime dueDate,
    required PaymentFrequency frequency,
    bool isInstallment = false,
    int? installmentCount,
    int? currentInstallment,
    double monthlyAmount = 0,
    int? customFrequencyDays,
    String? currencyCode,
    String description = '',
    String chequeNumber = '',
    String issuerName = '',
    String bankInfo = '',
    String promissoryNoteNumber = '',
    int? documentCount,
    int? currentDocument,
    List<DueScheduleItem> schedule = const [],
  }) async {
    final person = _person(personId);
    final debt = _buildPersonalDebt(
      id: newId('personal-debt'),
      currencyCode: _recordCurrency(currencyCode),
      creditorType: creditorType,
      title: title,
      creditorName: creditorName,
      totalAmount: totalAmount,
      debtDate: debtDate,
      dueDate: dueDate,
      frequency: frequency,
      isInstallment: isInstallment,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      monthlyAmount: monthlyAmount,
      customFrequencyDays: customFrequencyDays,
      description: description,
      chequeNumber: chequeNumber,
      issuerName: issuerName,
      bankInfo: bankInfo,
      promissoryNoteNumber: promissoryNoteNumber,
      documentCount: documentCount,
      currentDocument: currentDocument,
      schedule: schedule,
    );
    await _commit(
      _replacePerson(
        person.copyWith(personalDebts: [...person.personalDebts, debt]),
      ),
    );
  }

  Future<void> updatePersonalDebt({
    required String personId,
    required String debtId,
    required CreditorType creditorType,
    required String title,
    required String creditorName,
    required double totalAmount,
    required DateTime debtDate,
    required DateTime dueDate,
    required PaymentFrequency frequency,
    bool isInstallment = false,
    int? installmentCount,
    int? currentInstallment,
    double monthlyAmount = 0,
    int? customFrequencyDays,
    String? currencyCode,
    String description = '',
    String chequeNumber = '',
    String issuerName = '',
    String bankInfo = '',
    String promissoryNoteNumber = '',
    int? documentCount,
    int? currentDocument,
    List<DueScheduleItem> schedule = const [],
  }) async {
    final person = _person(personId);
    final existing = _personalDebt(person, debtId);
    final replacement = _buildPersonalDebt(
      id: existing.id,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      creditorType: creditorType,
      title: title,
      creditorName: creditorName,
      totalAmount: totalAmount,
      debtDate: debtDate,
      dueDate: dueDate,
      frequency: frequency,
      isInstallment: isInstallment,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      monthlyAmount: monthlyAmount,
      customFrequencyDays: customFrequencyDays,
      description: description,
      chequeNumber: chequeNumber,
      issuerName: issuerName,
      bankInfo: bankInfo,
      promissoryNoteNumber: promissoryNoteNumber,
      documentCount: documentCount,
      currentDocument: currentDocument,
      schedule: schedule,
      isArchived: existing.isArchived,
      payments: existing.payments,
      notes: existing.notes,
    );
    if (replacement.totalAmount < replacement.paidAmount) {
      throw ArgumentError(
        'Toplam borç, daha önce ödenen tutardan düşük olamaz.',
      );
    }
    await _commit(
      _replacePerson(
        person.copyWith(
          personalDebts: person.personalDebts
              .map((item) => item.id == debtId ? replacement : item)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deletePersonalDebt({
    required String personId,
    required String debtId,
  }) async {
    final person = _person(personId);
    _personalDebt(person, debtId);
    await _commit(
      _replacePerson(
        person.copyWith(
          personalDebts: person.personalDebts
              .where((item) => item.id != debtId)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> setPersonalDebtArchived({
    required String personId,
    required String debtId,
    required bool archived,
  }) async {
    final person = _person(personId);
    _personalDebt(person, debtId);
    await _commit(
      _replacePerson(
        person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == debtId
                    ? item.copyWith(isArchived: archived)
                    : item,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> addBill({
    required String personId,
    required BillKind kind,
    required String institutionName,
    required double amount,
    required DateTime dueDate,
    BillScheduleMode scheduleMode = BillScheduleMode.oneTime,
    int? paymentDay,
    DateTime? periodMonth,
    double? periodAmount,
    String subscriberNumber = '',
    String contractNumber = '',
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final periods =
        scheduleMode == BillScheduleMode.monthly &&
            periodMonth != null &&
            periodAmount != null
        ? [BillPeriodAmount(month: dateOnly(periodMonth), amount: periodAmount)]
        : const <BillPeriodAmount>[];
    final bill = _buildBill(
      id: newId('bill'),
      currencyCode: _recordCurrency(currencyCode),
      kind: kind,
      institutionName: institutionName,
      amount: amount,
      dueDate: dueDate,
      scheduleMode: scheduleMode,
      paymentDay: paymentDay,
      periodAmounts: periods,
      subscriberNumber: subscriberNumber,
      contractNumber: contractNumber,
      description: description,
    );
    await _commit(
      _replacePerson(person.copyWith(bills: [...person.bills, bill])),
    );
  }

  Future<void> updateBill({
    required String personId,
    required String billId,
    required BillKind kind,
    required String institutionName,
    required double amount,
    required DateTime dueDate,
    BillScheduleMode scheduleMode = BillScheduleMode.oneTime,
    int? paymentDay,
    DateTime? periodMonth,
    double? periodAmount,
    String subscriberNumber = '',
    String contractNumber = '',
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final existing = _bill(person, billId);
    final periods = [...existing.periodAmounts];
    if (scheduleMode == BillScheduleMode.monthly &&
        periodMonth != null &&
        periodAmount != null) {
      final key = periodMonth.year * 100 + periodMonth.month;
      periods.removeWhere(
        (item) => item.month.year * 100 + item.month.month == key,
      );
      periods.add(
        BillPeriodAmount(month: dateOnly(periodMonth), amount: periodAmount),
      );
    }
    final replacement = _buildBill(
      id: existing.id,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      kind: kind,
      institutionName: institutionName,
      amount: amount,
      dueDate: dueDate,
      scheduleMode: scheduleMode,
      paymentDay: paymentDay,
      periodAmounts: scheduleMode == BillScheduleMode.monthly
          ? periods
          : const [],
      subscriberNumber: subscriberNumber,
      contractNumber: contractNumber,
      description: description,
      isArchived: existing.isArchived,
      payments: existing.payments,
      notes: existing.notes,
    );
    if (!replacement.isMonthly && replacement.amount < replacement.paidAmount) {
      throw ArgumentError(
        'Fatura tutarı, daha önce ödenen tutardan düşük olamaz.',
      );
    }
    await _commit(
      _replacePerson(
        person.copyWith(
          bills: person.bills
              .map((item) => item.id == billId ? replacement : item)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deleteBill({
    required String personId,
    required String billId,
  }) async {
    final person = _person(personId);
    _bill(person, billId);
    await _commit(
      _replacePerson(
        person.copyWith(
          bills: person.bills.where((item) => item.id != billId).toList(),
        ),
      ),
    );
  }

  Future<void> setBillArchived({
    required String personId,
    required String billId,
    required bool archived,
  }) async {
    final person = _person(personId);
    _bill(person, billId);
    await _commit(
      _replacePerson(
        person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == billId
                    ? item.copyWith(isArchived: archived)
                    : item,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> addSubscription({
    required String personId,
    required SubscriptionKind kind,
    required String title,
    required String providerName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDueDate,
    String customKindName = '',
    int? customFrequencyDays,
    String subscriberNumber = '',
    String contractNumber = '',
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final subscription = _buildSubscription(
      id: newId('subscription'),
      currencyCode: _recordCurrency(currencyCode),
      kind: kind,
      title: title,
      providerName: providerName,
      amount: amount,
      frequency: frequency,
      nextDueDate: nextDueDate,
      customKindName: customKindName,
      customFrequencyDays: customFrequencyDays,
      subscriberNumber: subscriberNumber,
      contractNumber: contractNumber,
      description: description,
    );
    await _commit(
      _replacePerson(
        person.copyWith(subscriptions: [...person.subscriptions, subscription]),
      ),
    );
  }

  Future<void> updateSubscription({
    required String personId,
    required String subscriptionId,
    required SubscriptionKind kind,
    required String title,
    required String providerName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDueDate,
    String customKindName = '',
    int? customFrequencyDays,
    String subscriberNumber = '',
    String contractNumber = '',
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final existing = _subscription(person, subscriptionId);
    final replacement = _buildSubscription(
      id: existing.id,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      kind: kind,
      title: title,
      providerName: providerName,
      amount: amount,
      frequency: frequency,
      nextDueDate: nextDueDate,
      customKindName: customKindName,
      customFrequencyDays: customFrequencyDays,
      subscriberNumber: subscriberNumber,
      contractNumber: contractNumber,
      description: description,
      isArchived: existing.isArchived,
      payments: existing.payments,
      notes: existing.notes,
    );
    await _commit(
      _replacePerson(
        person.copyWith(
          subscriptions: person.subscriptions
              .map((item) => item.id == subscriptionId ? replacement : item)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deleteSubscription({
    required String personId,
    required String subscriptionId,
  }) async {
    final person = _person(personId);
    _subscription(person, subscriptionId);
    await _commit(
      _replacePerson(
        person.copyWith(
          subscriptions: person.subscriptions
              .where((item) => item.id != subscriptionId)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> setSubscriptionArchived({
    required String personId,
    required String subscriptionId,
    required bool archived,
  }) async {
    final person = _person(personId);
    _subscription(person, subscriptionId);
    await _commit(
      _replacePerson(
        person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == subscriptionId
                    ? item.copyWith(isArchived: archived)
                    : item,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> addRent({
    required String personId,
    RentEntryKind kind = RentEntryKind.custom,
    required String title,
    required double amount,
    required int paymentDay,
    required String receiverName,
    required DateTime dueDate,
    bool recurringMonthly = false,
    String iban = '',
    DateTime? contractStart,
    DateTime? contractEnd,
    DateTime? increaseDate,
    int? installmentCount,
    int? currentInstallment,
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final rent = _buildRent(
      id: newId('rent'),
      currencyCode: _recordCurrency(currencyCode),
      kind: kind,
      title: title,
      amount: amount,
      paymentDay: paymentDay,
      receiverName: receiverName,
      dueDate: dueDate,
      recurringMonthly: recurringMonthly,
      iban: iban,
      contractStart: contractStart,
      contractEnd: contractEnd,
      increaseDate: increaseDate,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      description: description,
    );
    await _commit(
      _replacePerson(person.copyWith(rents: [...person.rents, rent])),
    );
  }

  Future<void> updateRent({
    required String personId,
    required String rentId,
    RentEntryKind? kind,
    required String title,
    required double amount,
    required int paymentDay,
    required String receiverName,
    required DateTime dueDate,
    bool? recurringMonthly,
    String iban = '',
    DateTime? contractStart,
    DateTime? contractEnd,
    DateTime? increaseDate,
    int? installmentCount,
    int? currentInstallment,
    String? currencyCode,
    String description = '',
  }) async {
    final person = _person(personId);
    final existing = _rent(person, rentId);
    final replacement = _buildRent(
      id: existing.id,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      kind: kind ?? existing.kind,
      title: title,
      amount: amount,
      paymentDay: paymentDay,
      receiverName: receiverName,
      dueDate: dueDate,
      recurringMonthly: recurringMonthly ?? existing.recurringMonthly,
      iban: iban,
      contractStart: contractStart,
      contractEnd: contractEnd,
      increaseDate: increaseDate,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      description: description,
      isArchived: existing.isArchived,
      payments: existing.payments,
      notes: existing.notes,
    );
    if (!replacement.isMonthlySchedule &&
        replacement.amount < replacement.paidAmount) {
      throw ArgumentError(
        'Kira/taksit tutarı, daha önce ödenen tutardan düşük olamaz.',
      );
    }
    await _commit(
      _replacePerson(
        person.copyWith(
          rents: person.rents
              .map((item) => item.id == rentId ? replacement : item)
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> deleteRent({
    required String personId,
    required String rentId,
  }) async {
    final person = _person(personId);
    _rent(person, rentId);
    await _commit(
      _replacePerson(
        person.copyWith(
          rents: person.rents.where((item) => item.id != rentId).toList(),
        ),
      ),
    );
  }

  Future<void> setRentArchived({
    required String personId,
    required String rentId,
    required bool archived,
  }) async {
    final person = _person(personId);
    _rent(person, rentId);
    await _commit(
      _replacePerson(
        person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == rentId
                    ? item.copyWith(isArchived: archived)
                    : item,
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  Future<void> addPayment({
    required String personId,
    required RecordType type,
    required String sourceId,
    required double amount,
    required DateTime paidAt,
    PaymentEntryType entryType = PaymentEntryType.partial,
    String note = '',
    String method = '',
  }) async {
    _positiveAmount(amount, 'Ödeme tutarı');
    final person = _person(personId);
    DateTime? appliesToDueDate;
    if (type == RecordType.subscription) {
      appliesToDueDate = _subscription(person, sourceId).nextDueDate;
    } else if (type == RecordType.bill) {
      final bill = _bill(person, sourceId);
      if (bill.isMonthly) {
        appliesToDueDate = bill.effectiveDueDateAt(paidAt);
      }
    } else if (type == RecordType.rent) {
      final rent = _rent(person, sourceId);
      if (rent.isMonthlySchedule) {
        appliesToDueDate = rent.effectiveDueDateAt(paidAt);
      }
    } else if (type == RecordType.debt &&
        entryType == PaymentEntryType.installment) {
      final debt = _debtBySourceId(person, sourceId);
      appliesToDueDate = debt.dueMode == DebtDueMode.monthlyDay
          ? debt.oldestUnpaidDueDateAt(paidAt)
          : debt.dueDate;
    }
    final payment = PaymentRecord(
      id: newId('payment'),
      amount: amount,
      paidAt: paidAt,
      note: _optionalText(note, 'Ödeme notu', 240),
      method: _optionalText(method, 'Ödeme yöntemi', 80),
      entryType: entryType,
      appliesToDueDate: appliesToDueDate,
    );
    await _commit(
      _replacePerson(_personWithPayment(person, type, sourceId, payment)),
    );
  }

  Future<void> updatePayment({
    required String personId,
    required RecordType type,
    required String sourceId,
    required String paymentId,
    required double amount,
    required DateTime paidAt,
    PaymentEntryType entryType = PaymentEntryType.partial,
    String note = '',
    String method = '',
  }) async {
    _positiveAmount(amount, 'Ödeme tutarı');
    final person = _person(personId);
    final existingPayment = _paymentFor(person, type, sourceId, paymentId);
    final replacement = PaymentRecord(
      id: paymentId,
      amount: amount,
      paidAt: paidAt,
      note: _optionalText(note, 'Ödeme notu', 240),
      method: _optionalText(method, 'Ödeme yöntemi', 80),
      entryType: entryType,
      appliesToDueDate: existingPayment.appliesToDueDate,
    );
    await _commit(
      _replacePerson(
        _personWithUpdatedPayment(
          person,
          type,
          sourceId,
          paymentId,
          replacement,
        ),
      ),
    );
  }

  Future<void> deletePayment({
    required String personId,
    required RecordType type,
    required String sourceId,
    required String paymentId,
  }) async {
    final person = _person(personId);
    await _commit(
      _replacePerson(_personWithoutPayment(person, type, sourceId, paymentId)),
    );
  }

  Future<void> addNote({
    required String personId,
    required RecordType type,
    required String sourceId,
    required String text,
  }) async {
    final person = _person(personId);
    final note = RecordNote(
      id: newId('note'),
      text: _requiredText(text, 'Not', 240),
      createdAt: DateTime.now(),
    );
    await _commit(
      _replacePerson(_personWithNote(person, type, sourceId, note)),
    );
  }

  Future<void> deleteNote({
    required String personId,
    required RecordType type,
    required String sourceId,
    required String noteId,
  }) async {
    final person = _person(personId);
    await _commit(
      _replacePerson(_personWithoutNote(person, type, sourceId, noteId)),
    );
  }

  Future<void> addExpenseCategory(String name) async {
    final clean = _requiredText(name, 'Kategori adı', 60);
    _ensureUniqueCategoryName(clean);
    await _commit(
      _state.copyWith(
        expenseCategories: [
          ..._state.expenseCategories,
          ExpenseCategory(id: newId('category'), name: clean),
        ],
      ),
      reschedule: false,
    );
  }

  Future<void> renameExpenseCategory({
    required String categoryId,
    required String name,
  }) async {
    final clean = _requiredText(name, 'Kategori adı', 60);
    _category(categoryId);
    _ensureUniqueCategoryName(clean, excludingId: categoryId);
    await _commit(
      _state.copyWith(
        expenseCategories: _state.expenseCategories
            .map(
              (item) =>
                  item.id == categoryId ? item.copyWith(name: clean) : item,
            )
            .toList(growable: false),
      ),
      reschedule: false,
    );
  }

  Future<void> deleteExpenseCategory({
    required String categoryId,
    required String confirmation,
  }) async {
    _category(categoryId);
    MizanI18n.setLanguageTag(_state.appLanguageTag);
    final expectedConfirmation = MizanI18n.destructiveConfirmation;
    if (confirmation.trim() != expectedConfirmation) {
      throw ArgumentError(
        'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.',
      );
    }
    await _commit(
      _state.copyWith(
        expenseCategories: _state.expenseCategories
            .where((item) => item.id != categoryId)
            .toList(),
        expenses: _state.expenses
            .where((item) => item.categoryId != categoryId)
            .toList(),
      ),
      reschedule: false,
    );
  }

  Future<void> addExpense({
    required String categoryId,
    required String name,
    required double quantity,
    required double unitPrice,
    required DateTime spentAt,
    String? currencyCode,
    String note = '',
  }) async {
    _category(categoryId);
    final item = _buildExpense(
      id: newId('expense'),
      currencyCode: _recordCurrency(currencyCode),
      categoryId: categoryId,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      spentAt: spentAt,
      note: note,
    );
    await _commit(
      _state.copyWith(expenses: [item, ..._state.expenses]),
      reschedule: false,
    );
  }

  Future<void> updateExpense({
    required String expenseId,
    required String categoryId,
    required String name,
    required double quantity,
    required double unitPrice,
    required DateTime spentAt,
    String? currencyCode,
    String note = '',
  }) async {
    final existing = _expense(expenseId);
    _category(categoryId);
    final replacement = _buildExpense(
      id: expenseId,
      currencyCode: _recordCurrency(
        currencyCode,
        fallback: existing.currencyCode,
      ),
      categoryId: categoryId,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      spentAt: spentAt,
      note: note,
    );
    await _commit(
      _state.copyWith(
        expenses: _state.expenses
            .map((item) => item.id == expenseId ? replacement : item)
            .toList(growable: false),
      ),
      reschedule: false,
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    _expense(expenseId);
    await _commit(
      _state.copyWith(
        expenses: _state.expenses
            .where((item) => item.id != expenseId)
            .toList(),
      ),
      reschedule: false,
    );
  }

  Future<void> restoreFromBackup(MizanState restored) async {
    await _commit(
      restored.copyWith(schemaVersion: currentSchemaVersion),
      allowStorageRecovery: true,
    );
    _loadMessage = 'CSV yedeği doğrulandı ve geri yüklendi.';
    notifyListeners();
  }

  Future<void> mergeFromBackup(
    MizanState merged, {
    required int addedCount,
    required int mergedCount,
    required int duplicateCount,
  }) async {
    await _commit(
      merged.copyWith(schemaVersion: currentSchemaVersion),
      allowStorageRecovery: true,
    );
    final duplicatePart = duplicateCount > 0
        ? ', $duplicateCount gerçekten ortak kullanıcı kaydı atlandı'
        : '';
    _loadMessage =
        'CSV yedeği mevcut kayıtlarla birleştirildi: '
        '$addedCount yeni, $mergedCount ilişki güncellendi$duplicatePart.';
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _commit(
      _state.copyWith(notificationsEnabled: enabled),
      requestMissingNotificationPermissions: enabled,
    );
  }

  Future<void> setPaymentReminderFrequency(
    PaymentReminderFrequency frequency,
  ) async {
    await _commit(
      _state.copyWith(
        paymentReminderFrequency: frequency,
        paymentNotificationSlots: defaultPaymentNotificationSlotsFor(frequency),
      ),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<void> addPaymentNotificationSlot() async {
    if (_state.paymentNotificationSlots.length >= 10) {
      throw ArgumentError('En fazla 10 ödeme bildirimi eklenebilir.');
    }
    final index = _state.paymentNotificationSlots.length + 1;
    final last = _state.paymentNotificationSlots.isEmpty
        ? const NotificationSlot(
            id: 'temporary',
            label: 'Geçici',
            hour: 8,
            minute: 0,
            message: '',
          )
        : _state.paymentNotificationSlots.last;
    final totalMinutes = (last.hour * 60 + last.minute + 120) % (24 * 60);
    final slot = NotificationSlot(
      id: newId('payment-reminder'),
      label: 'Ödeme hatırlatması $index',
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
      message: 'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
    );
    await _commit(
      _state.copyWith(
        paymentNotificationSlots: [..._state.paymentNotificationSlots, slot],
      ),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<void> updatePaymentNotificationSlot({
    required String slotId,
    String? label,
    int? hour,
    int? minute,
    String? message,
    bool? enabled,
  }) async {
    final index = _state.paymentNotificationSlots.indexWhere(
      (item) => item.id == slotId,
    );
    if (index < 0) throw ArgumentError('Ödeme bildirim saati bulunamadı.');
    final current = _state.paymentNotificationSlots[index];
    final nextHour = hour ?? current.hour;
    final nextMinute = minute ?? current.minute;
    if (nextHour < 0 || nextHour > 23 || nextMinute < 0 || nextMinute > 59) {
      throw ArgumentError('Bildirim saati geçersiz.');
    }
    final cleanLabel = label == null
        ? current.label
        : _requiredText(label, 'Hatırlatma adı', 60);
    final cleanMessage = message == null
        ? current.message
        : _requiredText(message, 'Bildirim mesajı', 160);
    await _commit(
      _state.copyWith(
        paymentNotificationSlots: _state.paymentNotificationSlots
            .map(
              (item) => item.id == slotId
                  ? item.copyWith(
                      label: cleanLabel,
                      hour: nextHour,
                      minute: nextMinute,
                      message: cleanMessage,
                      enabled: enabled,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<void> deletePaymentNotificationSlot(String slotId) async {
    if (_state.paymentNotificationSlots.length <= 1) {
      throw ArgumentError('En az bir ödeme bildirim saati bulunmalıdır.');
    }
    if (!_state.paymentNotificationSlots.any((item) => item.id == slotId)) {
      throw ArgumentError('Ödeme bildirim saati bulunamadı.');
    }
    await _commit(
      _state.copyWith(
        paymentNotificationSlots: _state.paymentNotificationSlots
            .where((item) => item.id != slotId)
            .toList(growable: false),
      ),
    );
  }

  Future<void> addIncome({
    required String title,
    required double amount,
    required IncomeFrequency frequency,
    required DateTime startDate,
    String? currencyCode,
    String note = '',
    bool scheduleTrackingEnabled = false,
    int? scheduledWeekday,
    int? scheduledDayOfMonth,
  }) async {
    _positiveAmount(amount, 'Gelir tutarı');
    _validateIncomeTracking(
      frequency: frequency,
      enabled: scheduleTrackingEnabled,
      scheduledWeekday: scheduledWeekday,
      scheduledDayOfMonth: scheduledDayOfMonth,
    );
    final normalizedStart = dateOnly(startDate);
    final today = dateOnly(DateTime.now());
    final income = IncomeEntry(
      id: newId('income'),
      currencyCode: _recordCurrency(currencyCode),
      title: _requiredText(title, 'Gelir türü', 100),
      amount: amount,
      frequency: frequency,
      startDate: normalizedStart,
      note: _optionalText(note, 'Gelir notu', 240),
      scheduleTrackingEnabled: scheduleTrackingEnabled,
      scheduledWeekday: frequency == IncomeFrequency.weekly
          ? scheduledWeekday
          : null,
      scheduledDayOfMonth: frequency == IncomeFrequency.monthly
          ? scheduledDayOfMonth
          : null,
      trackingStartedAt: scheduleTrackingEnabled
          ? (normalizedStart.isAfter(today) ? normalizedStart : today)
          : null,
    );
    await _commit(
      _state.copyWith(incomes: [..._state.incomes, income]),
      reschedule: false,
    );
  }

  Future<void> updateIncome({
    required String incomeId,
    required String title,
    required double amount,
    required IncomeFrequency frequency,
    required DateTime startDate,
    String? currencyCode,
    String note = '',
    bool scheduleTrackingEnabled = false,
    int? scheduledWeekday,
    int? scheduledDayOfMonth,
  }) async {
    _positiveAmount(amount, 'Gelir tutarı');
    _validateIncomeTracking(
      frequency: frequency,
      enabled: scheduleTrackingEnabled,
      scheduledWeekday: scheduledWeekday,
      scheduledDayOfMonth: scheduledDayOfMonth,
    );
    if (!_state.incomes.any((item) => item.id == incomeId)) {
      throw ArgumentError('Gelir kaydı bulunamadı.');
    }
    final normalizedStart = dateOnly(startDate);
    final today = dateOnly(DateTime.now());
    await _commit(
      _state.copyWith(
        incomes: _state.incomes
            .map((item) {
              if (item.id != incomeId) return item;
              final trackingStart = scheduleTrackingEnabled
                  ? (item.scheduleTrackingEnabled
                        ? item.trackingStartedAt
                        : (normalizedStart.isAfter(today)
                              ? normalizedStart
                              : today))
                  : item.trackingStartedAt;
              return IncomeEntry(
                id: item.id,
                currencyCode: _recordCurrency(
                  currencyCode,
                  fallback: item.currencyCode,
                ),
                title: _requiredText(title, 'Gelir türü', 100),
                amount: amount,
                frequency: frequency,
                startDate: normalizedStart,
                isArchived: item.isArchived,
                note: _optionalText(note, 'Gelir notu', 240),
                scheduleTrackingEnabled: scheduleTrackingEnabled,
                scheduledWeekday: frequency == IncomeFrequency.weekly
                    ? scheduledWeekday
                    : null,
                scheduledDayOfMonth: frequency == IncomeFrequency.monthly
                    ? scheduledDayOfMonth
                    : null,
                trackingStartedAt: trackingStart,
                receipts: item.receipts,
              );
            })
            .toList(growable: false),
      ),
      reschedule: false,
    );
  }

  void _validateIncomeTracking({
    required IncomeFrequency frequency,
    required bool enabled,
    int? scheduledWeekday,
    int? scheduledDayOfMonth,
  }) {
    if (!enabled) return;
    if (frequency == IncomeFrequency.weekly) {
      if (scheduledWeekday == null ||
          scheduledWeekday < DateTime.monday ||
          scheduledWeekday > DateTime.sunday) {
        throw ArgumentError(
          'Haftalık gelir için geçerli bir gün seçilmelidir.',
        );
      }
      return;
    }
    if (frequency == IncomeFrequency.monthly) {
      if (scheduledDayOfMonth == null ||
          scheduledDayOfMonth < 1 ||
          scheduledDayOfMonth > 31) {
        throw ArgumentError('Aylık gelir günü 1 ile 31 arasında olmalıdır.');
      }
      return;
    }
    throw ArgumentError(
      'Yatış günü takibi yalnız haftalık ve aylık gelirlerde kullanılabilir.',
    );
  }

  Future<void> markIncomeReceived({
    required String incomeId,
    required DateTime receivedAt,
    DateTime? referenceDate,
  }) async {
    final index = _state.incomes.indexWhere((item) => item.id == incomeId);
    if (index < 0) throw ArgumentError('Gelir kaydı bulunamadı.');
    final income = _state.incomes[index];
    final receivedDate = dateOnly(receivedAt);
    final scheduledDate = income.trackedOccurrenceAt(
      referenceDate ?? DateTime.now(),
    );
    if (scheduledDate == null) {
      throw ArgumentError('Bu gelir için yatış günü takibi açık değil.');
    }
    if (income.hasReceiptFor(scheduledDate)) {
      throw ArgumentError(
        'Bu gelir dönemi daha önce alındı olarak işaretlenmiş.',
      );
    }
    final receipt = IncomeReceipt(
      id: newId('income-receipt'),
      scheduledDate: scheduledDate,
      receivedDate: receivedDate,
    );
    final updated = income.copyWith(receipts: [...income.receipts, receipt]);
    final incomes = [..._state.incomes]..[index] = updated;
    await _commit(_state.copyWith(incomes: incomes), reschedule: false);
  }

  Future<void> undoLatestIncomeReceipt(String incomeId) async {
    final index = _state.incomes.indexWhere((item) => item.id == incomeId);
    if (index < 0) throw ArgumentError('Gelir kaydı bulunamadı.');
    final income = _state.incomes[index];
    final latest = income.latestReceipt;
    if (latest == null) throw ArgumentError('Geri alınacak gelir işareti yok.');
    final updated = income.copyWith(
      receipts: income.receipts
          .where((item) => item.id != latest.id)
          .toList(growable: false),
    );
    final incomes = [..._state.incomes]..[index] = updated;
    await _commit(_state.copyWith(incomes: incomes), reschedule: false);
  }

  Future<void> setIncomeArchived(String incomeId, bool archived) async {
    if (!_state.incomes.any((item) => item.id == incomeId)) {
      throw ArgumentError('Gelir kaydı bulunamadı.');
    }
    await _commit(
      _state.copyWith(
        incomes: _state.incomes
            .map(
              (item) => item.id == incomeId
                  ? item.copyWith(isArchived: archived)
                  : item,
            )
            .toList(growable: false),
      ),
      reschedule: false,
    );
  }

  Future<void> deleteIncome(String incomeId) async {
    if (!_state.incomes.any((item) => item.id == incomeId)) {
      throw ArgumentError('Gelir kaydı bulunamadı.');
    }
    await _commit(
      _state.copyWith(
        incomes: _state.incomes
            .where((item) => item.id != incomeId)
            .toList(growable: false),
      ),
      reschedule: false,
    );
  }

  Future<void> setNotificationSoundMode(NotificationSoundMode mode) async {
    await _commit(
      _state.copyWith(notificationSoundMode: mode),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<void> setNotificationVibrationEnabled(bool enabled) async {
    await _commit(
      _state.copyWith(notificationVibrationEnabled: enabled),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<void> updateNotificationSlot({
    required String slotId,
    int? hour,
    int? minute,
    String? message,
    bool? enabled,
  }) async {
    final index = _state.notificationSlots.indexWhere(
      (item) => item.id == slotId,
    );
    if (index < 0) {
      throw ArgumentError('Bildirim ayarı bulunamadı.');
    }
    final current = _state.notificationSlots[index];
    final cleanMessage = message == null
        ? current.message
        : _requiredText(message, 'Bildirim mesajı', 160);
    final nextHour = hour ?? current.hour;
    final nextMinute = minute ?? current.minute;
    if (nextHour < 0 || nextHour > 23 || nextMinute < 0 || nextMinute > 59) {
      throw ArgumentError('Bildirim saati geçersiz.');
    }
    await _commit(
      _state.copyWith(
        notificationSlots: _state.notificationSlots
            .map(
              (item) => item.id == slotId
                  ? item.copyWith(
                      hour: nextHour,
                      minute: nextMinute,
                      message: cleanMessage,
                      enabled: enabled,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
      requestMissingNotificationPermissions: true,
    );
  }

  Future<DateTime> scheduleNotificationTest(NotificationSlot slot) async {
    _isBusy = true;
    _lastError = null;
    notifyListeners();
    try {
      final target = await _scheduler.scheduleTestNotification(
        slot: slot,
        state: _state,
      );
      _notificationHealth = await _scheduler.health();
      return target;
    } on Object catch (error) {
      _lastError = _friendlyError(error);
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> requestNotificationPermissions() async {
    _isBusy = true;
    notifyListeners();
    try {
      await _synchronizeNotifications(
        _state,
        requestMissingPermissions: true,
        surfaceErrors: true,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotificationHealth() async {
    try {
      _notificationHealth = await _scheduler.health();
      notifyListeners();
    } on Object catch (error) {
      _lastError = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> rescheduleNotifications() async {
    await _synchronizeNotifications(
      _state,
      requestMissingPermissions: true,
      surfaceErrors: true,
    );
    notifyListeners();
  }

  MizanState _replacePerson(PersonAccount replacement) {
    return _state.copyWith(
      people: _state.people
          .map((person) => person.id == replacement.id ? replacement : person)
          .toList(growable: false),
    );
  }

  MizanState _replaceBank(PersonAccount person, BankGroup replacement) {
    return _replacePerson(
      person.copyWith(
        banks: person.banks
            .map((bank) => bank.id == replacement.id ? replacement : bank)
            .toList(growable: false),
      ),
    );
  }

  PersonAccount _personWithPayment(
    PersonAccount person,
    RecordType type,
    String sourceId,
    PaymentRecord payment,
  ) {
    switch (type) {
      case RecordType.debt:
        for (final bank in person.banks) {
          final index = bank.products.indexWhere((item) => item.id == sourceId);
          if (index < 0) {
            continue;
          }
          final record = bank.products[index];
          if (payment.amount > record.remainingAmount) {
            throw ArgumentError('Ödeme kalan borçtan büyük olamaz.');
          }
          return person.copyWith(
            banks: person.banks
                .map(
                  (item) => item.id == bank.id
                      ? item.copyWith(
                          products: item.products
                              .map(
                                (product) => product.id == sourceId
                                    ? product.copyWith(
                                        payments: [
                                          payment,
                                          ...product.payments,
                                        ],
                                      )
                                    : product,
                              )
                              .toList(),
                        )
                      : item,
                )
                .toList(),
          );
        }
        throw ArgumentError('Borç kaydı bulunamadı.');
      case RecordType.personalDebt:
        final record = _personalDebt(person, sourceId);
        if (payment.amount > record.remainingAmount) {
          throw ArgumentError('Ödeme kalan borçtan büyük olamaz.');
        }
        return person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(payments: [payment, ...item.payments])
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.bill:
        final record = _bill(person, sourceId);
        if (payment.amount > record.remainingAmount) {
          throw ArgumentError('Ödeme kalan fatura tutarından büyük olamaz.');
        }
        return person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(payments: [payment, ...item.payments])
                    : item,
              )
              .toList(),
        );
      case RecordType.subscription:
        final record = _subscription(person, sourceId);
        if (payment.amount > record.remainingAmount) {
          throw ArgumentError(
            'Ödeme aboneliğin bu dönem kalan tutarından büyük olamaz.',
          );
        }
        final payments = [payment, ...record.payments];
        final cyclePaid = payments
            .where(
              (item) =>
                  item.appliesToDueDate != null &&
                  dateOnly(item.appliesToDueDate!) ==
                      dateOnly(record.nextDueDate),
            )
            .fold<double>(0.0, (sum, item) => sum + item.amount);
        final nextDate = cyclePaid + 0.001 >= record.amount
            ? _advanceDueDate(
                record.nextDueDate,
                record.frequency,
                record.customFrequencyDays,
              )
            : record.nextDueDate;
        return person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(payments: payments, nextDueDate: nextDate)
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.rent:
        final record = _rent(person, sourceId);
        if (payment.amount > record.remainingAmount) {
          throw ArgumentError(
            'Ödeme kalan kira/taksit tutarından büyük olamaz.',
          );
        }
        return person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(payments: [payment, ...item.payments])
                    : item,
              )
              .toList(),
        );
    }
  }

  PersonAccount _personWithUpdatedPayment(
    PersonAccount person,
    RecordType type,
    String sourceId,
    String paymentId,
    PaymentRecord replacement,
  ) {
    List<PaymentRecord> replace(List<PaymentRecord> payments, double total) {
      final existing = payments.where((item) => item.id == paymentId).toList();
      if (existing.isEmpty) {
        throw ArgumentError('Ödeme kaydı bulunamadı.');
      }
      final paidWithout = payments
          .where((item) => item.id != paymentId)
          .fold<double>(0, (sum, item) => sum + item.amount);
      if (paidWithout + replacement.amount > total + 0.001) {
        throw ArgumentError('Güncellenen ödeme toplam tutarı aşamaz.');
      }
      return payments
          .map((item) => item.id == paymentId ? replacement : item)
          .toList(growable: false);
    }

    switch (type) {
      case RecordType.debt:
        for (final bank in person.banks) {
          if (!bank.products.any((item) => item.id == sourceId)) {
            continue;
          }
          return person.copyWith(
            banks: person.banks
                .map(
                  (item) => item.id == bank.id
                      ? item.copyWith(
                          products: item.products
                              .map(
                                (product) => product.id == sourceId
                                    ? product.copyWith(
                                        payments: replace(
                                          product.payments,
                                          product.totalAmount,
                                        ),
                                      )
                                    : product,
                              )
                              .toList(),
                        )
                      : item,
                )
                .toList(),
          );
        }
        throw ArgumentError('Borç kaydı bulunamadı.');
      case RecordType.personalDebt:
        final debt = _personalDebt(person, sourceId);
        return person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: replace(item.payments, debt.totalAmount),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.bill:
        final bill = _bill(person, sourceId);
        return person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: replace(item.payments, bill.amount),
                      )
                    : item,
              )
              .toList(),
        );
      case RecordType.subscription:
        final subscription = _subscription(person, sourceId);
        return person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: replace(item.payments, subscription.amount),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.rent:
        final rent = _rent(person, sourceId);
        return person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: replace(item.payments, rent.amount),
                      )
                    : item,
              )
              .toList(),
        );
    }
  }

  PersonAccount _personWithoutPayment(
    PersonAccount person,
    RecordType type,
    String sourceId,
    String paymentId,
  ) {
    switch (type) {
      case RecordType.debt:
        for (final bank in person.banks) {
          if (!bank.products.any((item) => item.id == sourceId)) {
            continue;
          }
          return person.copyWith(
            banks: person.banks
                .map(
                  (item) => item.id == bank.id
                      ? item.copyWith(
                          products: item.products
                              .map(
                                (product) => product.id == sourceId
                                    ? product.copyWith(
                                        payments: product.payments
                                            .where(
                                              (payment) =>
                                                  payment.id != paymentId,
                                            )
                                            .toList(),
                                      )
                                    : product,
                              )
                              .toList(),
                        )
                      : item,
                )
                .toList(),
          );
        }
        throw ArgumentError('Borç kaydı bulunamadı.');
      case RecordType.personalDebt:
        _personalDebt(person, sourceId);
        return person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: item.payments
                            .where((payment) => payment.id != paymentId)
                            .toList(growable: false),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.bill:
        _bill(person, sourceId);
        return person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: item.payments
                            .where((payment) => payment.id != paymentId)
                            .toList(),
                      )
                    : item,
              )
              .toList(),
        );
      case RecordType.subscription:
        _subscription(person, sourceId);
        return person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: item.payments
                            .where((payment) => payment.id != paymentId)
                            .toList(growable: false),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.rent:
        _rent(person, sourceId);
        return person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        payments: item.payments
                            .where((payment) => payment.id != paymentId)
                            .toList(),
                      )
                    : item,
              )
              .toList(),
        );
    }
  }

  PersonAccount _personWithNote(
    PersonAccount person,
    RecordType type,
    String sourceId,
    RecordNote note,
  ) {
    switch (type) {
      case RecordType.debt:
        for (final bank in person.banks) {
          if (!bank.products.any((item) => item.id == sourceId)) continue;
          return person.copyWith(
            banks: person.banks
                .map(
                  (item) => item.id == bank.id
                      ? item.copyWith(
                          products: item.products
                              .map(
                                (product) => product.id == sourceId
                                    ? product.copyWith(
                                        notes: [note, ...product.notes],
                                      )
                                    : product,
                              )
                              .toList(),
                        )
                      : item,
                )
                .toList(),
          );
        }
        throw ArgumentError('Borç kaydı bulunamadı.');
      case RecordType.personalDebt:
        _personalDebt(person, sourceId);
        return person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(notes: [note, ...item.notes])
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.bill:
        _bill(person, sourceId);
        return person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(notes: [note, ...item.notes])
                    : item,
              )
              .toList(),
        );
      case RecordType.subscription:
        _subscription(person, sourceId);
        return person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(notes: [note, ...item.notes])
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.rent:
        _rent(person, sourceId);
        return person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(notes: [note, ...item.notes])
                    : item,
              )
              .toList(),
        );
    }
  }

  PersonAccount _personWithoutNote(
    PersonAccount person,
    RecordType type,
    String sourceId,
    String noteId,
  ) {
    switch (type) {
      case RecordType.debt:
        for (final bank in person.banks) {
          if (!bank.products.any((item) => item.id == sourceId)) {
            continue;
          }
          return person.copyWith(
            banks: person.banks
                .map(
                  (item) => item.id == bank.id
                      ? item.copyWith(
                          products: item.products
                              .map(
                                (product) => product.id == sourceId
                                    ? product.copyWith(
                                        notes: product.notes
                                            .where((note) => note.id != noteId)
                                            .toList(),
                                      )
                                    : product,
                              )
                              .toList(),
                        )
                      : item,
                )
                .toList(),
          );
        }
        throw ArgumentError('Borç kaydı bulunamadı.');
      case RecordType.personalDebt:
        _personalDebt(person, sourceId);
        return person.copyWith(
          personalDebts: person.personalDebts
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        notes: item.notes
                            .where((note) => note.id != noteId)
                            .toList(growable: false),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.bill:
        _bill(person, sourceId);
        return person.copyWith(
          bills: person.bills
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        notes: item.notes
                            .where((note) => note.id != noteId)
                            .toList(),
                      )
                    : item,
              )
              .toList(),
        );
      case RecordType.subscription:
        _subscription(person, sourceId);
        return person.copyWith(
          subscriptions: person.subscriptions
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        notes: item.notes
                            .where((note) => note.id != noteId)
                            .toList(growable: false),
                      )
                    : item,
              )
              .toList(growable: false),
        );
      case RecordType.rent:
        _rent(person, sourceId);
        return person.copyWith(
          rents: person.rents
              .map(
                (item) => item.id == sourceId
                    ? item.copyWith(
                        notes: item.notes
                            .where((note) => note.id != noteId)
                            .toList(),
                      )
                    : item,
              )
              .toList(),
        );
    }
  }

  DebtProduct _buildDebt({
    required String id,
    required String currencyCode,
    required DebtKind kind,
    required String title,
    required double totalAmount,
    required double monthlyAmount,
    required DateTime dueDate,
    DebtDueMode dueMode = DebtDueMode.fixedDate,
    int? dueDayOfMonth,
    String customKindName = '',
    int? installmentCount,
    int? currentInstallment,
    int? manualOverdueDays,
    DateTime? manualOverdueRecordedAt,
    DateTime? manualOverdueSince,
    List<DateTime> manualOverduePeriods = const [],
    double? limit,
    double? usedLimit,
    String description = '',
    bool isArchived = false,
    List<PaymentRecord> payments = const [],
    List<RecordNote> notes = const [],
  }) {
    final cleanTitle = _requiredText(title, 'Borç başlığı', 100);
    _positiveAmount(totalAmount, 'Toplam borç');
    _nonNegativeAmount(monthlyAmount, 'Aylık tutar');
    if (dueMode == DebtDueMode.monthlyDay) {
      if (dueDayOfMonth == null || dueDayOfMonth < 1 || dueDayOfMonth > 31) {
        throw ArgumentError('Aylık ödeme günü 1 ile 31 arasında olmalıdır.');
      }
      if (monthlyAmount <= 0) {
        throw ArgumentError(
          'Her ayın belirli günü seçildiğinde aylık tutar girilmelidir.',
        );
      }
    }
    if (kind == DebtKind.custom) {
      _requiredText(customKindName, 'Özel borç türü', 60);
    }
    _validateInstallments(installmentCount, currentInstallment);
    if (manualOverdueDays != null &&
        (manualOverdueDays < 0 || manualOverdueDays > 3650)) {
      throw ArgumentError('Gecikme günü 0 ile 3650 arasında olmalıdır.');
    }
    if (manualOverduePeriods.isNotEmpty && dueMode != DebtDueMode.monthlyDay) {
      throw ArgumentError(
        'Gecikmiş ay seçimi yalnız aylık ödeme gününde kullanılabilir.',
      );
    }
    final normalizedOverduePeriods = <DateTime>[];
    final seenPeriods = <int>{};
    final today = dateOnly(DateTime.now());
    for (final period in manualOverduePeriods) {
      final month = DateTime(period.year, period.month);
      final periodDueDate = _dateWithDay(month, dueDayOfMonth ?? dueDate.day);
      if (periodDueDate.isAfter(today)) {
        throw ArgumentError(
          'Gecikmiş ayın ödeme tarihi henüz gelmemiş olamaz.',
        );
      }
      final key = month.year * 100 + month.month;
      if (seenPeriods.add(key)) normalizedOverduePeriods.add(month);
    }
    normalizedOverduePeriods.sort();
    if (limit != null) {
      _nonNegativeAmount(limit, 'Limit');
    }
    if (usedLimit != null) {
      _nonNegativeAmount(usedLimit, 'Kullanılan limit');
    }
    if (limit != null && usedLimit != null && usedLimit > limit) {
      throw ArgumentError('Kullanılan limit toplam limiti aşamaz.');
    }
    return DebtProduct(
      id: id,
      currencyCode: currencyCode,
      kind: kind,
      title: cleanTitle,
      customKindName: _optionalText(customKindName, 'Özel borç türü', 60),
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      dueDate: dateOnly(dueDate),
      dueMode: dueMode,
      dueDayOfMonth: dueMode == DebtDueMode.monthlyDay ? dueDayOfMonth : null,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      manualOverdueDays: manualOverdueDays,
      manualOverdueRecordedAt: manualOverdueRecordedAt,
      manualOverdueSince: manualOverdueSince,
      manualOverduePeriods: normalizedOverduePeriods,
      limit: limit,
      usedLimit: usedLimit,
      description: _optionalText(description, 'Açıklama', 240),
      isArchived: isArchived,
      payments: payments,
      notes: notes,
    );
  }

  PersonalDebtEntry _buildPersonalDebt({
    required String id,
    required String currencyCode,
    required CreditorType creditorType,
    required String title,
    required String creditorName,
    required double totalAmount,
    required DateTime debtDate,
    required DateTime dueDate,
    required PaymentFrequency frequency,
    bool isInstallment = false,
    int? installmentCount,
    int? currentInstallment,
    double monthlyAmount = 0,
    int? customFrequencyDays,
    String description = '',
    String chequeNumber = '',
    String issuerName = '',
    String bankInfo = '',
    String promissoryNoteNumber = '',
    int? documentCount,
    int? currentDocument,
    List<DueScheduleItem> schedule = const [],
    bool isArchived = false,
    List<PaymentRecord> payments = const [],
    List<RecordNote> notes = const [],
  }) {
    _positiveAmount(totalAmount, 'Toplam borç');
    _nonNegativeAmount(monthlyAmount, 'Düzenli ödeme tutarı');
    if (dueDate.isBefore(debtDate)) {
      throw ArgumentError('Son ödeme tarihi borç tarihinden önce olamaz.');
    }
    if (isInstallment) {
      _validateInstallments(installmentCount, currentInstallment);
      if (monthlyAmount <= 0) {
        throw ArgumentError('Taksitli borçta ödeme tutarı girilmelidir.');
      }
    }
    if (frequency == PaymentFrequency.custom &&
        (customFrequencyDays == null || customFrequencyDays <= 0)) {
      throw ArgumentError('Özel ödeme aralığı gün olarak girilmelidir.');
    }
    if (creditorType == CreditorType.cheque && chequeNumber.trim().isEmpty) {
      throw ArgumentError('Çek numarası boş bırakılamaz.');
    }
    if (creditorType == CreditorType.promissoryNote &&
        promissoryNoteNumber.trim().isEmpty) {
      throw ArgumentError('Senet numarası boş bırakılamaz.');
    }
    if (documentCount != null || currentDocument != null) {
      _validateInstallments(documentCount, currentDocument);
    }
    final normalizedSchedule = schedule
        .map(
          (item) => item.copyWith(
            amount: _normalizedPositive(item.amount, 'Ödeme planı tutarı'),
            dueDate: dateOnly(item.dueDate),
          ),
        )
        .toList(growable: false);
    return PersonalDebtEntry(
      id: id,
      currencyCode: currencyCode,
      creditorType: creditorType,
      title: _requiredText(title, 'Borç başlığı', 100),
      creditorName: _requiredText(creditorName, 'Alacaklı adı', 100),
      totalAmount: totalAmount,
      debtDate: dateOnly(debtDate),
      dueDate: dateOnly(dueDate),
      frequency: frequency,
      isInstallment: isInstallment,
      installmentCount: installmentCount,
      currentInstallment: currentInstallment,
      monthlyAmount: monthlyAmount,
      customFrequencyDays: customFrequencyDays,
      description: _optionalText(description, 'Açıklama', 240),
      chequeNumber: _optionalText(chequeNumber, 'Çek numarası', 80),
      issuerName: _optionalText(issuerName, 'Düzenleyen', 100),
      bankInfo: _optionalText(bankInfo, 'Banka bilgisi', 100),
      promissoryNoteNumber: _optionalText(
        promissoryNoteNumber,
        'Senet numarası',
        80,
      ),
      documentCount: documentCount,
      currentDocument: currentDocument,
      schedule: normalizedSchedule,
      isArchived: isArchived,
      payments: payments,
      notes: notes,
    );
  }

  SubscriptionEntry _buildSubscription({
    required String id,
    required String currencyCode,
    required SubscriptionKind kind,
    required String title,
    required String providerName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDueDate,
    String customKindName = '',
    int? customFrequencyDays,
    String subscriberNumber = '',
    String contractNumber = '',
    String description = '',
    bool isArchived = false,
    List<PaymentRecord> payments = const [],
    List<RecordNote> notes = const [],
  }) {
    _positiveAmount(amount, 'Abonelik tutarı');
    if (kind == SubscriptionKind.custom) {
      _requiredText(customKindName, 'Abonelik türü', 60);
    }
    if (frequency == PaymentFrequency.oneTime) {
      throw ArgumentError('Abonelik ödeme sıklığı tek ödeme olamaz.');
    }
    if (frequency == PaymentFrequency.custom &&
        (customFrequencyDays == null || customFrequencyDays <= 0)) {
      throw ArgumentError('Özel ödeme aralığı gün olarak girilmelidir.');
    }
    return SubscriptionEntry(
      id: id,
      currencyCode: currencyCode,
      kind: kind,
      title: _requiredText(title, 'Abonelik başlığı', 100),
      providerName: _requiredText(providerName, 'Sağlayıcı adı', 100),
      amount: amount,
      frequency: frequency,
      nextDueDate: dateOnly(nextDueDate),
      customKindName: _optionalText(customKindName, 'Abonelik türü', 60),
      customFrequencyDays: customFrequencyDays,
      subscriberNumber: _optionalText(subscriberNumber, 'Abone numarası', 60),
      contractNumber: _optionalText(contractNumber, 'Sözleşme numarası', 60),
      description: _optionalText(description, 'Açıklama', 240),
      isArchived: isArchived,
      payments: payments,
      notes: notes,
    );
  }

  BillEntry _buildBill({
    required String id,
    required String currencyCode,
    required BillKind kind,
    required String institutionName,
    required double amount,
    required DateTime dueDate,
    BillScheduleMode scheduleMode = BillScheduleMode.oneTime,
    int? paymentDay,
    List<BillPeriodAmount> periodAmounts = const [],
    String subscriberNumber = '',
    String contractNumber = '',
    String description = '',
    bool isArchived = false,
    List<PaymentRecord> payments = const [],
    List<RecordNote> notes = const [],
  }) {
    _positiveAmount(amount, 'Fatura tutarı');
    if (scheduleMode == BillScheduleMode.monthly &&
        (paymentDay == null || paymentDay < 1 || paymentDay > 31)) {
      throw ArgumentError('Aylık fatura günü 1 ile 31 arasında olmalıdır.');
    }
    for (final period in periodAmounts) {
      _positiveAmount(period.amount, 'Dönem fatura tutarı');
    }
    return BillEntry(
      id: id,
      currencyCode: currencyCode,
      kind: kind,
      institutionName: _requiredText(institutionName, 'Kurum adı', 100),
      subscriberNumber: _optionalText(subscriberNumber, 'Abone numarası', 60),
      contractNumber: _optionalText(contractNumber, 'Sözleşme numarası', 60),
      amount: amount,
      dueDate: dateOnly(dueDate),
      scheduleMode: scheduleMode,
      paymentDay: scheduleMode == BillScheduleMode.monthly ? paymentDay : null,
      periodAmounts: periodAmounts,
      description: _optionalText(description, 'Açıklama', 240),
      isArchived: isArchived,
      payments: payments,
      notes: notes,
    );
  }

  RentEntry _buildRent({
    required String id,
    required String currencyCode,
    required RentEntryKind kind,
    required String title,
    required double amount,
    required int paymentDay,
    required String receiverName,
    required DateTime dueDate,
    bool recurringMonthly = false,
    String iban = '',
    DateTime? contractStart,
    DateTime? contractEnd,
    DateTime? increaseDate,
    int? installmentCount,
    int? currentInstallment,
    String description = '',
    bool isArchived = false,
    List<PaymentRecord> payments = const [],
    List<RecordNote> notes = const [],
  }) {
    _positiveAmount(amount, 'Kira/taksit tutarı');
    if (paymentDay < 1 || paymentDay > 31) {
      throw ArgumentError('Ödeme günü 1 ile 31 arasında olmalı.');
    }
    if (kind == RentEntryKind.productInstallment) {
      if (installmentCount == null || installmentCount <= 0) {
        throw ArgumentError('Ürün taksitinde toplam taksit sayısı gereklidir.');
      }
      _validateInstallments(installmentCount, currentInstallment);
    } else if (installmentCount != null || currentInstallment != null) {
      _validateInstallments(installmentCount, currentInstallment);
    }
    if (kind != RentEntryKind.productInstallment &&
        contractStart != null &&
        contractEnd != null &&
        contractEnd.isBefore(contractStart)) {
      throw ArgumentError('Sözleşme bitişi başlangıçtan önce olamaz.');
    }
    return RentEntry(
      id: id,
      currencyCode: currencyCode,
      kind: kind,
      title: _requiredText(title, 'Kira/taksit başlığı', 100),
      amount: amount,
      paymentDay: paymentDay,
      receiverName: _requiredText(receiverName, 'Alıcı adı', 100),
      iban: _optionalText(iban, 'IBAN', 40),
      dueDate: dateOnly(dueDate),
      recurringMonthly: kind == RentEntryKind.homeRent || recurringMonthly,
      contractStart:
          kind == RentEntryKind.productInstallment || contractStart == null
          ? null
          : dateOnly(contractStart),
      contractEnd:
          kind == RentEntryKind.productInstallment || contractEnd == null
          ? null
          : dateOnly(contractEnd),
      increaseDate:
          kind == RentEntryKind.productInstallment || increaseDate == null
          ? null
          : dateOnly(increaseDate),
      installmentCount: kind == RentEntryKind.homeRent
          ? null
          : installmentCount,
      currentInstallment: kind == RentEntryKind.homeRent
          ? null
          : currentInstallment,
      description: _optionalText(description, 'Açıklama', 240),
      isArchived: isArchived,
      payments: payments,
      notes: notes,
    );
  }

  ExpenseItem _buildExpense({
    required String id,
    required String currencyCode,
    required String categoryId,
    required String name,
    required double quantity,
    required double unitPrice,
    required DateTime spentAt,
    String note = '',
  }) {
    _positiveAmount(quantity, 'Adet');
    _nonNegativeAmount(unitPrice, 'Birim fiyat');
    return ExpenseItem(
      id: id,
      currencyCode: currencyCode,
      categoryId: categoryId,
      name: _requiredText(name, 'Gider adı', 100),
      quantity: quantity,
      unitPrice: unitPrice,
      spentAt: dateOnly(spentAt),
      note: _optionalText(note, 'Gider notu', 240),
    );
  }

  void _validateState(MizanState state) {
    if (!state.hasCompleteRecordCurrencies) {
      throw StateError(
        'Para taşıyan her kaydın kalıcı ISO para birimi bulunmalıdır.',
      );
    }
    if (state.setupCompleted) {
      if (state.appLanguageTag.trim().isEmpty) {
        throw StateError('Tamamlanmış profilde uygulama dili eksik.');
      }
      if (!RegExp(r'^[A-Z]{2}$').hasMatch(state.debtRegionCountryCode)) {
        throw StateError('Tamamlanmış profilde ülke kodu geçersiz.');
      }
      if (!RegExp(r'^[A-Z]{3}$').hasMatch(state.defaultCurrencyCode)) {
        throw StateError('Tamamlanmış profilde para birimi kodu geçersiz.');
      }
    }
    final ids = <String>{};
    void addId(String id, String type) {
      if (id.trim().isEmpty || !ids.add(id)) {
        throw StateError('$type kayıt kimliği geçersiz veya tekrarlı.');
      }
    }

    for (final person in state.people) {
      addId(person.id, 'Kişi');
      _requiredText(person.name, 'Kişi adı', 80);
      for (final bank in person.banks) {
        addId(bank.id, 'Banka');
        _requiredText(bank.userWrittenName, 'Banka adı', 100);
        for (final debt in bank.products) {
          addId(debt.id, 'Borç');
          if (debt.paidAmount > debt.totalAmount + 0.001) {
            throw StateError('Bir borç kaydında ödeme toplamı borcu aşıyor.');
          }
          for (final payment in debt.payments) {
            addId(payment.id, 'Ödeme');
          }
          for (final note in debt.notes) {
            addId(note.id, 'Not');
          }
        }
      }
      for (final debt in person.personalDebts) {
        addId(debt.id, 'Kişisel/kurumsal borç');
        if (debt.paidAmount > debt.totalAmount + 0.001) {
          throw StateError('Bir kişisel borçta ödeme toplamı borcu aşıyor.');
        }
        for (final scheduleItem in debt.schedule) {
          addId(scheduleItem.id, 'Ödeme planı');
        }
        for (final payment in debt.payments) {
          addId(payment.id, 'Ödeme');
        }
        for (final note in debt.notes) {
          addId(note.id, 'Not');
        }
      }
      for (final bill in person.bills) {
        addId(bill.id, 'Fatura');
        if (!bill.isMonthly && bill.paidAmount > bill.amount + 0.001) {
          throw StateError('Bir fatura kaydında ödeme toplamı tutarı aşıyor.');
        }
        if (bill.isMonthly &&
            (bill.paymentDay == null ||
                bill.paymentDay! < 1 ||
                bill.paymentDay! > 31)) {
          throw StateError('Aylık fatura ödeme günü geçersiz.');
        }
        for (final period in bill.periodAmounts) {
          if (period.amount <= 0) {
            throw StateError(
              'Dönemsel fatura tutarı sıfırdan büyük olmalıdır.',
            );
          }
        }
        for (final payment in bill.payments) {
          addId(payment.id, 'Ödeme');
        }
        for (final note in bill.notes) {
          addId(note.id, 'Not');
        }
      }
      for (final subscription in person.subscriptions) {
        addId(subscription.id, 'Abonelik');
        for (final payment in subscription.payments) {
          addId(payment.id, 'Ödeme');
        }
        for (final note in subscription.notes) {
          addId(note.id, 'Not');
        }
      }
      for (final rent in person.rents) {
        addId(rent.id, 'Kira');
        if (rent.paidAmount > rent.amount + 0.001) {
          throw StateError('Bir kira kaydında ödeme toplamı tutarı aşıyor.');
        }
        for (final payment in rent.payments) {
          addId(payment.id, 'Ödeme');
        }
        for (final note in rent.notes) {
          addId(note.id, 'Not');
        }
      }
    }
    final categoryIds = <String>{};
    for (final category in state.expenseCategories) {
      addId(category.id, 'Kategori');
      categoryIds.add(category.id);
    }
    for (final expense in state.expenses) {
      addId(expense.id, 'Gider');
      if (!categoryIds.contains(expense.categoryId)) {
        throw StateError('Bir gider kaydı bulunmayan kategoriye bağlı.');
      }
    }
  }

  PersonAccount _person(String id) => _state.people.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Kişi bulunamadı.'),
  );

  BankGroup _bank(PersonAccount person, String id) => person.banks.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Banka kaydı bulunamadı.'),
  );

  DebtProduct _debt(BankGroup bank, String id) => bank.products.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Borç kaydı bulunamadı.'),
  );

  PersonalDebtEntry _personalDebt(PersonAccount person, String id) =>
      person.personalDebts.firstWhere(
        (item) => item.id == id,
        orElse: () => throw ArgumentError('Kişisel/kurumsal borç bulunamadı.'),
      );

  SubscriptionEntry _subscription(PersonAccount person, String id) =>
      person.subscriptions.firstWhere(
        (item) => item.id == id,
        orElse: () => throw ArgumentError('Abonelik kaydı bulunamadı.'),
      );

  BillEntry _bill(PersonAccount person, String id) => person.bills.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Fatura kaydı bulunamadı.'),
  );

  RentEntry _rent(PersonAccount person, String id) => person.rents.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Kira/taksit kaydı bulunamadı.'),
  );

  PaymentRecord _paymentFor(
    PersonAccount person,
    RecordType type,
    String sourceId,
    String paymentId,
  ) {
    Iterable<PaymentRecord> payments;
    switch (type) {
      case RecordType.debt:
        payments = person.banks
            .expand((bank) => bank.products)
            .firstWhere(
              (item) => item.id == sourceId,
              orElse: () => throw ArgumentError('Borç kaydı bulunamadı.'),
            )
            .payments;
      case RecordType.personalDebt:
        payments = _personalDebt(person, sourceId).payments;
      case RecordType.bill:
        payments = _bill(person, sourceId).payments;
      case RecordType.subscription:
        payments = _subscription(person, sourceId).payments;
      case RecordType.rent:
        payments = _rent(person, sourceId).payments;
    }
    return payments.firstWhere(
      (item) => item.id == paymentId,
      orElse: () => throw ArgumentError('Ödeme kaydı bulunamadı.'),
    );
  }

  DateTime _advanceDueDate(
    DateTime dueDate,
    PaymentFrequency frequency,
    int? customDays,
  ) {
    switch (frequency) {
      case PaymentFrequency.oneTime:
        return dueDate;
      case PaymentFrequency.weekly:
        return dueDate.add(const Duration(days: 7));
      case PaymentFrequency.biweekly:
        return dueDate.add(const Duration(days: 14));
      case PaymentFrequency.monthly:
        return _addMonths(dueDate, 1);
      case PaymentFrequency.quarterly:
        return _addMonths(dueDate, 3);
      case PaymentFrequency.yearly:
        return _addMonths(dueDate, 12);
      case PaymentFrequency.custom:
        return dueDate.add(Duration(days: customDays ?? 1));
    }
  }

  DateTime _addMonths(DateTime source, int count) {
    final targetMonth = source.month - 1 + count;
    final year = source.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, source.day.clamp(1, lastDay));
  }

  double _normalizedPositive(double value, String label) {
    _positiveAmount(value, label);
    return double.parse(value.toStringAsFixed(2));
  }

  ExpenseCategory _category(String id) => _state.expenseCategories.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Gider kategorisi bulunamadı.'),
  );

  ExpenseItem _expense(String id) => _state.expenses.firstWhere(
    (item) => item.id == id,
    orElse: () => throw ArgumentError('Gider kaydı bulunamadı.'),
  );

  void _ensureUniqueBankName(
    PersonAccount person,
    String name, {
    String? excludingId,
  }) {
    final normalized = name.toLowerCase();
    if (person.banks.any(
      (bank) =>
          bank.id != excludingId &&
          bank.userWrittenName.toLowerCase() == normalized,
    )) {
      throw ArgumentError('Bu kişide aynı banka adı zaten var.');
    }
  }

  void _ensureUniqueCategoryName(String name, {String? excludingId}) {
    final normalized = name.toLowerCase();
    if (_state.expenseCategories.any(
      (category) =>
          category.id != excludingId &&
          category.name.toLowerCase() == normalized,
    )) {
      throw ArgumentError('Bu kategori adı zaten kullanılıyor.');
    }
  }

  String _requiredText(String value, String label, int maxLength) {
    final clean = value.trim();
    if (clean.isEmpty) {
      throw ArgumentError('$label boş bırakılamaz.');
    }
    if (clean.length > maxLength) {
      throw ArgumentError('$label en fazla $maxLength karakter olabilir.');
    }
    return clean;
  }

  String _optionalText(String value, String label, int maxLength) {
    final clean = value.trim();
    if (clean.length > maxLength) {
      throw ArgumentError('$label en fazla $maxLength karakter olabilir.');
    }
    return clean;
  }

  String _recordCurrency(String? value, {String? fallback}) {
    final code = (value ?? fallback ?? _state.defaultCurrencyCode)
        .trim()
        .toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw ArgumentError('Kayıt para birimi kodu geçersiz.');
    }
    return code;
  }

  void _positiveAmount(double value, String label) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError('$label sıfırdan büyük olmalı.');
    }
  }

  void _nonNegativeAmount(double value, String label) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError('$label negatif olamaz.');
    }
  }

  DebtProduct _debtBySourceId(PersonAccount person, String sourceId) {
    for (final bank in person.banks) {
      for (final debt in bank.products) {
        if (debt.id == sourceId) return debt;
      }
    }
    throw ArgumentError('Banka borcu kaydı bulunamadı.');
  }

  DateTime _dateWithDay(DateTime month, int day) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, day.clamp(1, lastDay).toInt());
  }

  DateTime _nextMonthlyDueDate(DateTime reference, int day) =>
      _dateWithDay(DateTime(reference.year, reference.month + 1), day);

  void _validateInstallments(int? total, int? current) {
    if (total != null && total <= 0) {
      throw ArgumentError('Toplam taksit pozitif olmalı.');
    }
    if (current != null && current < 0) {
      throw ArgumentError('Taksit ilerlemesi negatif olamaz.');
    }
    if (total != null && current != null && current > total) {
      throw ArgumentError('Taksit ilerlemesi toplam taksiti aşamaz.');
    }
  }

  String _friendlyError(Object error) {
    final message = error
        .toString()
        .replaceFirst('Invalid argument(s): ', '')
        .replaceFirst('Bad state: ', '')
        .replaceFirst('FormatException: ', '')
        .replaceFirst('FileSystemException: ', '');
    return MizanI18n.text(message);
  }
}
