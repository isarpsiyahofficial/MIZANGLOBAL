import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_aware_store.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';

class _MemoryStore implements MizanStore {
  _MemoryStore(this.state);

  MizanState state;

  @override
  Future<StoreLoadResult> load() async => StoreLoadResult(
    state: state,
    source: StoreLoadSource.primary,
  );

  @override
  Future<void> save(MizanState state) async {
    this.state = state;
  }

  @override
  Future<void> reset(MizanState state) async {
    this.state = state;
  }
}

void main() {
  test('profile preferences do not count as behavior-ad actions', () async {
    final delegate = _MemoryStore(MizanState.empty());
    var meaningfulActions = 0;
    final controller = MizanController(
      MonetizationAwareStore(
        delegate: delegate,
        onDurableMutation: () => meaningfulActions++,
      ),
    );

    await controller.load();
    await controller.updateGlobalPreferences(
      appLanguageTag: 'en',
      debtRegionCountryCode: 'US',
      defaultCurrencyCode: 'USD',
    );

    expect(meaningfulActions, 0);

    await controller.addPerson('Test Person');
    expect(meaningfulActions, 1);

    await controller.updateGlobalPreferences(
      appLanguageTag: 'tr',
      debtRegionCountryCode: 'TR',
      defaultCurrencyCode: 'TRY',
    );
    expect(meaningfulActions, 1);
  });
}
