import 'dart:async';

import 'app_event.dart';

typedef EventHandler<TEvent> = void Function(TEvent event);

abstract class IAppEvents {
  StreamSubscription subscribe<TEvent extends AppEvent>(
    Object subscriber,
    EventHandler<TEvent> handler,
  );

  void unsubscribe(StreamSubscription subscription);

  void raise<TEvent extends AppEvent>(TEvent event);
}
