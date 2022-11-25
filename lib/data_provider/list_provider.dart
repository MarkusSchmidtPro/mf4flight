// ignore_for_file: unnecessary_new

import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../data_model/data_model_base.dart';
import '../data_model/i_data_provider2.dart';


/// List based data model provider for any type of [DataModelBase].
/// 
/// The List is the Store.
class ListProvider<TDataModel extends DataModelBase> implements IDataModelProvider<TDataModel>{
  
  @protected
  final HashMap<int, TDataModel> items = new HashMap<int, TDataModel>();

  static int _nextId = 0;
  static int newId() => ++_nextId; 
  
  ListProvider( this.entityName) ;

  @override
  final String entityName;
  
  /// Unsorted list of items.
  @override
  Future<List<TDataModel>> fetchAsync({String? criteria}) async => items.values.toList();

  @override
  Future<int> saveAsync(TDataModel dataModel) async {
    if( dataModel.id == null) dataModel.id= newId();
    items[ dataModel.id!] = dataModel;
    return dataModel.id!;
  }


  @override
  Future deleteAsync(int id) async {
    assert( null != items.remove( id));
  }

  @override
  Future<TDataModel> getAsync(int id) async => items[id]!;
}
