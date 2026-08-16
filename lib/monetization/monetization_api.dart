import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'monetization_config.dart';

class PromoRedemptionResult {
  const PromoRedemptionResult({
    required this.accepted,
    required this.messageCode,
    this.premiumUntilUtc,
  });

  final bool accepted;
  final String messageCode;
  final DateTime? premiumUntilUtc;
}

class RewardSessionResult {
  const RewardSessionResult({
    required this.accepted,
    required this.messageCode,
    required this.rewardedViewsToday,
    this.sessionId,
    this.premiumUntilUtc,
    this.sessionRewarded = false,
  });

  final bool accepted;
  final String messageCode;
  final int rewardedViewsToday;
  final String? sessionId;
  final DateTime? premiumUntilUtc;
  final bool sessionRewarded;
}

class TemporaryEntitlementResult {
  const TemporaryEntitlementResult({
    required this.accepted,
    required this.messageCode,
    required this.rewardedViewsToday,
    this.premiumUntilUtc,
  });

  final bool accepted;
  final String messageCode;
  final int rewardedViewsToday;
  final DateTime? premiumUntilUtc;
}

class MizanDeviceIdentity {
  MizanDeviceIdentity({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('com.lefferionprime.mizanglobal/device_identity');

  final MethodChannel _channel;

  Future<String?> hashedDeviceId() async {
    try {
      final raw = await _channel.invokeMethod<String>('getAndroidId');
      if (raw == null || raw.trim().isEmpty) return null;
      final normalized =
          'mizan-global|com.lefferionprime.mizanglobal|${raw.trim()}';
      return sha256.convert(utf8.encode(normalized)).toString();
    } on PlatformException {
      return null;
    }
  }
}

class MizanPlayIntegrity {
  MizanPlayIntegrity({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('com.lefferionprime.mizanglobal/play_integrity');

  final MethodChannel _channel;

  String _requestHash({
    required String purpose,
    required String deviceHash,
    required String nonce,
  }) {
    final digest = sha256.convert(utf8.encode('$purpose|$deviceHash|$nonce'));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  Future<String?> requestToken({
    required String purpose,
    required String deviceHash,
    required String nonce,
  }) async {
    final projectNumber = MonetizationConfig.playIntegrityCloudProjectNumber;
    if (projectNumber <= 0) return null;
    try {
      return await _channel.invokeMethod<String>('requestStandardToken', {
        'cloudProjectNumber': projectNumber,
        'requestHash': _requestHash(
          purpose: purpose,
          deviceHash: deviceHash,
          nonce: nonce,
        ),
      });
    } on PlatformException {
      return null;
    }
  }
}

class MizanMonetizationApi {
  MizanMonetizationApi({
    http.Client? client,
    String? baseUrl,
    MizanDeviceIdentity? deviceIdentity,
    MizanPlayIntegrity? playIntegrity,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? MonetizationConfig.monetizationApiBaseUrl,
       _deviceIdentity = deviceIdentity ?? MizanDeviceIdentity(),
       _playIntegrity = playIntegrity ?? MizanPlayIntegrity();

  final http.Client _client;
  final String _baseUrl;
  final MizanDeviceIdentity _deviceIdentity;
  final MizanPlayIntegrity _playIntegrity;
  final Random _random = Random.secure();

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Uri _uri(String path) =>
      Uri.parse('${_baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  String _nonce() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<Map<String, dynamic>?> _postJson(
    String path,
    Map<String, Object?> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      decoded['_httpOk'] =
          response.statusCode >= 200 && response.statusCode < 300;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseUtc(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  int _rewardCount(Object? value) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return parsed
        .clamp(0, MonetizationConfig.rewardedViewsRequiredForDailyPremium)
        .toInt();
  }

  Future<PromoRedemptionResult> redeemPromo(String rawCode) async {
    if (!isConfigured) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'backend_not_configured',
      );
    }
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'invalid_code',
      );
    }
    final deviceHash = await _deviceIdentity.hashedDeviceId();
    if (deviceHash == null) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'device_identity_unavailable',
      );
    }

    final nonce = '${_nonce()}.$code';
    final integrityToken = await _playIntegrity.requestToken(
      purpose: 'mizan-promo-v1',
      deviceHash: deviceHash,
      nonce: nonce,
    );
    final decoded = await _postJson('/v1/promo/redeem', {
      'deviceHash': deviceHash,
      'code': code,
      'nonce': nonce,
      'platform': 'android',
      'packageName': 'com.lefferionprime.mizanglobal',
      if (integrityToken != null) 'integrityToken': integrityToken,
    });
    if (decoded == null) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'network_error',
      );
    }
    final accepted = decoded['_httpOk'] == true && decoded['accepted'] == true;
    return PromoRedemptionResult(
      accepted: accepted,
      messageCode:
          decoded['messageCode']?.toString() ??
          (accepted ? 'accepted' : 'rejected'),
      premiumUntilUtc: _parseUtc(decoded['premiumUntilUtc']),
    );
  }

