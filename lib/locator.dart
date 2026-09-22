import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app_events/app_event_bus.dart';
import 'app_events/i_app_events.dart';

final GetIt serviceProvider = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

NavigatorState get navigator {
  final state = navigatorKey.currentState;
  if (state == null) {
    throw StateError(
        "Navigator is not available. Ensure navigatorKey is assigned to MaterialApp.");
  }
  return state;
}

ScaffoldMessengerState get messenger {
  final state = scaffoldMessengerKey.currentState;
  if (state == null) {
    throw StateError(
      "ScaffoldMessenger is not available. Ensure scaffoldMessengerKey is assigned to MaterialApp.",
    );
  }
  return state;
}

IAppEvents appEvents = new AppEventBus();
