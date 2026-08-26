import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoRedemptionResult {
  const PromoRedemptionResult({
    required this.accepted,
    required this.messageCode,
    this.premiumDuration,
    this.permanent = false,
  });

  final bool accepted;
  final String messageCode;
  final Duration? premiumDuration;
  final bool permanent;
}

typedef PromoGrant = Future<void> Function(Duration duration);
typedef PermanentPromoGrant = Future<void> Function();

class _PromoDefinition {
  const _PromoDefinition.temporary(this.duration) : permanent = false;
  const _PromoDefinition.permanent() : duration = null, permanent = true;

  final Duration? duration;
  final bool permanent;
}

class MizanPromoCodeService {
  MizanPromoCodeService({
    SharedPreferencesAsync? preferences,
    required this.grant,
    required this.grantPermanent,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  final PromoGrant grant;
  final PermanentPromoGrant grantPermanent;

  static const _fingerprints = <String, _PromoDefinition>{
    '40d844f4232ec3ccfec81fd04e7256d1b3fcfcc471f2439629d21a6d80eccdaa':
        _PromoDefinition.temporary(Duration(days: 7)),
    '578af8ebcd839ce76ca6028fb78275d8afd4f4093cc7a01477130cbd1873bd26':
        _PromoDefinition.temporary(Duration(days: 3)),
    'd159e3b769a237992f5c6896023892fca1b27beac336207eea7995fdcb3773bd':
        _PromoDefinition.permanent(),
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

  Future<PromoRedemptionResult> redeem(String rawCode) async {
    final normalized = _normalize(rawCode);
    if (normalized.isEmpty) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'invalid_code',
      );
    }

    final fingerprint = _fingerprint(normalized);
    final definition = _fingerprints[fingerprint];
    if (definition == null) {
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
      if (definition.permanent) {
        await grantPermanent();
      } else {
        await grant(definition.duration!);
      }
    } on Object catch (grantError, grantStack) {
      try {
        await _preferences.remove(redemptionKey);
      } on Object {
        Error.throwWithStackTrace(grantError, grantStack);
      }
      Error.throwWithStackTrace(grantError, grantStack);
    }

    return PromoRedemptionResult(
      accepted: true,
      messageCode: 'accepted',
      premiumDuration: definition.duration,
      permanent: definition.permanent,
    );
  }
}
