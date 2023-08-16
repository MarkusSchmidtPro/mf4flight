import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app_events/app_event_bus.dart';
import 'app_events/i_app_events.dart';

final GetIt serviceProvider = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

NavigatorState get navigator => navigatorKey.currentState as NavigatorState;
ScaffoldMessengerState get messenger => scaffoldMessengerKey.currentState as ScaffoldMessengerState;

IAppEvents appEvents = new AppEventBus();