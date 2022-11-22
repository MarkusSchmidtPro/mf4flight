
import 'data_model_base.dart';

/// Provides CRUD operations on a data store.
abstract class IDataProvider2<TDataModel extends DataModelBase> {
  String get entityName => throw UnimplementedError();

  Future<List<TDataModel>> fetchAsync({String? criteria});

  Future<TDataModel> getAsync(int id);

  /// Save a data model in its store.
  /// 
  /// Saving to the store takes place, 
  /// a) when the record has never been stored before - new record (record.id==null).
  /// b) when any property of the [currentRecord] has changed (compared to the stored version of the record).
  /// 
  /// Before the [currentRecord] is written to its store, 
  /// its [currentRecord.recordVersion] and [currentRecord.recordLastUpdateUtc] 
  /// properties are updated, and in case of a new record, the [currentRecord.modelId] property is updated
  /// with the information returned by the store (SQLite behavior).
  /// 
  /// The function returns the [record.id] which is not null!
  Future<int> saveAsync(TDataModel currentRecord);

  Future deleteAsync(int id);
}
