import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../controllers/mizan_controller.dart';
import '../core/mizan_clock.dart';
import '../models/mizan_models.dart';
import '../monetization/monetization_controller.dart';
import 'notification_service.dart';
import 'reminder_engine.dart';

class PremiumNotificationCoordinator with WidgetsBindingObserver {
  PremiumNotificationCoordinator({
    required this.controller,
    required this.monetization,
    MizanNotificationService? notificationService,
  }) : _notificationService =
           notificationService ?? MizanNotificationService();

  final MizanController controller;
  final MonetizationController monetization;
  final MizanNotificationService _notificationService;

  bool _started = false;
  bool _disposed = false;
  bool _syncing = false;
  bool _syncAgain = false;
  bool _forceNextSync = false;
  bool _hadScheduledAccess = false;
  String? _lastStateFingerprint;
  String? _lastAccessKey;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_onControllerChanged);
    monetization.addListener(_onMonetizationChanged);
    _lastAccessKey = _accessKey();
    await _sync(force: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _queueSync(force: true);
    }
  }

  void _onControllerChanged() => _queueSync();

  void _onMonetizationChanged() {
    final next = _accessKey();
    if (next == _lastAccessKey) return;
    _lastAccessKey = next;
    _queueSync(force: true);
  }

  String _accessKey() =>
      '${monetization.legalAccessGranted ? 1 : 0}:'
      '${monetization.isPremium ? 1 : 0}';

  void _queueSync({bool force = false}) {
    if (_disposed) return;
    _forceNextSync = _forceNextSync || force;
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    unawaited(_drainSyncQueue());
  }

  Future<void> _drainSyncQueue() async {
    if (_syncing || _disposed) return;
    _syncing = true;
    try {
      do {
        final force = _forceNextSync;
        _forceNextSync = false;
        _syncAgain = false;
        await _sync(force: force);
      } while (!_disposed && (_syncAgain || _forceNextSync));
    } finally {
      _syncing = false;
    }
  }

  Future<void> _sync({required bool force}) async {
    if (_disposed) return;
    final state = controller.state;
    final hasAccess =
        monetization.legalAccessGranted &&
        monetization.isPremium &&
        state.notificationsEnabled;
    if (!hasAccess) {
      if (force || _hadScheduledAccess) {
        await _notificationService.cancelAll();
      }
      _hadScheduledAccess = false;
      _lastStateFingerprint = null;
      return;
    }

    final fingerprint = jsonEncode(state.toJson());
    if (!force && fingerprint == _lastStateFingerprint) return;

    final permissionGranted = await _notificationService.requestPermission();
    if (_disposed) return;
    if (!permissionGranted) {
      await _notificationService.cancelAll();
      _hadScheduledAccess = false;
      _lastStateFingerprint = null;
      return;
    }

    final reminders = _expandedPlan(state, MizanClock.now());
    await _notificationService.replaceAll(
      reminders: reminders,
      soundMode: state.notificationSoundMode,
      vibrationEnabled: state.notificationVibrationEnabled,
    );
    _hadScheduledAccess = true;
    _lastStateFingerprint = fingerprint;
  }

  List<ScheduledReminder> _expandedPlan(MizanState state, DateTime now) {
    const builder = ReminderPlanBuilder();
    final firstPlan = builder.build(state: state, now: now);
    final daily = firstPlan
        .where((item) => item.kind == ReminderKind.expense)
        .toList(growable: false);
    final paymentsById = <int, ScheduledReminder>{};
    final today = DateTime(now.year, now.month, now.day);

    for (var offset = 0; offset <= 10; offset++) {
      final day = today.add(Duration(days: offset));
      final probe = offset == 0
          ? now
          : day.subtract(const Duration(microseconds: 1));
      final plan = builder.build(
        state: state,
        now: probe,
        maximumPaymentReminders: safeMaximumConcurrentNotifications,
      );
      for (final reminder in plan) {
        if (reminder.kind == ReminderKind.payment) {
          paymentsById.putIfAbsent(reminder.id, () => reminder);
        }
      }
    }

    final result = <ScheduledReminder>[
      ...daily,
      ...paymentsById.values,
    ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result
        .take(safeMaximumConcurrentNotifications)
        .toList(growable: false);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_onControllerChanged);
    monetization.removeListener(_onMonetizationChanged);
  }
}
