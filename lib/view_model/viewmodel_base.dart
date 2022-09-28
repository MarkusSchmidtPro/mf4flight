import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../mf4flight.dart';

/// Extend a ViewModelBased to support data binding.
///
/// Data binging is used to pass data from a View to a ViewModel:
/// pass or bing data to the ViewModel.
mixin DataBinder<TData> on ViewModelBase {
  void bindData(TData model) {
    if (_data != null && model == _data) return;
    if (_data != null) onContextChanging(model);
    _data = model;
    if ((this is LazyLoad)) (this as LazyLoad).lazyLoad();
  }

  TData? _data;

  TData get data => _data!;

  @protected
  void onContextChanging(TData newData) {}
}

mixin LazyLoad on ViewModelBase {

  void lazyLoad() {
    _setState(ViewModelState.busy);
    onLoadAsync().then((_) {
      _setState(ViewModelState.ready);
      notifyListeners();
    });
  }

  /// Start asynchronous initialization of the ViewModel.
  /// Once this is completed the state is [ViewModelState.ready].
  ///
  /// Call this method from the View:
  /// ```
  /// Widget build(BuildContext context) => ViewModelBuilder<ContactListViewModel>.reactive(
  ///       viewModelBuilder: () => new ContactListViewModel(),
  ///       onModelReady: (viewModel) => viewModel.lazyLoad(),
  ///       builder: _buildPage);
  /// ```

  /// Provide an asynchronous initialisation functionality.
  ///
  /// [onLoadAsync] is started during [startLazyLoad] and
  /// no explicit call of asynchronous initialisation is necessary.
  @protected
  Future<void> onLoadAsync();
}

/// The base class for view models whose context does not change.
///
/// The view model's context is set once (usually in the constructor).
/// While Context's content may change and update the view (notify())
/// the context itself is fix and never changes.
abstract class ViewModelBase extends ChangeNotifier {
  late final Logger logger;

  // region ViewModel State
  late ViewModelState _state;

  /// Get the ViewModel's state.
  ///
  /// You can use this in the view to display a progress bar,
  /// for example, until the ViewModel is ready.
  /// ```
  /// body: pageVM.state != ViewModelState.ready
  ///             ? const Center(child: CircularProgressIndicator())
  ///             : _pageBody(context, pageVM),
  /// ```
  ViewModelState get state => _state;

  _setState(ViewModelState state) {
    logger.finest("ViewModelState=$state");
    _state = state;
  }

  bool get ready => _state == ViewModelState.ready;

  // endregion

  @protected
  @mustCallSuper
  ViewModelBase() : super() {
    logger = new Logger('$runtimeType');
    _setState(ViewModelState.initializing);
  }

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
