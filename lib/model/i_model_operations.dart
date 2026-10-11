import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract class IModelOperations<TModel> {
  @protected
  IModelOperations() {}

  /// Save (update or insert) all model data to their
  /// corresponding places in the data store (one or many tables).
  Future<void> saveAsync(TModel model);

  /// Delete all Model data from the connected data store.
  Future<void> deleteAsync(TModel model);
}
