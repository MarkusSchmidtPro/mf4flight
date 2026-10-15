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
abstract class ViewModel<TArgs> extends ChangeNotifier
    with ViewModelNavigationMixin, ViewModelFeedbackMixin {
  @override
  late final Logger logger;
  static int _instanceID = 0;
  final int instanceID = _instanceID++;

  @protected
  ViewModel() : super() {
    logger = Logger("$runtimeType[$instanceID]");
    logger.finest(">CreateInstance() $state");
  }

  @protected
  Future<void> initAsync([TArgs? args]) async {}

  /// Use for detail views to init data asynchronously, only one.
  void init({TArgs? args, ViewModelState readyState = ViewModelState.ready}) {
    if (state != ViewModelState.ready) return;

    state = ViewModelState.loading;
    initAsync(args).then((_) {
      if (state == ViewModelState.disposed) {
        logger.warning("DataLoader.asyncCompletion after dispose($instanceID)");
        return;
      }

      state = readyState;
      notifyListeners();
    });
  }

  /// Use this method to load/update data into an existing ViewModel.
  void update(TArgs args) {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
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
    logger.finest("State: $_state");
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
