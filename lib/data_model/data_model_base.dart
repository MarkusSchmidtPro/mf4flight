import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'database_helper.dart';


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
abstract class DataModelBase  {
  
  /// The DataModel's unique id.
  ///
  /// This id is null until the DataModel is saved.
  int? id;
  
  /// Get a millisecond-based version of the stored record.
  /// 
  /// The [recordVersion] is updated every time the data model 
  /// is written to the store.
  int recordVersion = 0;
  
  /// Logical state of the data model.
  /// 0: active
  /// 1: logically deleted
  int recordState = 0;
  
  
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
    recordCreatedDateUtc = DBHelper.utcNow();
    recordLastUpdateUtc = recordCreatedDateUtc;
  }

  /// Compare the current data model with another data model.
  /// 
  /// In unordered mode, the order of elements in iterables and lists are not important.
  /// See also [DeepCollectionEquality.unordered].
  bool equals(Map<String, dynamic> other)=> (id != null &&
        DeepCollectionEquality.unordered().equals(other, toJson()));

  /// Serialize the current object to JSON (Map). 
  ///   
  /// JSON serialization must be overridden by inheriting class.
  @protected
  Map<String, dynamic> toJson() => throw UnimplementedError();
}
