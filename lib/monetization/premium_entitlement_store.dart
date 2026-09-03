import 'package:shared_preferences/shared_preferences.dart';

import 'monetization_config.dart';

enum PermanentPremiumSource { none, googlePlay, localPromotion }

class PremiumSnapshot {
  const PremiumSnapshot({
    required this.permanent,
    required this.temporaryUntilUtc,
    required this.rewardDateUtc,
    required this.rewardedViewsToday,
    required this.permanentPurchaseFingerprint,
    this.permanentSource = PermanentPremiumSource.none,
  });

  final bool permanent;
  final DateTime? temporaryUntilUtc;
  final String rewardDateUtc;
  final int rewardedViewsToday;
  final String? permanentPurchaseFingerprint;
  final PermanentPremiumSource permanentSource;

  bool hasPremiumAt(DateTime nowUtc) =>
      permanent ||
      (temporaryUntilUtc != null && temporaryUntilUtc!.isAfter(nowUtc));

  Duration remainingAt(DateTime nowUtc) {
    if (permanent) return Duration.zero;
    final end = temporaryUntilUtc;
    if (end == null || !end.isAfter(nowUtc)) return Duration.zero;
    return end.difference(nowUtc);
  }
}

class PremiumEntitlementStore {
  PremiumEntitlementStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _permanentKey = 'monetization.permanentPremium.v1';
  static const _permanentPurchaseFingerprintKey =
      'monetization.permanentPurchaseFingerprint.v1';
  static const _permanentSourceKey = 'monetization.permanentSource.v1';
  static const _temporaryUntilKey = 'monetization.temporaryUntilUtc.v1';
  static const _rewardDateKey = 'monetization.rewardDateUtc.v1';
  static const _rewardCountKey = 'monetization.rewardedViews.v1';
  static const _lastObservedUtcKey = 'monetization.lastObservedUtc.v1';

