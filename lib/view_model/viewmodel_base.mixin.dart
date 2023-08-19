/*
import 'package:flutter/foundation.dart';

import '../enums.dart';
import 'viewmodel_base.dart';

/// Asynchronous data loader with arguments
mixin DataLoader<TArgs> on ViewModelBase {
  void init([TArgs? args]) {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
        if( state== ViewModelState.disposed ){ 
          logger.warning("DataLoader.asyncCompletion after dispose($instanceID");
          return;}
        //_args = args;
        state = ViewModelState.asyncLoadCompleted;
      });
    } else if (state == ViewModelState.asyncLoadCompleted) {
      state = ViewModelState.ready;
    } else if (state == ViewModelState.loading) {
      //return;
    }
  }

  //late final TArgs? args;

  @protected
  Future<void> initAsync([TArgs? args]);

  @override
  @mustCallSuper
  void dispose() => super.dispose();
}
*/
