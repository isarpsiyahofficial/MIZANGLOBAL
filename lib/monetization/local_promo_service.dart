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
    '7760e30e51c9544ea3ef88213528fc87bcc33eb8fd5addcb5d108bb234dd45c4':
        _PromoDefinition.temporary(Duration(days: 7)),
    '578af8ebcd839ce76ca6028fb78275d8afd4f4093cc7a01477130cbd1873bd26':
        _PromoDefinition.temporary(Duration(days: 3)),
    '59a5c2cb2cae38b421f53c743a5d4c492d119343c5bcd608f340e25f7b7a348d':
        _PromoDefinition.temporary(Duration(days: 7)),
    '085ddfd31876d2cf090db3fab5a73eace69701ede1370ff1b4597526c823f01c':
        _PromoDefinition.temporary(Duration(days: 30)),
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