  String _dayKey(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';

  String? _normalizePermanentFingerprint(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || !RegExp(r'^[0-9a-f]{64}$').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }

  Future<DateTime> trustedNowUtc([DateTime? wallClockUtc]) async {
    final now = (wallClockUtc ?? DateTime.now().toUtc()).toUtc();
    final previousMillis = await _preferences.getInt(_lastObservedUtcKey);
    final previous = previousMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(previousMillis, isUtc: true);
    final resolved = previous != null && previous.isAfter(now) ? previous : now;
    await _preferences.setInt(
      _lastObservedUtcKey,
      resolved.millisecondsSinceEpoch,
    );
    return resolved;
  }

  Future<PremiumSnapshot> load() async {
    final now = await trustedNowUtc();
    final permanentFlag = await _preferences.getBool(_permanentKey) ?? false;
    final storedFingerprint = await _preferences.getString(
      _permanentPurchaseFingerprintKey,
    );
    final normalizedFingerprint = _normalizePermanentFingerprint(
      storedFingerprint,
    );
    final permanent = permanentFlag && normalizedFingerprint != null;
    final storedSource = await _preferences.getString(_permanentSourceKey);
    final permanentSource = !permanent
        ? PermanentPremiumSource.none
        : storedSource == PermanentPremiumSource.localPromotion.name
        ? PermanentPremiumSource.localPromotion
        : PermanentPremiumSource.googlePlay;
    if (permanentFlag && !permanent) {
      await _preferences.remove(_permanentKey);
      await _preferences.remove(_permanentPurchaseFingerprintKey);
      await _preferences.remove(_permanentSourceKey);
    } else if (!permanentFlag) {
      if (storedFingerprint != null) {
        await _preferences.remove(_permanentPurchaseFingerprintKey);
      }
      if (storedSource != null) {
        await _preferences.remove(_permanentSourceKey);
      }
    }

    final temporaryMillis = await _preferences.getInt(_temporaryUntilKey);
    var temporaryUntil = temporaryMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(temporaryMillis, isUtc: true);
    if (temporaryUntil != null && !temporaryUntil.isAfter(now)) {
      temporaryUntil = null;
      await _preferences.remove(_temporaryUntilKey);
    }

    final today = _dayKey(now);
    var rewardDate = await _preferences.getString(_rewardDateKey) ?? today;
    var rewardCount = await _preferences.getInt(_rewardCountKey) ?? 0;
    if (rewardDate != today) {
      rewardDate = today;
      rewardCount = 0;
      await _preferences.setString(_rewardDateKey, rewardDate);
      await _preferences.setInt(_rewardCountKey, 0);
    }

    return PremiumSnapshot(
      permanent: permanent,
      temporaryUntilUtc: temporaryUntil,
      rewardDateUtc: rewardDate,
      rewardedViewsToday: rewardCount
          .clamp(0, MonetizationConfig.rewardedViewsRequiredForDailyPremium)
          .toInt(),
      permanentPurchaseFingerprint: permanent ? normalizedFingerprint : null,
      permanentSource: permanentSource,
    );
  }

  Future<PremiumSnapshot> setPermanentPremium({
    required String purchaseFingerprint,
    PermanentPremiumSource source = PermanentPremiumSource.googlePlay,
  }) async {
    final normalizedFingerprint = _normalizePermanentFingerprint(
      purchaseFingerprint,
    );
    if (normalizedFingerprint == null) {
      throw ArgumentError.value(
        purchaseFingerprint,
        'purchaseFingerprint',
        'A verified 64-character SHA-256 purchase fingerprint is required.',
      );
    }
    await _preferences.remove(_temporaryUntilKey);
    await _preferences.setString(
      _permanentPurchaseFingerprintKey,
      normalizedFingerprint,
    );
    await _preferences.setString(_permanentSourceKey, source.name);
    await _preferences.setBool(_permanentKey, true);
    return load();
  }

  Future<PremiumSnapshot> clearPermanentPremium() async {
    await _preferences.remove(_permanentKey);
    await _preferences.remove(_permanentPurchaseFingerprintKey);
    await _preferences.remove(_permanentSourceKey);
    return load();
  }

  Future<PremiumSnapshot> grantTemporaryUntil(DateTime endUtc) async {
    final now = await trustedNowUtc();
    if (!endUtc.toUtc().isAfter(now)) return load();

    final currentMillis = await _preferences.getInt(_temporaryUntilKey);
    final current = currentMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(currentMillis, isUtc: true);
    final requested = endUtc.toUtc();
    final effective = current != null && current.isAfter(requested)
        ? current
        : requested;
    await _preferences.setInt(
      _temporaryUntilKey,
      effective.millisecondsSinceEpoch,
    );
    return load();
  }

  Future<PremiumSnapshot> grantTemporaryDuration(Duration duration) async {
    final now = await trustedNowUtc();
    final snapshot = await load();
    final base =
        snapshot.temporaryUntilUtc != null &&
            snapshot.temporaryUntilUtc!.isAfter(now)
        ? snapshot.temporaryUntilUtc!
        : now;
    return grantTemporaryUntil(base.add(duration));
  }

  Future<PremiumSnapshot> recordRewardedViewAndGrantIfEligible() async {
    final now = await trustedNowUtc();
    final today = _dayKey(now);
    final previousDate = await _preferences.getString(_rewardDateKey);
    final previousCount = await _preferences.getInt(_rewardCountKey);
    final previousTemporary = await _preferences.getInt(_temporaryUntilKey);

    var count = previousDate == today ? previousCount ?? 0 : 0;
    count = (count + 1)
        .clamp(0, MonetizationConfig.rewardedViewsRequiredForDailyPremium)
        .toInt();

    try {
      await _preferences.setString(_rewardDateKey, today);
      await _preferences.setInt(_rewardCountKey, count);
      if (count >= MonetizationConfig.rewardedViewsRequiredForDailyPremium) {
        final currentTemporary = previousTemporary == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                previousTemporary,
                isUtc: true,
              );
        final base = currentTemporary != null && currentTemporary.isAfter(now)
            ? currentTemporary
            : now;
        await _preferences.setInt(
          _temporaryUntilKey,
          base
              .add(MonetizationConfig.rewardedPremiumDuration)
              .millisecondsSinceEpoch,
        );
      }
      return load();
    } on Object catch (error, stackTrace) {
      try {
        if (previousDate == null) {
          await _preferences.remove(_rewardDateKey);
        } else {
          await _preferences.setString(_rewardDateKey, previousDate);
        }
        if (previousCount == null) {
          await _preferences.remove(_rewardCountKey);
        } else {
          await _preferences.setInt(_rewardCountKey, previousCount);
        }
        if (previousTemporary == null) {
          await _preferences.remove(_temporaryUntilKey);
        } else {
          await _preferences.setInt(_temporaryUntilKey, previousTemporary);
        }
      } on Object {
        Error.throwWithStackTrace(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<PremiumSnapshot> applyVerifiedTemporaryState({
    required int rewardedViewsToday,
    required DateTime? temporaryUntilUtc,
  }) async {
    final now = await trustedNowUtc();
    final today = _dayKey(now);
    await _preferences.setString(_rewardDateKey, today);
    await _preferences.setInt(
      _rewardCountKey,
      rewardedViewsToday
          .clamp(0, MonetizationConfig.rewardedViewsRequiredForDailyPremium)
          .toInt(),
    );

    final until = temporaryUntilUtc?.toUtc();
    if (until != null && until.isAfter(now)) {
      await _preferences.setInt(
        _temporaryUntilKey,
        until.millisecondsSinceEpoch,
      );
    } else {
      await _preferences.remove(_temporaryUntilKey);
    }
    return load();
  }

  Future<void> clearForTests() async {
    await _preferences.remove(_permanentKey);
    await _preferences.remove(_permanentPurchaseFingerprintKey);
    await _preferences.remove(_permanentSourceKey);
    await _preferences.remove(_temporaryUntilKey);
    await _preferences.remove(_rewardDateKey);
    await _preferences.remove(_rewardCountKey);
    await _preferences.remove(_lastObservedUtcKey);
  }
}
