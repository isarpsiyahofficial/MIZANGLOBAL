import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoRedemptionResult {
  const PromoRedemptionResult({
    required this.accepted,
    required this.messageCode,
    this.premiumDuration,
  });

  final bool accepted;
  final String messageCode;
  final Duration? premiumDuration;
}

typedef PromoGrant = Future<void> Function(Duration duration);

class MizanPromoCodeService {
  MizanPromoCodeService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _fingerprints = <String, Duration>{
    '40d844f4232ec3ccfec81fd04e7256d1b3fcfcc471f2439629d21a6d80eccdaa':
        Duration(days: 7),
    '578af8ebcd839ce76ca6028fb78275d8afd4f4093cc7a01477130cbd1873bd26':
        Duration(days: 3),
  };

  static const _keyParts = <String>[
    'm1z4n-',
    'g10b4l-',
    'pr0m0-',
    'v2-2026',
    '|lefferion',
  ];

  String _normalize(String value) => value.trim().toUpperCase();

  String _fingerprint(String normalizedCode) {
    final key = utf8.encode(_keyParts.join());
    final digest = Hmac(sha256, key).convert(utf8.encode(normalizedCode));
    return digest.toString();
  }

  Future<PromoRedemptionResult> redeem(
    String rawCode, {
    PromoGrant? grant,
  }) async {
    final normalized = _normalize(rawCode);
    if (normalized.isEmpty) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'invalid_code',
      );
    }

    final fingerprint = _fingerprint(normalized);
    final duration = _fingerprints[fingerprint];
    if (duration == null) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'invalid_code',
      );
    }

    final redemptionKey = 'monetization.promo.used.v2.$fingerprint';
    final alreadyUsed = await _preferences.getBool(redemptionKey) ?? false;
    if (alreadyUsed) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'already_used',
      );
    }

    await _preferences.setBool(redemptionKey, true);
    try {
      if (grant != null) {
        await grant(duration);
      }
    } on Object {
      try {
        await _preferences.remove(redemptionKey);
      } on Object {
        // The original grant error remains the actionable failure.
      }
      rethrow;
    }

    return PromoRedemptionResult(
      accepted: true,
      messageCode: 'accepted',
      premiumDuration: duration,
    );
  }
}
