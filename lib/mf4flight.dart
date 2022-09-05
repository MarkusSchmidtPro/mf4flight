library mf4flight;

import 'package:flutter/material.dart';

import 'app_events/app_event_bus.dart';
import 'app_events/i_app_events.dart';

export 'app_events/app_event.dart';
export 'app_events/app_event_bus.dart';
export 'app_events/i_app_events.dart';
export 'command/i_command.dart';
export 'command/inactive_command.dart';
export 'command/relay_command.dart';
export 'command/relay_p_command.dart';
export 'datastore/database_helper.dart';
export 'datastore/database_record.dart';
export 'datastore/i_data_provider.dart';
export 'datastore/i_datastore.dart';
export 'datastore/i_datastore_migration.dart';
export 'datastore/i_json_object.dart';
export 'datastore/sync_record.dart';
export 'enums.dart';
export 'event_handler.dart';
export 'model/model_adapter.dart';
export 'model/model_adapter_mixin.dart';
export 'model/model_base.dart';
export 'view/dialog2.dart';
export 'view/view_errors.dart';
export 'view_model/viewmodel_all.dart';
export 'view_model/viewmodel_base.dart';
export 'view_model/viewmodel_edit.dart';
export 'view_model/list_vm_mixin.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

ScaffoldMessengerState get messenger => scaffoldMessengerKey.currentState as ScaffoldMessengerState;

NavigatorState get navigator => navigatorKey.currentState as NavigatorState;

IAppEvents appEvents = new AppEventBus();
