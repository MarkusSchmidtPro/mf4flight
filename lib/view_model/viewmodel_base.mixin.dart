
import 'package:flutter/foundation.dart';

import '../enums.dart';
import 'viewmodel_base.dart';

mixin DataLoader<TArgs> on ViewModelBase {
  void init({TArgs? args}) {
    if (_args != null && _args == args) {
      logger.finest("DataBinder2 args not changed!");
      return;
    }

    setState(ViewModelState.busy);
    initAsync(args).then((_) {
      _args = args;
      setState(ViewModelState.ready);
      notifyListeners();
    });
  }

  TArgs? _args;
  TArgs? get args => _args;

  @protected
  Future<void> initAsync(TArgs? newArgs);
}
