import 'package:flutter/foundation.dart';

/// Text
///
/// [IJsonObjects] require an empty default constructor for `new ()`.
abstract class IJsonObject {
  void load(Map<String, dynamic> json) => throw "@mustOverride";

  Map<String, dynamic> toJson()=> throw "@mustOverride";

  /// Deep clone a JSON object to another JSON object.
  /// Use:
  /// ```dart
  /// var proposedRecord = favoriteRecord.copyTo( new FavoriteRecord());
  /// ```
  T clone<T extends IJsonObject>(T target) {
    target.load(this.toJson());
    return target;
  }

  /// Compare two DatabaseRecords.
  ///
  /// This method must be static as it is not available in
  /// overridden classes if not explicitly implemented there.
  /// E.g. FavoriteRecord would be required to implement
  /// this method, if not static.
  bool equal<T, U>(IJsonObject originalRecord) => _jEquals(originalRecord.toJson(), this.toJson());

  static bool _jEquals<T, U>(Map<T, U>? originalRecord, Map<T, U> currentRecord) {
    if (originalRecord == null) return false;
    for (final T key in originalRecord.keys) {
      if (!currentRecord.containsKey(key) || currentRecord[key] != originalRecord[key]) {
        return false;
      }
    }
    return true;
  }


  // region Change Tracking

  IJsonObject? _original;

  /// Begin editing (tracking changes) on the current record.
  /// A [newInstance] for the current record must be provided.
  /// This new instance is then populated with the current version of the record and
  /// it acts as the original version which is later used for comparison.
  /// NOTE: This [newInstance] must be provided by the caller
  /// because Dart does not allow to create a new instance of type <T> in here.
  /// See also dart:mirrors
  /// Calling [trackChanges] on an [isDirty] record that has already tracking enabled
  /// will throw an assertion.
  void trackChanges(IJsonObject newInstance) {
    assert(_original==null || !isDirty(),
    "Tracking is enabled and record is dirty! You must call acceptChanges() or discardChanges() before.");
    newInstance.load(this.toJson());
    _original = newInstance;
  }

  /// Check if record changes are tracked. 
  /// This is the case when [trackChanges] was called on this record 
  /// or when the record is a new record with [_id] == null.
  @protected
  @mustCallSuper
  bool isTracking() => _original != null;

  /// Accept all changes on the current record and end editing (stop tracking).
  void acceptChanges() => _original = null;

  /// Discard all changed made since [trackChanges] call, and
  /// reset the record to the state before the [trackChanges] call
  /// and cancel editing (stop tracking).
  void discardChanges() {
    assert(_original != null, "Before you can discardChanges you must have started tracking.");
    this.load(_original!.toJson());
    _original = null;
  }

  // endregion

  /// A record is dirty when the record is new (_id==null, not yet in DB),
  /// when tracking has not been activated [trackChanges],
  /// or when the tracked record is not [equal] to the current record.
  @protected
  @mustCallSuper
  bool isDirty() {
    assert(_original!=null);
    assert(isTracking(), "Call on isDirty even if tracking is not activated.");
    return  !this.equal(_original!);
  }
}
