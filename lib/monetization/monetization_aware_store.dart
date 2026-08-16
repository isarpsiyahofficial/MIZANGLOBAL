import 'package:flutter/foundation.dart';

import '../models/mizan_models.dart';
import '../services/local_store.dart';

class MonetizationAwareStore implements MizanStore {
  MonetizationAwareStore({
    required MizanStore delegate,
    required VoidCallback onDurableMutation,
  }) : this._(delegate, onDurableMutation);

  MonetizationAwareStore._(this._delegate, this._onDurableMutation);

  final MizanStore _delegate;
  final VoidCallback _onDurableMutation;

  @override
  Future<StoreLoadResult> load() => _delegate.load();

  @override
  Future<void> save(MizanState state) async {
    await _delegate.save(state);
    _onDurableMutation();
  }

  @override
  Future<void> reset(MizanState state) async {
    await _delegate.reset(state);
    _onDurableMutation();
  }
}
