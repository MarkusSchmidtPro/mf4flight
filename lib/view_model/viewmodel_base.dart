import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../mf4flight.dart';

/// The base class for view models whose context does not change.
///
/// The view model's context is set once (usually in the constructor).
/// While Context's content may change and update the view (notify())
/// the context itself is fix and never changes.
abstract class ViewModelBase extends ChangeNotifier {
  late final Logger logger;
  static int _instanceID =0;
  int instanceID =0;
  // region ViewModel State
  late ViewModelState _state;

  /// Get the ViewModel's state.
  ///
  /// You can use this in the view to display a progress bar,
  /// for example, until the ViewModel is ready.
  /// ```
  /// body: !pageVM.dataLoaded
  ///             ? const Center(child: CircularProgressIndicator())
  ///             : _pageBody(context, pageVM),
  /// ```
  @protected
  ViewModelState get state => _state;

  @protected
  set state(ViewModelState state) {
    logger.finest("ViewModelState=$state");
    _state = state;
  }

  bool get dataLoaded => _state != ViewModelState.loading;

  // endregion

  @protected
  @mustCallSuper
  ViewModelBase() : super() {
    instanceID = _instanceID++;
    logger = new Logger('$runtimeType($instanceID)');
    state = ViewModelState.ready;
  }

  /// The source which request to close the view.
  CloseViewRequestSource closeViewRequestSource =
      CloseViewRequestSource.backButton;

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
  void showSnackBar(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));

  // region Navigation: Show and Close

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewNamedAsync<TResult>(String routeName,
      {Object? args}) async {
    logger.finest(">$routeName show");
    TResult? result =
        await navigator.pushNamed<TResult?>(routeName, arguments: args);
    logger.finest("<$routeName closed, result=$result");
    return result;
  }

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewAsync<TResult>(StatelessWidget view) async {
    TResult? result =
        await navigator.push<TResult>(MaterialPageRoute(builder: (_) => view));
    logger.finest("$runtimeType closed, result=$result");
    return result;
  }

  /// Close the current view and return to the previous View, returning [result].
  void closeView<TResult>([TResult? result]) => navigator.pop(result);

  void closeViewWithResult<TResult>(TResult? result) => navigator.pop(result);

  // endregion

  ICommand deleteCloseViewCommand(
          {required Future<void> Function() deleteActionAsync,
          bool Function()? canExecuteAction}) =>
      new RelayCommand((context) async {
        switch (await showDeleteDialogAsync(context)) {
          case DialogResultYesNoCancel.cancel:
            break;
          case DialogResultYesNoCancel.yes:
            await deleteActionAsync();
            closeViewWithResult(ViewResult.Delete);
            break;
          case DialogResultYesNoCancel.no:
            closeViewWithResult(ViewResult.None);
            break;
        }
      }, canExecute: canExecuteAction ?? () => true);

  Future<DialogResultYesNoCancel> showDeleteDialogAsync(
          BuildContext context) async =>
      await Dialog2.showQueryDialogAsync(
          context,
          "Daten unwiderruflich löschen?",
          "Sollen die ausgewählten Daten unwiderruflich gelöscht werden?",
          actions: [Dialog2.yesButton, Dialog2.noButton],
          cancelButton: true);

  late ICommand showHelpCommand =
      new RelayPCommand((context, helpContext) async {
    await showViewAsync(HelpPage(new HelpPageArgs(helpContext)));
  });

  @mustCallSuper
  @protected
  void dispose() {
    _state = ViewModelState.disposed;
    super.dispose();
    logger.finest(
        "Dispose Instance($instanceID, Event Subscription Count=${_appEventSubscriptions.length} )");
    for (var s in _appEventSubscriptions) appEvents.unsubscribe(s);
  }
}
