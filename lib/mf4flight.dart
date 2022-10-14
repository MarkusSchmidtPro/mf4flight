library mf4flight;

import 'package:flutter/material.dart';

import 'app_events/app_event_bus.dart';
import 'app_events/i_app_events.dart';

export "sqflite/migration_set.dart";
export "sqflite/sqlite_store2.dart";
export 'app_events/app_event.dart';
export 'app_events/app_event_bus.dart';
export 'app_events/i_app_events.dart';
export 'command/i_command.dart';
export 'command/inactive_command.dart';
export 'command/relay_command.dart';
export 'command/relay_p_command.dart';
export 'data_model/data_model_base.dart';
export 'data_model/database_helper.dart';
export 'data_model/i_data_provider2.dart';
export 'data_model/sync_record.dart';
export 'data_provider/list_provider.dart';
export 'data_provider/sqlite_provider2.dart';
export 'enums.dart';
export 'event_handler.dart';
export 'locator.dart';
export 'model/model_adapter.dart';
export 'model/model_base2.dart';
export 'view/dialog2.dart';
export 'view/view_errors.dart';
export 'view_model/list_vm_mixin.dart';
export 'view_model/viewmodel_all.dart';
export 'view_model/viewmodel_base.dart';
export 'view_model/viewmodel_edit.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

ScaffoldMessengerState get messenger => scaffoldMessengerKey.currentState as ScaffoldMessengerState;

NavigatorState get navigator => navigatorKey.currentState as NavigatorState;

IAppEvents appEvents = new AppEventBus();
