import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final GetIt serviceProvider = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

NavigatorState get navigator => navigatorKey.currentState as NavigatorState;
ScaffoldMessengerState get messenger => scaffoldMessengerKey.currentState as ScaffoldMessengerState;
