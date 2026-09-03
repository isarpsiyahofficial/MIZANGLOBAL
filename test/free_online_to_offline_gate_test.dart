import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/monetization/free_offline_gate.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_controller.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_scope.dart';
import 'package:lefferion_prime_mizan/monetization/network_gate_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/widgets/responsive_scaffold.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'test_support.dart';

class _MutableNetworkGate extends NetworkGateService {
  _MutableNetworkGate({required this.online});

  bool online;

  @override
  bool get isOnline => online;

  @override
  Future<void> start() async {}

  @override
  Future<bool> checkNow() async => online;

  void setOnline(bool value) {
    if (online == value) return;
    online = value;
    notifyListeners();
  }
}

Future<(MizanController, MonetizationController)> _pumpApplication(
  WidgetTester tester, {
  required _MutableNetworkGate network,
  bool permanentPro = false,
}) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(const <String, Object>{});
  final entitlementStore = PremiumEntitlementStore();
  if (permanentPro) {
    await entitlementStore.setPermanentPremium(
      purchaseFingerprint:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
  }

  final monetization = MonetizationController(
    entitlementStore: entitlementStore,
    networkGate: network,
  );
  await monetization.initialize(legalAccessGranted: true);

  final core = MizanController(
    MemoryStore(comprehensiveState()),
    scheduler: SpyScheduler(),
  );
  await core.load();

  await tester.pumpWidget(
    MonetizationScope(
      controller: monetization,
      child: MaterialApp(home: MizanHome(controller: core)),
    ),
  );
  await tester.pumpAndSettle();
  return (core, monetization);
}

Future<void> _disposeApplication(
  WidgetTester tester,
  MizanController core,
  MonetizationController monetization,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  monetization.dispose();
  core.dispose();
  await tester.pump();
}

void main() {
  testWidgets(
    'free user already inside the app is blocked when internet disappears',
    (tester) async {
      final network = _MutableNetworkGate(online: true);
      final (core, monetization) = await _pumpApplication(
        tester,
        network: network,
      );

      expect(monetization.isPremium, isFalse);
      expect(monetization.canUseApp, isTrue);
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
      expect(find.byType(FreeOfflineGate), findsNothing);

      network.setOnline(false);
      await tester.pump();

      expect(monetization.canUseApp, isFalse);
      expect(find.byType(ResponsiveScaffold), findsNothing);
      expect(find.byType(FreeOfflineGate), findsOneWidget);

      network.setOnline(true);
      await tester.pump();

      expect(monetization.canUseApp, isTrue);
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
      expect(find.byType(FreeOfflineGate), findsNothing);

      await _disposeApplication(tester, core, monetization);
    },
  );

  testWidgets('valid permanent PRO remains usable across the same outage', (
    tester,
  ) async {
    final network = _MutableNetworkGate(online: true);
    final (core, monetization) = await _pumpApplication(
      tester,
      network: network,
      permanentPro: true,
    );

    expect(monetization.isPermanentPremium, isTrue);
    expect(monetization.canUseApp, isTrue);

    network.setOnline(false);
    await tester.pump();

    expect(monetization.canUseApp, isTrue);
    expect(find.byType(ResponsiveScaffold), findsOneWidget);
    expect(find.byType(FreeOfflineGate), findsNothing);

    await _disposeApplication(tester, core, monetization);
  });
}
