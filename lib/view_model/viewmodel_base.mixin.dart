import 'package:flutter/foundation.dart';

import '../enums.dart';
import 'viewmodel_base.dart';

/// Asynchronous data loader with arguments
mixin DataLoader<TArgs> on ViewModelBase {
  void init({required TArgs args}) {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
        if( state== ViewModelState.disposed ){ 
          logger.warning("DataLoader.asyncCompletion after dispose($instanceID");
          return;}
        _args = args;
        state = ViewModelState.asyncLoadCompleted;
        refreshView();
      });
    } else if (state == ViewModelState.asyncLoadCompleted) {
      state = ViewModelState.ready;
    } else if (state == ViewModelState.loading) {
      //return;
    }
  }

  TArgs? _args;

  TArgs? get args => _args;

  @protected
  Future<void> initAsync(TArgs args);

  @override
  @mustCallSuper
  void dispose() => super.dispose();
}

/// Asynchronous data loader without arguments
mixin DataLoaderN on ViewModelBase {
  void init() {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync().then((_) {
        if( state== ViewModelState.disposed ){
          logger.warning("DataLoader.asyncCompletion after dispose($instanceID");
          return;}
        state = ViewModelState.asyncLoadCompleted;
        refreshView();
      });
    } else if (state == ViewModelState.asyncLoadCompleted) {
      state = ViewModelState.ready;
    } else if (state == ViewModelState.loading) {}
  }

  @protected
  Future<void> initAsync();

  @override
  @mustCallSuper
  void dispose() => super.dispose();
}

/// Extend a ViewModelBased to support data binding.
///
/// Data binging is used to pass data from a View to a ViewModel:
/// pass or bing data to the ViewModel.
@deprecated
mixin DataBinder<TData> on ViewModelBase {
  void bindData(TData model) {
    if (_data != null && model == _data) return;
    if (_data != null) onContextChanging(model);
    _data = model;
  }

  TData? _data;

  TData get data => _data!;

  @protected
  void onContextChanging(TData newData) {}

  @override
  @mustCallSuper
  void dispose() => super.dispose();
}