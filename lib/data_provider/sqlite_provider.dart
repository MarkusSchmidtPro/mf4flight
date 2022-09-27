// ignore_for_file: unnecessary_new, invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../data_model/data_model_base.dart';
import '../data_model/database_helper.dart';
import '../data_model/i_data_provider2.dart';



/// SQLite data model provider implementation.
class SQLiteProvider2<TDataModel extends DataModelBase> implements IDataProvider2<TDataModel> {
  @protected
  final Database db;

  /// Create a new SQLite provider for table=[entityName]
  SQLiteProvider2(this.db, this.entityName, this.fromJsonFactory);

  @override
  final String entityName;

  /// A function to create a new instance of [TDataModel] from a JSON Object (Map).
  /// This is to work around Dart's inability to use new TDataModel().
  final TDataModel Function(Map<String, dynamic> record) fromJsonFactory;

  /// Unsorted list of items.
  @override
  Future<List<TDataModel>> fetchAllAsync() async {
    List<Map<String, Object?>> records = await db.rawQuery("SELECT * FROM $entityName");
    return records.map((record) => fromJsonFactory(record)).toList();
  }
 
  @override
  Future<int> saveAsync(TDataModel currentRecord) async {
    if (currentRecord.id != null && currentRecord.equals(await _getAsync(currentRecord.id!))) return currentRecord.id!;

    currentRecord.recordVersion = DBHelper.getVersionFromNow();
    currentRecord.recordLastUpdateUtc = DBHelper.utcNow();

    if (currentRecord.id == null) {
      currentRecord.recordCreatedDateUtc = DBHelper.utcNow();
      currentRecord.id = await db.insert(entityName, currentRecord.toJson());
    } else {
      await db.update(entityName, currentRecord.toJson(), where: 'id=${currentRecord.id}');
    }

    return currentRecord.id!;
  }

  @override
  Future deleteAsync(int id) async {
    await db.delete(entityName, where: 'id=$id');
  }

  @override
  Future<TDataModel> getAsync(int id) async => fromJsonFactory(await _getAsync(id));

  Future<Map<String, Object?>> _getAsync(int id) async {
    var records = await db.rawQuery("SELECT * FROM $entityName WHERE id=$id");
    assert(records.length == 1);
    return records[0];
  }
}
