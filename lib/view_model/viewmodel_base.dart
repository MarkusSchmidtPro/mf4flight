import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../mf4flight.dart';

abstract class ViewModelBase extends ChangeNotifier {
  late final Logger logger;

  // region ViewModel State
  late ViewModelState _state;

  ViewModelState get state => _state;

  _setState(ViewModelState state) {
    logger.finest("ViewModelState=$state");
    _state = state;
  }
  // endregion

  @protected
  @mustCallSuper
  ViewModelBase() : super() {
    logger = new Logger('$runtimeType');
    _setState( ViewModelState.initializing);
  }

  int _initCount = 0;
  void init() {
    logger.finest(">init($_initCount)");
    assert(++_initCount == 1);
    onInitAsync().then((_) {
      _setState( ViewModelState.ready);
      notifyListeners();
    });
    logger.finest("<init($_initCount)");
  }

  /// Provide an asynchronous initialisation functionality.
  /// 
  /// The [onInitAsync()] is started during [init()] and 
  /// no explicit call of asynchronous initialisation is necessary. 
  @protected
  Future<void> onInitAsync() async {}

  /// The source which request to close the view.
  CloseViewRequestSource closeViewRequestSource = CloseViewRequestSource.backButton;

  final List<StreamSubscription> _appEventSubscriptions = [];

  /// Register a Global Event handler.
  ///
  /// Event handlers are cancelled during [dispose], so don't forget!
  @protected
  void registerAppEventHandler<T extends AppEvent>(void handler(T event)) {
    _appEventSubscriptions.add(appEvents.subscribe<T>(this, handler));
    logger.finest("Subscription count=${_appEventSubscriptions.length}");
  }

  @protected
  void showSnackBar(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));

  // region Navigation: Show and Close

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewNamedAsync<TResult>(String routeName, {Object? args}) async {
    logger.finer(">$routeName show");
    TResult? result = await navigator.pushNamed<TResult?>(routeName, arguments: args);
    logger.finer("<$routeName closed, result=$result");
    return result;
  }

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewAsync<TResult>(StatelessWidget view) async {
    TResult? result = await navigator.push<TResult>(MaterialPageRoute(builder: (_) => view));
    logger.finest("$runtimeType closed, result=$result");
    return result;
  }

  /// Close the current view and return to the previous View, returning [result].
  void closeView<TResult>([TResult? result]) => navigator.pop(result);

  void closeViewWithResult<TResult>(TResult? result) => navigator.pop(result);

  // endregion

  @mustCallSuper
  @protected
  void dispose() {
    logger.finest("Dispose Instance( Event Subscription Count=${_appEventSubscriptions.length} )");
    for (var s in _appEventSubscriptions) appEvents.unsubscribe(s);
    super.dispose();
  }
}
