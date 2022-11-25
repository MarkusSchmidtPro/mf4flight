import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract class IModelProvider2<TModel>{
  late final Logger logger;

  @protected
  IModelProvider2() {
    logger = new Logger('$runtimeType');
  }
  
  /// Get a Model based on a "seed" record.Id.
  //Future<TModel> getAsync(int id) ;
  
  /// Save (update or insert) all model data to their 
  /// corresponding places in the data store (one or many tables).
  Future<void> saveAsync(TModel model);
  
  /// Delete all Model data from the connected data store.
  Future<void> deleteAsync(TModel model);
}