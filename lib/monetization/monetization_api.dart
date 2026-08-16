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

class MizanMonetizationApi {
  MizanMonetizationApi({
    http.Client? client,
    String? baseUrl,
    MizanDeviceIdentity? deviceIdentity,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? MonetizationConfig.monetizationApiBaseUrl,
       _deviceIdentity = deviceIdentity ?? MizanDeviceIdentity();

  final http.Client _client;
  final String _baseUrl;
  final MizanDeviceIdentity _deviceIdentity;

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Uri _uri(String path) => Uri.parse('${_baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

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
            }),
          )
          .timeout(const Duration(seconds: 8));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final accepted = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          body['accepted'] == true;
      final untilRaw = body['premiumUntilUtc']?.toString();
      return PromoRedemptionResult(
        accepted: accepted,
        messageCode: body['messageCode']?.toString() ??
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
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['verified'] == true && body['purchaseState'] == 'PURCHASED';
    } catch (_) {
      return false;
    }
  }

  void close() => _client.close();
}
