import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract class IModelOperations<TModel>{
  late final Logger logger;

  @protected
  IModelOperations() {
    logger = new Logger('$runtimeType');
  }
  
  /// Save (update or insert) all model data to their 
  /// corresponding places in the data store (one or many tables).
  Future<void> saveAsync(TModel model);
  
  /// Delete all Model data from the connected data store.
  Future<void> deleteAsync(TModel model);
}