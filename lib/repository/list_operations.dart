import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'i_dto_operations.dart';
import 'sqflite/db_record_base.dart';


/// List based data model provider for any type of [RecordBase].
/// 
/// The List is the Store.
class ListOperations<TListItem extends RecordBase> implements IDTOOperations<TListItem>{

  // The List Repository to store the values!
  @protected
  final HashMap<String, TListItem> items = new HashMap<String, TListItem>();
  

  static int _nextId = 0;
  static int newId() => ++_nextId;

  ListOperations( this.entityName) ;

  @override
  final String entityName;

  /// Unsorted list of items.
  @override
  Future<List<TListItem>> fetchAsync({String? criteria}) async => items.values.toList();

  @override
  Future<String> saveAsync(TListItem item) async {
    if( item.id == null) item.id= newId();
    String itemId = item.id!.toString();
    items[ itemId] = item;
    return itemId;
  }


  @override
  Future deleteSoftAsync(TListItem currenTListItem) async {
    assert( null != items.remove( currenTListItem.id));
  }

  @override
  Future<TListItem> getAsync(String id) async => items[id]!;
}