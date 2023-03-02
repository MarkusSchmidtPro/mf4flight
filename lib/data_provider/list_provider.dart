import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../data_model/data_model_base.dart';
import '../data_model/i_data_provider2.dart';


/// List based data model provider for any type of [DataModelBase].
/// 
/// The List is the Store.
class ListProvider<TRecord extends DataModelBase> implements IRecordProvider<TRecord>{

  @protected
  final HashMap<int, TRecord> items = new HashMap<int, TRecord>();

  static int _nextId = 0;
  static int newId() => ++_nextId;

  ListProvider( this.entityName) ;

  @override
  final String entityName;

  /// Unsorted list of items.
  @override
  Future<List<TRecord>> fetchAsync({String? criteria}) async => items.values.toList();

  @override
  Future<int> saveAsync(TRecord dataModel) async {
    if( dataModel.id == null) dataModel.id= newId();
    items[ dataModel.id!] = dataModel;
    return dataModel.id!;
  }


  @override
  Future deleteSoftAsync(TRecord currentRecord) async {
    assert( null != items.remove( currentRecord.id));
  }

  @override
  Future<TRecord> getAsync(int id) async => items[id]!;
}