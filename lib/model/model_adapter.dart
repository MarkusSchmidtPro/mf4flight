import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Provides CRUD functionality for a Model.
abstract class ModelAdapter<TContext> {
  late final Logger logger;

  @protected
  ModelAdapter() {
    logger = new Logger('$runtimeType');
  }

  /// Populate a model with the data that is available during
  /// adapter initialization - synchronous load.
  ///
  /// Normally, an adapter instance receives a _seed_ in its constructor
  /// ```dart
  ///  FavoriteDatabaseAdapter(this.seed);
  /// ```
  /// The [load] method should then _map_ the seed's information
  /// the the model (see [FavoriteModel]):
  /// ```dart
  ///  @override
  ///  void load(FavoriteModel model) {
  ///     model.id = seed.syncId;
  ///     model.productName = seed.productName;
  ///     ...
  ///  }
  void load(TContext model) => logger.finest(">Load( ModelType: ${TContext.runtimeType})");

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
  Future<void> loadAsync(TContext model) async {
    assert(true, "$runtimeType does not support loadAsync for model ${TContext.runtimeType}");
  }

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
  ///     await _c.favorites.saveChangesAsync(seed);
  ///     assert(!seed.isTracking());
  ///   }
  /// }
  /// ```
  /// Use the model's save functionality in the view model
  /// (see [FavoriteViewModelBase]):
  /// ```dart
  /// @override
  /// Future onViewSaveAsync() async {
  ///   logger.finest(">onViewSaveAsync()");
  ///   _viewToModel(model);
  ///   await model.saveAsync();
  ///   await serviceProvider<SyncTimer>().triggerSyncRequestAsync();
  ///   logger.finest("<onViewSaveAsync()");
  /// }
  /// ```
  Future<void> saveAsync(TContext model) async {
    assert(true, "$runtimeType does not support saveAsync for model ${TContext.runtimeType}");
  }

  Future<void> deleteAsync(TContext model) async {
    assert(true, "$runtimeType does not support deleteAsync for model ${TContext.runtimeType}");
  }
}
