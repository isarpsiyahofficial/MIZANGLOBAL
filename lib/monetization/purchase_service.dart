import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'monetization_config.dart';
import 'premium_entitlement_store.dart';

class MizanPurchaseService extends ChangeNotifier {
  MizanPurchaseService({
    InAppPurchase? inAppPurchase,
    PremiumEntitlementStore? entitlementStore,
  }) : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance,
       _entitlementStore = entitlementStore ?? PremiumEntitlementStore();

  final InAppPurchase _inAppPurchase;
  final PremiumEntitlementStore _entitlementStore;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _syncing = false;
  bool _purchasing = false;
  ProductDetails? _product;
  String? _lastError;

  bool get storeAvailable => _storeAvailable;
  bool get isSyncing => _syncing;
  bool get isPurchasing => _purchasing;
  ProductDetails? get product => _product;
  String? get lastError => _lastError;

  Future<void> initialize() async {
    if (_initialized) return;
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        _lastError = 'purchase_stream_error';
        _purchasing = false;
        _syncing = false;
        notifyListeners();
      },
      cancelOnError: false,
    );
    _initialized = true;

    try {
      _storeAvailable = await _inAppPurchase.isAvailable();
    } catch (_) {
      _storeAvailable = false;
    }
    notifyListeners();
    if (!_storeAvailable) return;

    await _loadProduct();
    unawaited(synchronizeOwnedPurchases());
  }

  Future<void> _loadProduct() async {
    try {
      final response = await _inAppPurchase.queryProductDetails({
        MonetizationConfig.permanentPremiumProductId,
      });
      for (final candidate in response.productDetails) {
        if (candidate.id == MonetizationConfig.permanentPremiumProductId) {
          _product = candidate;
          break;
        }
      }
      if (response.error != null) _lastError = 'product_query_error';
    } catch (_) {
      _lastError = 'product_query_error';
    }
    notifyListeners();
  }

  Future<bool> buyPermanentPremium() async {
    if (_purchasing || !_storeAvailable) return false;
    var currentProduct = _product;
    if (currentProduct == null) {
      await _loadProduct();
      currentProduct = _product;
    }
    if (currentProduct == null) {
      _lastError = 'product_unavailable';
      notifyListeners();
      return false;
    }

    _purchasing = true;
    _lastError = null;
    notifyListeners();
    try {
      final started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: currentProduct),
      );
      if (!started) {
        _purchasing = false;
        _lastError = 'purchase_not_started';
        notifyListeners();
      }
      return started;
    } catch (_) {
      _purchasing = false;
      _lastError = 'purchase_start_error';
      notifyListeners();
      return false;
    }
  }

  Future<void> synchronizeOwnedPurchases() async {
    if (!_initialized || !_storeAvailable || _syncing) return;
    _syncing = true;
    _lastError = null;
    notifyListeners();
    try {
      if (Platform.isAndroid) {
        final addition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final response = await addition.queryPastPurchases();
        if (response.error != null) {
          _lastError = 'silent_restore_error';
          return;
        }

        final matching = response.pastPurchases
            .where(
              (purchase) =>
                  purchase.productID ==
                  MonetizationConfig.permanentPremiumProductId,
            )
            .cast<PurchaseDetails>()
            .toList(growable: false);
        if (matching.isEmpty) {
          await _entitlementStore.clearPermanentPremium();
          notifyListeners();
          return;
        }
        await _handlePurchaseUpdates(matching);
        return;
      }

      await _inAppPurchase.restorePurchases();
    } catch (_) {
      _lastError = 'silent_restore_error';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  String _purchaseFingerprint(PurchaseDetails purchase) {
    final purchaseToken = purchase.verificationData.serverVerificationData;
    final material = '${purchase.productID}|${purchaseToken.trim()}';
    return sha256.convert(utf8.encode(material)).toString();
  }

  Future<void> _grantPermanentPurchase(PurchaseDetails purchase) async {
    await _entitlementStore.setPermanentPremium(
      purchaseFingerprint: _purchaseFingerprint(purchase),
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != MonetizationConfig.permanentPremiumProductId) {
        if (purchase.pendingCompletePurchase) {
          await _safeCompletePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.pending) {
        _purchasing = true;
        _lastError = null;
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _grantPermanentPurchase(purchase);
        _purchasing = false;
        _lastError = null;
        if (purchase.pendingCompletePurchase) {
          await _safeCompletePurchase(purchase);
        }
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        _purchasing = false;
        _lastError = 'purchase_error';
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _purchasing = false;
        _lastError = 'purchase_canceled';
        notifyListeners();
      }
    }
  }

  Future<void> _safeCompletePurchase(PurchaseDetails purchase) async {
    try {
      await _inAppPurchase.completePurchase(purchase);
    } catch (_) {
      _lastError = 'purchase_acknowledgement_error';
    }
  }

  Future<void> disposeService() async {
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    _purchasing = false;
    _syncing = false;
  }

  @override
  void dispose() {
    unawaited(disposeService());
    super.dispose();
  }
}
