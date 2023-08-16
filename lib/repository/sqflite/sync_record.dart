import 'package:uuid/uuid.dart';

import 'db_util.dart';
import 'db_record_base.dart';


abstract class SyncRecord extends RecordBase {
  String syncId = Uuid().v4();
  int recordVersion =0;
  bool get syncRequired => recordVersion > DBUtil.lastSyncVersion;
}
