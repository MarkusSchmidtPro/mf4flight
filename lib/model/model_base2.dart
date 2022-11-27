import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../data_model/tracked_object.dart';

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
abstract class ModelBase2 extends TrackedObject {
  static int modelSeqNo=0;
  @protected
  ModelBase2();

  /// The unique model id.
  @JsonKey(ignore: true)
  final String modelId = (++modelSeqNo).toString();

  @JsonKey(ignore: true)
  dynamic seed;

  // region Generic functions: can be called for Models based on SyncRecords
  
  bool get syncRequired => (seed==null || (seed.syncRequired));

  bool get isSaved => (seed?.id != null);
  
  // endregion
}


