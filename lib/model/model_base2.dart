import 'package:collection/collection.dart';
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
abstract class ModelBase2 {
  /// Create a new model with a unique [modelKey]. 
  /// The [modelKey] is used to generate the unique [id]. 
  ModelBase2(String modelKey) ;//: id = "$modelKey#${++_id}";

  /// The unique model id.
  late final String id;
  static int _id = 100;

  Map<String, dynamic>? _original;


  /// Save the current state of the object.
  /// 
  /// Use this method after your have modified the current object 
  /// and when you want to save its current state for reference.
  /// 
  /// This saved (original) object state is used, for example, to check 
  /// whether the current object has been altered: [isDirty()].
  /// 
  /// If there is no plan to change (edit) a model (read/view-only), 
  /// this method is not required.
  /// 
  /// Editable / changeable models call this method in their factory 
  /// after the model has been initialized.
  /// ```dart
  /// factory ContactModel.fromRecord(ContactRecord record) {
  ///   ContactModel model = new ContactModel();
  ///   model.contactId = record.id!;
  ///   model.name = record.name;
  ///   ...
  ///   model.applyChanges();
  ///   return model;
  /// }
  /// ```
  void saveState() => _original = toJson();
  

  /// Check if the current object has bee changed 
  /// since the last call to [saveState].
  bool isDirty() {
    assert( _original!=null, "The model does not support changes. Ref. applyChanges()");
    return _original == null || !DeepCollectionEquality.unordered().equals(_original, toJson());
  }

  // region JSON Serialization
  //  flutter pub run build_runner build --delete-conflicting-outputs

  /// Serialize the current model to JSON.
  /// 
  /// This method must be overridden. 
  /// Otherwise an [UnimplementedError] is thrown.
  @protected
  Map<String, dynamic> toJson() => throw UnimplementedError( "@mustOverride: \$<ModelName>ToJson(this);");

  /// Create a new instance of the overriding class,
  /// based on a JSON Object (deserialize).
  /// 
  /// This method must be overridden. 
  /// Otherwise an [UnimplementedError] is thrown.
  @protected
  factory ModelBase2.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError("@mustOverride: \$<ModelName>FromJson(json)");

// endregion
}
