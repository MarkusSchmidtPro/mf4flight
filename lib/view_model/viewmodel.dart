import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../app_events/app_event.dart';
import '../enums.dart';
import '../locator.dart';
import 'viewmodel_feedback_mixin.dart';
import 'viewmodel_navigation_mixin.dart';

/// The base class for view models managing observable state, lifecycle, and event subscriptions.
///
/// Integrates [ViewModelNavigationMixin] and [ViewModelFeedbackMixin] to provide
/// navigation and UI feedback capabilities while maintaining cohesive state management.
abstract class ViewModel extends ChangeNotifier
    with ViewModelNavigationMixin, ViewModelFeedbackMixin {

  static int _instanceID = 0;
  final int instanceID = _instanceID++;

  @protected
  late final Logger logger;


  @protected
  ViewModel() : super() {
    logger = Logger("$runtimeType[$instanceID]");
    logger.finest(">CreateInstance() $state");
    _init();
  }

  @protected
  Future<void> initAsync() async {}

  /// Initial fetch/setup logic.
  /// [state] is [ViewModelState.loading] until [initAsync] will have completed.
  /// Then [state] becomes [ViewModelState.ready].
  void _init() {
    state = ViewModelState.loading;
    initAsync().then((_) {
      if (state == ViewModelState.disposed) {
        logger.warning("DataLoader.asyncCompletion after dispose($instanceID)");
        return;
      }

      state = ViewModelState.ready;
      notifyListeners();
    });
  }

  /// Use this method to load/update data into an existing ViewModel.
  void update() {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync().then((_) {
        if (state == ViewModelState.disposed) {
          logger.warning("DataLoader.asyncCompletion after dispose($instanceID)");
          return;
        }

        // Set this state to non-dataLoading so that the circle disappears
        // and repaint can take place on notifyListeners()
        state = ViewModelState.refreshAfterAsyncLoad;
        notifyListeners();
      });
    } else if (state == ViewModelState.refreshAfterAsyncLoad) {
      state = ViewModelState.ready;
    }
  }

  // region ViewModel State
  ViewModelState _state = ViewModelState.ready;

  /// Get the ViewModel's state.
  ///
  /// You can use this in the view to display a progress bar,
  /// for example, until the ViewModel is ready.
  /// ```dart
  /// body: pageVM.dataLoading
  ///             ? const Center(child: CircularProgressIndicator())
  ///             : _pageBody(context, pageVM),
  /// ```
  ViewModelState get state => _state;

  set state(ViewModelState value) {
    if (_state == value) return;
    _state = value;
    // notify!?
  }

  bool get dataLoading => _state == ViewModelState.loading;

  // endregion

  final List<StreamSubscription> _appEventSubscriptions = [];

  /// Register a Global Event handler.
  ///
  /// Event handlers are automatically cancelled during [dispose].
  @protected
  void registerAppEventHandler<T extends AppEvent>(void Function(T event) handler) {
    _appEventSubscriptions.add(appEvents.subscribe<T>(this, handler));
    logger.finest("Subscription count=${_appEventSubscriptions.length}");
  }

  void closeView<TResult>({TResult? result}) {
    /* Guards against using a BuildContext after the widget that owns 
        it may have been removed from the screen.
        await pageVM.deleteFavorite.action() pauses the function while the deletion runs, 
        which can take a moment, especially over a network. During that pause, 
        the user could navigate away, the screen could be disposed, or the widget 
        tree could otherwise change. If that happens, 
        context no longer refers to a live widget in the tree.
     */
    if (!navigator.mounted) return;
    /* Closes the current route, the topmost screen in the navigation stack, 
        and returns the user to the screen beneath it.
        
        You can also pass a value back to the previous screen, like Navigator.of(context).pop(true), 
        and the caller can receive it as the result of its push call. 
        That’s useful for signaling that something changed.
     */
    navigator.pop(result);
    // required notifyListeners() on the parent view!
  }

  @mustCallSuper
  @override
  void dispose() {
    _state = ViewModelState.disposed;
    super.dispose();
    logger.finest(
        "Dispose Instance($instanceID, Event Subscription Count=${_appEventSubscriptions.length})");
    for (var s in _appEventSubscriptions) {
      appEvents.unsubscribe(s);
    }
    _appEventSubscriptions.clear();
  }
}