  Future<RewardSessionResult> createRewardSession() async {
    if (!isConfigured) {
      return const RewardSessionResult(
        accepted: false,
        messageCode: 'backend_not_configured',
        rewardedViewsToday: 0,
      );
    }
    final deviceHash = await _deviceIdentity.hashedDeviceId();
    if (deviceHash == null) {
      return const RewardSessionResult(
        accepted: false,
        messageCode: 'device_identity_unavailable',
        rewardedViewsToday: 0,
      );
    }
    final nonce = _nonce();
    final integrityToken = await _playIntegrity.requestToken(
      purpose: 'mizan-reward-session-v1',
      deviceHash: deviceHash,
      nonce: nonce,
    );
    final decoded = await _postJson('/v1/reward/session', {
      'deviceHash': deviceHash,
      'nonce': nonce,
      'platform': 'android',
      'packageName': 'com.lefferionprime.mizanglobal',
      if (integrityToken != null) 'integrityToken': integrityToken,
    });
    if (decoded == null) {
      return const RewardSessionResult(
        accepted: false,
        messageCode: 'network_error',
        rewardedViewsToday: 0,
      );
    }
    final accepted = decoded['_httpOk'] == true && decoded['accepted'] == true;
    return RewardSessionResult(
      accepted: accepted,
      messageCode:
          decoded['messageCode']?.toString() ??
          (accepted ? 'accepted' : 'rejected'),
      rewardedViewsToday: _rewardCount(decoded['rewardedViewsToday']),
      sessionId: decoded['sessionId']?.toString(),
      premiumUntilUtc: _parseUtc(decoded['premiumUntilUtc']),
    );
  }

  Future<RewardSessionResult> rewardSessionStatus(String sessionId) async {
    if (!isConfigured || sessionId.trim().isEmpty) {
      return const RewardSessionResult(
        accepted: false,
        messageCode: 'invalid_request',
        rewardedViewsToday: 0,
      );
    }
    final decoded = await _postJson('/v1/reward/session/status', {
      'sessionId': sessionId.trim(),
    }, timeout: const Duration(seconds: 8));
    if (decoded == null) {
      return const RewardSessionResult(
        accepted: false,
        messageCode: 'network_error',
        rewardedViewsToday: 0,
      );
    }
    final accepted = decoded['_httpOk'] == true && decoded['accepted'] == true;
    return RewardSessionResult(
      accepted: accepted,
      messageCode:
          decoded['messageCode']?.toString() ??
          (accepted ? 'accepted' : 'rejected'),
      rewardedViewsToday: _rewardCount(decoded['rewardedViewsToday']),
      sessionId: sessionId,
      premiumUntilUtc: _parseUtc(decoded['premiumUntilUtc']),
      sessionRewarded: decoded['sessionRewarded'] == true,
    );
  }

  Future<TemporaryEntitlementResult> syncTemporaryEntitlement() async {
    if (!isConfigured) {
      return const TemporaryEntitlementResult(
        accepted: false,
        messageCode: 'backend_not_configured',
        rewardedViewsToday: 0,
      );
    }
    final deviceHash = await _deviceIdentity.hashedDeviceId();
    if (deviceHash == null) {
      return const TemporaryEntitlementResult(
        accepted: false,
        messageCode: 'device_identity_unavailable',
        rewardedViewsToday: 0,
      );
    }
    final nonce = _nonce();
    final integrityToken = await _playIntegrity.requestToken(
      purpose: 'mizan-entitlement-sync-v1',
      deviceHash: deviceHash,
      nonce: nonce,
    );
    final decoded = await _postJson('/v1/entitlement/temporary/sync', {
      'deviceHash': deviceHash,
      'nonce': nonce,
      'platform': 'android',
      'packageName': 'com.lefferionprime.mizanglobal',
      if (integrityToken != null) 'integrityToken': integrityToken,
    });
    if (decoded == null) {
      return const TemporaryEntitlementResult(
        accepted: false,
        messageCode: 'network_error',
        rewardedViewsToday: 0,
      );
    }
    final accepted = decoded['_httpOk'] == true && decoded['accepted'] == true;
    return TemporaryEntitlementResult(
      accepted: accepted,
      messageCode:
          decoded['messageCode']?.toString() ??
          (accepted ? 'synced' : 'rejected'),
      rewardedViewsToday: _rewardCount(decoded['rewardedViewsToday']),
      premiumUntilUtc: _parseUtc(decoded['premiumUntilUtc']),
    );
  }

  Future<bool> verifyGooglePlayPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    if (!isConfigured || purchaseToken.isEmpty) return false;
    final decoded = await _postJson('/v1/billing/google/verify', {
      'packageName': 'com.lefferionprime.mizanglobal',
      'productId': productId,
      'purchaseToken': purchaseToken,
    }, timeout: const Duration(seconds: 10));
    return decoded != null &&
        decoded['_httpOk'] == true &&
        decoded['verified'] == true &&
        decoded['purchaseState'] == 'PURCHASED';
  }

  void close() => _client.close();
}
