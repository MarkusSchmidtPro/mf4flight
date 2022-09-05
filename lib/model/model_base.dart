import 'package:flutter/foundation.dart';

import 'model_adapter.dart';

/// Represents the base class for model implementations.
///
/// A model is a logical abstraction of data. Data represents the record.
/// A model can be based on many and different records, for example:
/// Favorite, Shop & Purchase.
/// 
/// A model supports factory methods. The factory method sets the [ModelAdapter]
/// and it initializes the static (synchronous) part of the model:
/// ```dart
/// @JsonSerializable() 
/// class FavoriteModel extends ModelBase with ModelAdapterMixin 
/// {
///   factory FavoriteModel.fromRecord(FavoriteRecord record) {
///     FavoriteModel model = new FavoriteModel();
///     // Set adapter - requires ModelAdapterMixin
///     model.adapter = new FavoriteDatabaseAdapter(record);
///     // init sync part
///     model.id = record.syncId;
///     model.productName = record.productName;
///     ...
///     return model;
///   }
/// }
/// ```
abstract class ModelBase {
  late final String id;


  ModelBase();

  // region JSON Serialization
  //  flutter pub run build_runner build --delete-conflicting-outputs

  @protected
  Map<String, dynamic> toJson() => throw "@mustOverride: _\$<ModelClassName>ToJson(this);";

  @protected
  factory ModelBase.fromJson(Map<String, dynamic> json) =>
      throw "@mustOverride: _\$<ModelClassName>FromJson(json);";

  // endregion

  /// Placeholder for cloning an object.
  /// Must be implemented in the inheriting object.
  ///
  /// ```dart
  /// @override
  /// FavoriteModel deepClone()
  ///   => FavoriteModel.fromJson(toJson());
  /// ```
  @protected
  ModelBase deepClone() => throw "@mustOverride: => <ModelClassName>.fromJson(toJson());";

  /// Deep compare two models.
  bool equals<T, U>(ModelBase original) => _jEquals(original.toJson(), this.toJson());

  bool _jEquals<T, U>(Map<T, U>? originalRecord, Map<T, U> currentRecord) {
    if (originalRecord == null) return false;
    for (final T key in originalRecord.keys) {
      if (!currentRecord.containsKey(key) || currentRecord[key] != originalRecord[key]) {
        return false;
      }
    }
    return true;
  }
}
