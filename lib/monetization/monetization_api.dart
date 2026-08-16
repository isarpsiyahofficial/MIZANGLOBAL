import 'dart:convert';

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

class MizanDeviceIdentity {
  MizanDeviceIdentity({MethodChannel? channel})
    : _channel = channel ??
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
    : _channel = channel ??
          const MethodChannel('com.lefferionprime.mizanglobal/play_integrity');

  final MethodChannel _channel;

  String _requestHash(String deviceHash, String code) {
    final digest = sha256.convert(
      utf8.encode('mizan-promo-v1|$deviceHash|$code'),
    );
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  Future<String?> promoToken({
    required String deviceHash,
    required String code,
  }) async {
    final projectNumber = MonetizationConfig.playIntegrityCloudProjectNumber;
    if (projectNumber <= 0) return null;
    try {
      return await _channel.invokeMethod<String>('requestStandardToken', {
        'cloudProjectNumber': projectNumber,
        'requestHash': _requestHash(deviceHash, code),
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

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Uri _uri(String path) =>
      Uri.parse('${_baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

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

    final integrityToken = await _playIntegrity.promoToken(
      deviceHash: deviceHash,
      code: code,
    );

    try {
      final response = await _client
          .post(
            _uri('/v1/promo/redeem'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'deviceHash': deviceHash,
              'code': code,
              'platform': 'android',
              'packageName': 'com.lefferionprime.mizanglobal',
              if (integrityToken != null) 'integrityToken': integrityToken,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const PromoRedemptionResult(
          accepted: false,
          messageCode: 'invalid_server_response',
        );
      }
      final accepted = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['accepted'] == true;
      final untilRaw = decoded['premiumUntilUtc']?.toString();
      return PromoRedemptionResult(
        accepted: accepted,
        messageCode: decoded['messageCode']?.toString() ??
            (accepted ? 'accepted' : 'rejected'),
        premiumUntilUtc: untilRaw == null
            ? null
            : DateTime.tryParse(untilRaw)?.toUtc(),
      );
    } catch (_) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'network_error',
      );
    }
  }

  Future<bool> verifyGooglePlayPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    if (!isConfigured || purchaseToken.isEmpty) return false;
    try {
      final deviceHash = await _deviceIdentity.hashedDeviceId();
      final response = await _client
          .post(
            _uri('/v1/billing/google/verify'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'packageName': 'com.lefferionprime.mizanglobal',
              'productId': productId,
              'purchaseToken': purchaseToken,
              if (deviceHash != null) 'deviceHash': deviceHash,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return false;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return false;
      return decoded['verified'] == true &&
          decoded['purchaseState'] == 'PURCHASED';
    } catch (_) {
      return false;
    }
  }

  void close() => _client.close();
}
