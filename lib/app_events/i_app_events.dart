import 'dart:async';

import 'app_event.dart';

abstract class IAppEvents {
  StreamSubscription subscribe<T extends AppEvent>(Object subscriber, void Function(T event) handler);
  void unsubscribe(StreamSubscription subscription);
  void raise<TEvent extends AppEvent>(TEvent event);
}
