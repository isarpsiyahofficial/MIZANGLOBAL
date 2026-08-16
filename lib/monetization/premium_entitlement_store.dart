import 'package:shared_preferences/shared_preferences.dart';

class PremiumSnapshot {
  const PremiumSnapshot({
    required this.permanent,
    required this.temporaryUntilUtc,
    required this.rewardDateUtc,
    required this.rewardedViewsToday,
  });

  final bool permanent;
  final DateTime? temporaryUntilUtc;
  final String rewardDateUtc;
  final int rewardedViewsToday;

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
  static const _temporaryUntilKey = 'monetization.temporaryUntilUtc.v1';
  static const _rewardDateKey = 'monetization.rewardDateUtc.v1';
  static const _rewardCountKey = 'monetization.rewardedViews.v1';
  static const _lastObservedUtcKey = 'monetization.lastObservedUtc.v1';

  String _dayKey(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';

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
    final permanent = await _preferences.getBool(_permanentKey) ?? false;
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
      rewardedViewsToday: rewardCount.clamp(0, 3).toInt(),
    );
  }

  Future<PremiumSnapshot> setPermanentPremium() async {
    await _preferences.setBool(_permanentKey, true);
    await _preferences.remove(_temporaryUntilKey);
    return load();
  }

  Future<PremiumSnapshot> clearPermanentPremium() async {
    await _preferences.remove(_permanentKey);
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
    final base = snapshot.temporaryUntilUtc != null &&
            snapshot.temporaryUntilUtc!.isAfter(now)
        ? snapshot.temporaryUntilUtc!
        : now;
    return grantTemporaryUntil(base.add(duration));
  }

  Future<PremiumSnapshot> recordRewardedView() async {
    final now = await trustedNowUtc();
    final today = _dayKey(now);
    final storedDate = await _preferences.getString(_rewardDateKey);
    var count = await _preferences.getInt(_rewardCountKey) ?? 0;
    if (storedDate != today) count = 0;
    count = (count + 1).clamp(0, 3).toInt();
    await _preferences.setString(_rewardDateKey, today);
    await _preferences.setInt(_rewardCountKey, count);
    return load();
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
      rewardedViewsToday.clamp(0, 3).toInt(),
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
    await _preferences.remove(_temporaryUntilKey);
    await _preferences.remove(_rewardDateKey);
    await _preferences.remove(_rewardCountKey);
    await _preferences.remove(_lastObservedUtcKey);
  }
}
