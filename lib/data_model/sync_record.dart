import 'package:mf4flight/mf4flight.dart';


abstract class SyncRecord extends DataModelBase {
  late final String syncId;
  int recordVersion =0;
  bool get syncRequired => recordVersion > DBHelper.lastSyncVersion;
}
