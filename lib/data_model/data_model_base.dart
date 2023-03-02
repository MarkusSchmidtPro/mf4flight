import 'package:flutter/foundation.dart';
import 'package:mf4flight/mf4flight.dart';


class RecordState {
  static const Active = 0;
  static const Deleted = 1;
}


/// Represents the base class from which all data models inherit.
///
/// Classes that inherit from [DataModelBase] must be @JsonSerializable()
/// and override [toJson()]. Otherwise an [UnimplementedError] is thrown.
///
/// ```dart
/// part 'contact_record.g.dart';
/// // flutter pub run build_runner watch --delete-conflicting-outputs
///
/// /// In-Memory and serializable data representation.
/// @JsonSerializable()
/// class ContactRecord extends DataModelBase {
///   String? name;
///   String? email;
///
///   @override
///   factory ContactRecord.fromJson(Map<String, dynamic> json) => _$ContactRecordFromJson(json);
///
///   @override
///   Map<String, dynamic> toJson() => _$ContactRecordToJson(this);
/// }
/// ```
abstract class DataModelBase {
  /// The DataModel's unique id.
  ///
  /// This id is null until the DataModel is saved.
  int? id;

  /// Logical state of the data model.
  /// 0: active
  /// 1: logically deleted
  int recordState = RecordState.Active;

  late DateTime recordLastUpdateUtc;
  late DateTime recordCreatedDateUtc;

  /// Create a new record instance, having
  /// [id]  = null,
  /// [recordVersion] = 0
  /// [recordState] = 0
  /// [recordCreatedDateUtc] = utcNow()
  /// [recordLastUpdateUtc] = utcNow()
  @mustCallSuper
  @protected
  DataModelBase() {
    recordCreatedDateUtc = Util.utcNow();
    recordLastUpdateUtc = recordCreatedDateUtc;
  }

  /// Serialize the current object to JSON (Map).
  ///
  /// JSON serialization must be overridden by inheriting class.
  @protected
  Map<String, dynamic> toJson();
}