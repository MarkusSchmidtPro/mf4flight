
import 'database_record.dart';

/// Provides CRUD operations on a data_model table.
abstract class IDataProvider<TRecord extends DatabaseRecord> {

  String get tableName;
  
  Future<int> getActiveCountAsync({String? criteria}) ;

  /// Fetch all record of the current table
  /// from data_model no matter if active or deleted.
  ///
  /// Returns: a List of TItem - never <i>null</i>
  Future<List<TRecord>> fetchAllAsync() ;

  /// Fetch active OR inactive records from data_model.
  Future<List<TRecord>> fetchAsync({String whereAndOrder = 'WHERE RecordState=${RecordState.Active}'});
  
  /// Get active items from data_model by a where-criteria
  ///
  /// Returns: a List of TItem with count 0 to n. It never returns <i>null</i>
  Future<List<TRecord>> fetchActiveAsync({String? criteria}) ;

  Future<List<Map<String, dynamic>>> rawQueryAsync(String sql) ;

  Future<TRecord?> getBySyncId(String itemId, {bool activeOnly = true});

  /// Saves a [DatabaseRecord] into the data_model.
  ///
  /// Saving a record is: create, update or soft-delete.
  ///
  /// If [isTracking] is enabled on the record changes are written,
  /// only when the record [isDirty]. If tracking has not been enabled,
  /// the record is unconditionally written to the data_model.
  /// In case the record is saved, [recordLastUpdateUtc] is set to utcNow, and
  /// changes are accepted by calling [acceptChanges].
  ///
  /// In case the record is of type [SyncRecord] the [recordVersion] is updated.
  ///
  /// Return *true* when the record was saved to DB.
  Future<bool> saveChangesAsync(TRecord record) ;

  /// Saves a [DatabaseRecord] as-is to the data_model.
  ///
  /// If `record.id == null`
  ///   Set recordCreatedDateUtc
  ///   CREATE a new record - insert.
  /// Else
  ///   UPDATE existing record.
  ///   Note: Normally, this method is used during inbound sync only.
  ///   Any business logic should prefer using [saveChangesAsync].
  ///   [recordCreatedDateUtc] is set when the record instance is created.
  Future<void> rawSaveAsync(TRecord record) ;

  /// Logically (soft) delete a record and update data_model.
  Future deleteAsync(TRecord record, {int recordStatus = RecordStatus.Default});

  Future deleteHardAsync(int id);

  /// Get all local records which require synchronization
  /// (client to service) incl. deleted ones.
  Future<List<TRecord>> getLocalChangesAsync(int minVersion) ;
}
