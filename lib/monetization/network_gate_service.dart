import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'monetization_config.dart';

class NetworkGateService extends ChangeNotifier {
  NetworkGateService({
    Connectivity? connectivity,
    http.Client? client,
    Duration? pollInterval,
    Uri? reachabilityUri,
    List<Uri>? reachabilityUris,
  }) : _connectivity = connectivity ?? Connectivity(),
       _client = client ?? http.Client(),
       _pollInterval = pollInterval ?? MonetizationConfig.networkPollInterval,
       _reachabilityUris = reachabilityUris ??
           <Uri>[
             reachabilityUri ?? Uri.parse(MonetizationConfig.reachabilityUrl),
             Uri.parse('https://cp.cloudflare.com/generate_204'),
             Uri.parse('https://www.msftconnecttest.com/connecttest.txt'),
           ];

  final Connectivity _connectivity;
  final http.Client _client;
  final Duration _pollInterval;
  final List<Uri> _reachabilityUris;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _pollTimer;
  bool _online = false;
  bool _started = false;
  bool _checking = false;

  bool get isOnline => _online;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (_) => unawaited(checkNow()),
      onError: (_) => unawaited(checkNow()),
    );

    await checkNow();
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(checkNow()));
  }

  Future<bool> checkNow() async {
    if (_checking) return _online;
    _checking = true;
    try {
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.isEmpty ||
          connectivity.every((item) => item == ConnectivityResult.none)) {
        _setOnline(false);
        return false;
      }

      final seen = <String>{};
      for (final uri in _reachabilityUris) {
        if (!seen.add(uri.toString())) continue;
        try {
          final response = await _client
              .get(
                uri,
                headers: const {
                  'Cache-Control': 'no-cache, no-store, max-age=0',
                  'Pragma': 'no-cache',
                },
              )
              .timeout(const Duration(seconds: 3));
          if (response.statusCode >= 200 && response.statusCode < 400) {
            _setOnline(true);
            return true;
          }
        } on Object {
          continue;
        }
      }
      _setOnline(false);
      return false;
    } on Object {
      _setOnline(false);
      return false;
    } finally {
      _checking = false;
    }
  }

  void _setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    unawaited(_connectivitySubscription?.cancel());
    _client.close();
    super.dispose();
  }
}
