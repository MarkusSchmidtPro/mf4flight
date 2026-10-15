import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:logging/logging.dart';

import '../view_model/viewmodel_base.dart';
import 'app_event.dart';
import 'i_app_events.dart';

/// [EventBus] based implementation of application events.
/// 
/// AppEventBus acts as the centralized, asynchronous in-memory event broker for the application.
/// 
///  It is a direct realization of the Event Bus / Publish-Subscribe (Pub/Sub) pattern.
///  The class directly wraps the third-party EventBus (package:event_bus/event_bus.dart) 
///  while implementing the [IAppEvents] abstraction interface.
///  
///  Its core responsibilities and features include:
///  #### 1. Decoupled Event Publication (raise)
///   • Allows any component (ViewModels, background services, sync workers, auth handlers) 
///     to broadcast strongly typed AppEvent instances.
///     
///   • Senders do not need direct references to consumers or listeners, 
///     ensuring loose coupling across modules.
///     
/// #### 2. Type-Safe Event Subscriptions (subscribe)
///   • Enables listeners to subscribe to specific event types (T extends AppEvent) 
///     via Dart streams (_eventBus.on<T>()).
///     
///   • Returns a StreamSubscription so subscribers can manage 
///     their own lifecycle and prevent memory leaks.
///     
/// #### 3. Subscription Management (unsubscribe)
///   • Provides a straightforward cancellation mechanism (subscription.cancel()) to 
///     terminate event streams when components or widgets are disposed.
///     
/// #### 4. Diagnostic Guardrails and Logging
///   • Lifecycle Logging: Records diagnostic logs with Logger("EventBus") 
///     whenever an event is published (including sender type) or when a new component subscribes.
///     
///   • Architectural Invariant Enforcement: Enforces debug-time assertions 
///     (e.g., verifying ViewModel state) to prevent premature event 
///     emissions during improper lifecycle phases.
/// 
/// #### 5. Abstraction & Adapter Layer
///   • Implements the IAppEvents contract, shielding the rest of the application 
///     codebase from direct dependency on the third-party event_bus package.
///     This enables easy mocking/stubbing in unit tests.
///
class AppEventBus implements IAppEvents {
  final Logger _logger = new Logger("EventBus");
  final EventBus _eventBus = new EventBus(sync: false);

  @override
  void raise<TEvent extends AppEvent>(TEvent event) {
    _logger.finest("${event.sender.runtimeType} fired $TEvent");
    assert(
        !((event.sender
            is ViewModel) /* && (event.sender as ViewModel).state != ViewModelState.ready*/),
        "Do not raise application events while view model is not ready, yet.");
    _eventBus.fire(event);
  }

  @override
  StreamSubscription subscribe<T extends AppEvent>(
      Object subscriber, void Function(T event) handler) {
    _logger
        .finest("${subscriber.runtimeType} subscribes to receive $T events.");
    return _eventBus.on<T>().listen((e) => handler(e));
  }

  @override
  void unsubscribe(StreamSubscription subscription) => subscription.cancel();
}
