import 'package:flutter/foundation.dart';

import 'database_helper.dart';
import 'i_json_object.dart';


class RecordState {
  static const Active = 0;
  static const Deleted = 1;
}

class RecordStatus {
  static const Default = 0;
}


/// Represents a data_model record with the five standard columns,
/// and serialization [toJson] and deserialization [init] support.
class DatabaseRecord extends IDataModel{
  int? get id => _id;
  int? _id;
  setId( int value) {
    assert(_id==null);
    _id=value;
  }

  late DateTime recordLastUpdateUtc;
  late DateTime recordCreatedDateUtc;
  late int recordState;
  late int recordStatus;

  /// Create a new record instance, having
  /// [id], [recordLastUpdateUtc] = null,
  /// [recordCreatedDateUtc] = utcNow()
  /// [recordState] = [RecordState.Active]
  /// [recordStatus] = [RecordStatus.Default]
  DatabaseRecord() {
    recordCreatedDateUtc = DBHelper.utcNow();
    recordLastUpdateUtc = recordCreatedDateUtc;
    recordState = RecordState.Active;
    recordStatus = RecordStatus.Default;
  }

  /// Load JSON data into an existing instance of a DatabaseRecord.
  @mustCallSuper
  void load(Map<String, dynamic> json) {
    _id = json['_id'];
    recordLastUpdateUtc = (json['RecordLastUpdateUtc'] as String).parseToUtc();
    recordCreatedDateUtc = (json['RecordCreatedDateUtc'] as String).parseToUtc();
    recordState = json['RecordState'];
    recordStatus = json['RecordStatus'];
  }

  @override
  bool isTracking() => _id==null || super.isTracking();

  @override
  bool isDirty() => _id == null || super.isDirty();
  
  
   /// Ensure a DatabaseRecord is active.
  ///
  /// If you fetch records from the data_model you can include *deleted* records ([RecordState] == [RecordState.Deleted]).
  /// To ensure you work with active records only, you may reactivate in case, using this method.
  void ensureActive() {
    if (this.recordState != RecordState.Active) this.recordState = RecordState.Active;
  }

  /// Convert a databaseRecord object into a Map/Json.
  //@protected  if protected toJson is no longer visible on FavoriteRecord etc.
  @mustCallSuper
  Map<String, dynamic> toJson() => {
        '_id': _id,
        'RecordLastUpdateUtc': recordLastUpdateUtc.toIso8601String(),
        'RecordCreatedDateUtc': recordCreatedDateUtc.toIso8601String(),
        'RecordState': recordState,
        'RecordStatus': recordStatus
      };

  

  /// If r1 and r2 are not null: compare both records.
  /// If any of r1/r2 is null (or both) they are considered equal if
  /// both are null.
  static bool equals(DatabaseRecord? r1, DatabaseRecord? r2) => r1 != null && r2 != null ? r1.equal(r2) : (r1 == null && r2 == null);
}
