import 'package:flutter/foundation.dart';

import 'model_adapter.dart';
import 'model_base.dart';

/// Support CRUD functionality on a [ModelBase] using a [ModelAdapter].
/// 
/// The mixin requires a [ModelAdapter] to function. 
/// The Mixin knows how to persist [ModelBase] information.
mixin ModelAdapterMixin on ModelBase {
  late final ModelAdapter _adapter;

  @protected
  ModelAdapter get adapter => _adapter;

  /// Shortcut to: [ModelAdapter.load].
  @protected
  void init(ModelAdapter modelAdapter) {
    _adapter = modelAdapter;
    adapter.load(this);
  }

  /// Shortcut to: [ModelAdapter.loadAsync].
  Future<void> loadAsync() async => await adapter.loadAsync(this);

  /// Shortcut to: [ModelAdapter.saveAsync].
  Future<void> saveAsync() async => await adapter.saveAsync(this);

  /// Shortcut to: [ModelAdapter.deleteAsync].
  Future<void> deleteAsync() async => await adapter.deleteAsync(this);
}
