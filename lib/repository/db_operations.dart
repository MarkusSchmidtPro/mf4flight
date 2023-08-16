import 'package:collection/collection.dart';
import 'package:mf4flight/mf4flight.dart';
import 'package:sqflite/sqflite.dart';

import '../model/tracked_object.dart';

/// SQLite data model provider implementation.
class DBOperations<TRecord extends RecordBase> implements IDTOOperations<TRecord> {
  final Database db;

  /// Create a new SQLite provider for table=[entityName]
  DBOperations(this.db, this.entityName, this.fromJsonFactory);

  @override
  final String entityName;

  /// A function to create a new instance of [TRecord] from a JSON Object (Map).
  /// This is to work around Dart's inability to use new TRecord().
  final TRecord Function(Map<String, dynamic> record) fromJsonFactory;

  /// Fetch an unsorted list of records.
  /// Returns: a List of [TRecord] with count from 0 to n. It never returns <i>null</i>.
  @override
  Future<List<TRecord>> fetchAsync({String? criteria}) async {
    String sql = "SELECT * FROM $entityName";
    if (criteria != null) {
      assert(!criteria.startsWith("where"));
      sql += " WHERE ( $criteria )";
    }
    List<Map<String, Object?>> records = await db.rawQuery(sql);
    return records.map((record) => fromJsonFactory(record)).toList();
  }

  Future<List<TRecord>> fetchActiveAsync({String? criteria}) async {
    String whereClause = "recordState=${RecordState.Active}";
    if (criteria != null) whereClause += " AND ($criteria)";
    return await fetchAsync(criteria: whereClause);
  }

  Future<List<Map<String, dynamic>>> rawQueryAsync(String sql) async => await db.rawQuery(sql);

  Future<TRecord?> getByItemId(String itemId, {bool activeOnly = true}) async {
    String where = "syncId=\'$itemId\'";
    List<TRecord> records =
        activeOnly ? await fetchActiveAsync(criteria: where) : await fetchAsync(criteria: where);
    assert(records.length <= 1, "Multiple records with same SyncId!");
    return records.length == 1 ? records[0] : null;
  }

  /// Saves the [currentRecord].
  ///
  /// If [currentRecord.id] is null a new record is inserted into the DB.
  /// Otherwise, the existing record is updated, when the provided [currentRecord] is different from the record in the DB.
  @override
  Future<String> saveAsync(TRecord currentRecord) async {
    int recordId = await saveAsyncDB(currentRecord);
    return recordId.toString();
  }

  Future<int> saveAsyncDB(TRecord currentRecord, {bool updateRecordVersion = true}) async {
    // Check if the provided record matches the object in the database.
    if (currentRecord.id != null && _equals(currentRecord, await _getAsync(currentRecord.id!)))
      return currentRecord.id!;

    if (updateRecordVersion && currentRecord is SyncRecord) {
      currentRecord.recordVersion = DBUtil.getVersionFromNow();
    }
    currentRecord.recordLastUpdateUtc = Util.utcNow();

    if (currentRecord.id == null) {
      currentRecord.recordCreatedDateUtc = Util.utcNow();
      int id = await db.insert(entityName, currentRecord.toJson());
      currentRecord.id = id;
    } else {
      await db.update(entityName, currentRecord.toJson(), where: 'id=${currentRecord.id}');
    }

    if (currentRecord is TrackedObject) (currentRecord as TrackedObject).acceptChanges();

    return currentRecord.id!;
  }

  bool _equals(TRecord currentRecord, Map<String, dynamic> other) =>
      DeepCollectionEquality.unordered().equals(other, currentRecord.toJson());

  //Future _deleteHardAsync(int id) async =>  await db.delete(entityName, where: 'id=$id');

  @override
  Future deleteSoftAsync(TRecord currentRecord) async {
    currentRecord.recordState = RecordState.Deleted;
    await saveAsync(currentRecord);
  }

  @override
  Future<TRecord> getAsync(String id) async => await getAsyncDB(int.parse(id));
  
  
  Future<TRecord> getAsyncDB(int id) async => fromJsonFactory(await _getAsync(id));

  Future<Map<String, Object?>> _getAsync(int id) async {
    var records = await db.rawQuery("SELECT * FROM $entityName WHERE id=$id");
    assert(records.length == 1);
    return records[0];
  }
}
