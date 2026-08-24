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
  MizanState? _lastPersistedState;

  bool _businessDataChanged(MizanState previous, MizanState next) =>
      !identical(previous.people, next.people) ||
      !identical(previous.expenseCategories, next.expenseCategories) ||
      !identical(previous.expenses, next.expenses) ||
      !identical(previous.incomes, next.incomes);

  @override
  Future<StoreLoadResult> load() async {
    final result = await _delegate.load();
    _lastPersistedState = result.state;
    return result;
  }

  @override
  Future<void> save(MizanState state) async {
    final previous = _lastPersistedState;
    await _delegate.save(state);
    _lastPersistedState = state;
    if (previous != null && _businessDataChanged(previous, state)) {
      _onDurableMutation();
    }
  }

  @override
  Future<void> reset(MizanState state) async {
    final previous = _lastPersistedState;
    await _delegate.reset(state);
    _lastPersistedState = state;
    if (previous != null && _businessDataChanged(previous, state)) {
      _onDurableMutation();
    }
  }
}
