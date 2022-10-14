// ignore_for_file: unnecessary_new, invalid_use_of_protected_member

import 'package:sqflite/sqflite.dart';

import '../data_model/data_model_base.dart';
import '../data_model/database_helper.dart';
import '../data_model/i_data_provider2.dart';

/// SQLite data model provider implementation.
class SQLiteProvider2<TDataModel extends DataModelBase>
    implements IDataProvider2<TDataModel> {
  
  final Database db;

  /// Create a new SQLite provider for table=[entityName]
  SQLiteProvider2(this.db, this.entityName, this.fromJsonFactory);

  @override
  final String entityName;

  /// A function to create a new instance of [TDataModel] from a JSON Object (Map).
  /// This is to work around Dart's inability to use new TDataModel().
  final TDataModel Function(Map<String, dynamic> record) fromJsonFactory;

  /// Fetch an unsorted list of records.
  /// Returns: a List of [TDataModel] with count from 0 to n. It never returns <i>null</i>.
  @override
  Future<List<TDataModel>> fetchAsync({String? whereClause}) async {
    String sql = "SELECT * FROM $entityName";
    if (whereClause != null) sql += "WHERE ( $whereClause )";
    List<Map<String, Object?>> records = await db.rawQuery(sql);
    return records.map((record) => fromJsonFactory(record)).toList();
  }

  Future<List<TDataModel>> fetchActiveAsync({String? criteria}) async {
    String whereClause = "RecordState=${RecordState.Active}";
    if (criteria != null) whereClause += "AND ($criteria)";
    return await fetchAsync(whereClause: whereClause);
  }

  Future<List<Map<String, dynamic>>> rawQueryAsync(String sql) async =>
      await db.rawQuery(sql);

  Future<TDataModel?> getBySyncId(String itemId,
      {bool activeOnly = true}) async {
    String where = "SyncId=\'$itemId\'";
    List<TDataModel> records = activeOnly
        ? await fetchActiveAsync(criteria: where)
        : await fetchAsync(whereClause: where);
    assert(records.length <= 1, "Multiple records with same SyncId!");
    return records.length == 1 ? records[0] : null;
  }

  /// Saves the [currentRecord].
  ///
  /// If [currentRecord.id] is null a new record is inserted into the DB.
  /// Otherwise, the existing record is updated, when the provided [currentRecord] is different from the record in the DB.
  @override
  Future<int> saveAsync(TDataModel currentRecord) async {
    // Check if the provided record matches the object in the database.
    if (currentRecord.id != null &&
        currentRecord.equals(await _getAsync(currentRecord.id!)))
      return currentRecord.id!;

    currentRecord.recordVersion = DBHelper.getVersionFromNow();
    currentRecord.recordLastUpdateUtc = DBHelper.utcNow();

    if (currentRecord.id == null) {
      currentRecord.recordCreatedDateUtc = DBHelper.utcNow();
      currentRecord.id = await db.insert(entityName, currentRecord.toJson());
    } else {
      await db.update(entityName, currentRecord.toJson(),
          where: 'id=${currentRecord.id}');
    }

    return currentRecord.id!;
  }

  @override
  Future deleteAsync(int id) async {
    await db.delete(entityName, where: 'id=$id');
  }

  @override
  Future<TDataModel> getAsync(int id) async =>
      fromJsonFactory(await _getAsync(id));

  Future<Map<String, Object?>> _getAsync(int id) async {
    var records = await db.rawQuery("SELECT * FROM $entityName WHERE id=$id");
    assert(records.length == 1);
    return records[0];
  }
}
