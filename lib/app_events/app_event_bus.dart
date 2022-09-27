import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:logging/logging.dart';

import '../view_model/viewmodel_base.dart';
import 'app_event.dart';
import 'i_app_events.dart';

/// [EventBus] based implementation of application events.
class AppEventBus implements IAppEvents {
  final Logger _logger = new Logger("EventBus");
  final EventBus _eventBus = new EventBus(sync: false);

  @override
  void raise<TEvent extends AppEvent>( TEvent event) {
    _logger.finest("${event.sender.runtimeType} fired $TEvent");
    assert( !((event.sender is ViewModelBase)/* && (event.sender as ViewModelBase).state != ViewModelState.ready*/),
            "Do not raise application events while view model is not ready, yet.");
    _eventBus.fire( event);
  }

  @override
  StreamSubscription subscribe<T extends AppEvent>( Object subscriber, void Function( T event) handler){
    _logger.finest("${subscriber.runtimeType} subscribes to receive $T events.");
    return _eventBus.on<T>().listen((e) => handler(e));
  }

  @override
  void unsubscribe( StreamSubscription subscription)=> subscription.cancel();
}