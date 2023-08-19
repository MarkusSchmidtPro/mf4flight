import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../mf4flight.dart';
import '../view/textWithCountdown.dart';



/// The base class for view models whose context does not change.
///
/// The view model's context is set once (usually in the constructor).
/// While Context's content may change and update the view (notify())
/// the context itself is fix and never changes.
abstract class ViewModelBase<TArgs> extends ChangeNotifier {
  late final Logger logger;
  static int _instanceID = 0;
  final int instanceID = _instanceID++;

  @protected
  ViewModelBase() : super() {
    logger = new Logger("$runtimeType[$instanceID]");
    logger.finer(">CreateInstance() $state");
  }

  @protected
  Future<void> initAsync([TArgs? args]) async {}

  /// Use for detail views to init data asynchronously, only one.
  void init({TArgs? args, ViewModelState readyState = ViewModelState.ready}) {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
        assert(state != ViewModelState.disposed,
            "DataLoader.asyncCompletion after dispose($instanceID)");
        state = ViewModelState.ready;
        notifyListeners();
      });
    }
  }

  /// Use this method to load/update data into an existing ViewModel.
  void update(TArgs args) {
    if (state == ViewModelState.ready) {
      state = ViewModelState.loading;
      initAsync(args).then((_) {
        assert(state != ViewModelState.disposed,
            "DataLoader.asyncCompletion after dispose($instanceID)");

        // Set this state to non-dataLoading so that the circle disappears
        // and repaint can take place on notifyListeners()
        state = ViewModelState.refreshAfterAsyncLoad;
        notifyListeners();
        // this will refresh the screen and on a list it'll call init() again
        // this second init() will then go to
        // the next if: state == ViewModelState.refreshAfterAsyncLoad
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
  /// ```
  /// body: pageVM.dataLoading
  ///             ? const Center(child: CircularProgressIndicator())
  ///             : _pageBody(context, pageVM),
  /// ```
  ViewModelState get state => _state;

  set state(ViewModelState value) {
    if (_state == value) return;
    _state = value;
    logger.finer("State: $_state");
  }

  bool get dataLoading => _state == ViewModelState.loading;

  // endregion

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

  //@protected
  void showSnackBar(String message,
      {Future<void> Function()? commitFuncAsync,
      int commitDelay = 5,
      VoidCallback? rollbackFunc,
      String? rollbackLabel}) {
    SnackBarAction? rollbackAction;
    if (rollbackFunc != null) {
      rollbackAction = SnackBarAction(label: rollbackLabel ?? "", onPressed: rollbackFunc);
    }
    /*
      The ScaffoldMessengerState.showSnackBar function returns a ScaffoldFeatureController. 
      The value of the controller's closed property is a Future that resolves to a SnackBarClosedReason. 
      Applications that need to know how a snackbar was closed can use this value.
      See: https://api.flutter.dev/flutter/material/SnackBarClosedReason.html
     */
    messenger
        .showSnackBar(SnackBar(
          content: TextWithCountdown(
            text: message,
            countValue: commitDelay,
          ),
          action: rollbackAction,
          duration: Duration(seconds: commitDelay),
        ))
        .closed
        .then((SnackBarClosedReason reason) async {
      if (reason != SnackBarClosedReason.action && commitFuncAsync != null) {
        await commitFuncAsync();
      }
    });
  }

  // region Navigation: Show and Close

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewNamedAsync<TResult>(String routeName, {Object? args}) async {
    logger.finest(">$routeName show");
    TResult? result = await navigator.pushNamed<TResult?>(routeName, arguments: args);
    logger.finest("<$routeName closed, result=$result");
    return result;
  }

  /// Navigator to a view
  /// Pattern: https://www.notion.so/markusschmidtpro/Open-View-Navigate-to-page-93709bb5d0df47158387a97b1c41bd79#132f061dad8644b5a0c8de840275694b
  Future<TResult?> showViewAsync<TResult>(StatelessWidget view) async {
    TResult? result = await navigator.push<TResult>(MaterialPageRoute(builder: (_) => view));
    logger.finest("$runtimeType closed, result=$result");
    return result;
  }

  /// Close the current view and return to the previous view, returning [result].
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

  Future<DialogResultYesNoCancel> showDeleteDialogAsync(BuildContext context) async =>
      await Dialog2.showQueryDialogAsync(context, "Daten unwiderruflich lÃ¶schen?",
          "Sollen die ausgewÃ¤hlten Daten unwiderruflich gelÃ¶scht werden?",
          actions: [Dialog2.yesButton, Dialog2.noButton], cancelButton: true);

  late ICommand showHelpCommand = new RelayPCommand((context, helpContext) async {
    await showViewAsync(HelpPage.show(new HelpPageArgs(helpContext)));
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
