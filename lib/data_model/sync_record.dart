import 'package:mf4flight/mf4flight.dart';
import 'package:uuid/uuid.dart';


abstract class SyncRecord extends DataModelBase {
  String syncId = Uuid().v4();
  int recordVersion =0;
  bool get syncRequired => recordVersion > DBHelper.lastSyncVersion;
}
