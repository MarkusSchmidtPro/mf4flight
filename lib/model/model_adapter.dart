import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Provides CRUD functionality for a Model.
abstract class ModelAdapter<TModel, TSource> {
  late final Logger logger;

  @protected
  ModelAdapter() {
    logger = new Logger('$runtimeType');
  }

  TModel load(TModel model, TSource source) {
    return model;
  } // Todo

  /// Save the model's data back to its origin.
  ///
  /// The _origin_ is defined by the adapter itself, by its _seed_.
  /// For example a data_model related adapter, may implement saveAsync
  /// like this (see [FavoriteDatabaseAdapter]):
  /// ```dart
  /// class FavoriteDatabaseAdapter extends ModelAdapter<FavoriteModel> {
  ///   final FavoriteRecord seed;
  ///   FavoriteDatabaseAdapter(this.seed);
  ///
  ///   late final LocalContext _c = serviceProvider<LocalContext>();
  ///
  ///   @override
  ///   Future<void> saveAsync(FavoriteModel model) async {
  ///     seed.trackChanges(new FavoriteRecord());
  ///     seed.syncId = model.id;
  ///     seed.productName = model.productName;
  ///     ...
  ///     await _c.favorites.saveAsync(seed);
  ///     assert(!seed.isTracking());
  ///   }
  /// }
  /// ```
  /// Use the model's save functionality in the view model
  /// (see [FavoriteViewModelBase]):
  /// ```dart
  /// @override
  /// Future onsaveAsync() async {
  ///   logger.finest(">onsaveAsync()");
  ///   _viewToModel(model);
  ///   await model.saveAsync();
  ///   await serviceProvider<SyncTimer>().triggerSyncRequestAsync();
  ///   logger.finest("<onsaveAsync()");
  /// }
  /// ```
  Future<void> saveAsync(TModel model) async {
    assert(true,
        "$runtimeType does not support saveAsync for model ${TModel.runtimeType}");
  }

  Future<void> deleteAsync(TModel model) async {
    assert(true,
        "$runtimeType does not support deleteAsync for model ${TModel.runtimeType}");
  }
}

mixin AsyncCompletion<TModel, TSource> on ModelAdapter<TModel, TSource> {
  /// Complete the model by executing an asynchronous load functionality.
  ///
  /// Normally, [loadAsync] is called in the
  /// view model's [ViewModelBase.loadAsync]
  /// method (see [FavoriteMessageAdapter]):
  /// ```dart
  /// @override
  /// Future<void> loadDataAsync() async {
  ///   await model.loadAsync();
  ///   _modelToViewModel(model);
  ///   notifyListeners();
  /// }
  /// ```
  Future<void> completeAsync(TModel model);

  Future<TModel> loadCompleteAsync(TModel model, TSource source) async {
    load(model, source);
    await completeAsync(model);
    return model;
  }
}
