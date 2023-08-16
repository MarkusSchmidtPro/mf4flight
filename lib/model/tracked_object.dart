import 'package:collection/collection.dart' as tracked_object;
import 'package:flutter/foundation.dart';

abstract class TrackedObject {
  /// Serialize the current model to JSON.
  ///
  /// This method must be overridden.
  /// Otherwise an [UnimplementedError] is thrown.
  @protected
  Map<String, dynamic> toJson();

  Map<String, dynamic>? _original;

  void trackChanges() {
    //  assert(_original == null,
    //  "This data_model is already tracking changes. Call acceptChanges() or discardChanges() before you can re-activate tracking");
    // It is acceptable that a model already tracks changes. 
    _original = toJson();
  }

  void acceptChanges() => _original = null;

  bool isDirty() {
    assert(_original != null,
        "This model instance does not support changes. Ref. saveState()");
    return !tracked_object.DeepCollectionEquality.unordered()
        .equals(_original, toJson());
  }
}
