import 'package:flutter/foundation.dart';

import '../enums.dart';
import 'viewmodel_base.dart';

mixin DataLoader<TArgs> on ViewModelBase {
  void init({TArgs? args}) {
    
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
        _args = args;
        state = ViewModelState.asyncLoadCompleted;
        notifyListeners();
      });
    } else if (state == ViewModelState.asyncLoadCompleted) {
      state = ViewModelState.ready;
    } else if (state == ViewModelState.loading) {
      return;
    }
  }

  TArgs? _args;

  TArgs? get args => _args;

  @protected
  Future<void> initAsync(TArgs? newArgs);
}
