import 'package:flutter/material.dart';

import 'database_record.dart';
import '../database_helper.dart';

abstract class SyncRecord extends DatabaseRecord {
  late final String syncId;
  int recordVersion =0;
  bool get syncRequired => recordVersion > DBHelper.lastSyncVersion;

  @protected
  @mustCallSuper
  SyncRecord() : super() {
    //syncId = DBHelper.newGuid();
  }

  @protected
  @mustCallSuper
  void load (Map<String, dynamic> json)  {
    assert(json['SyncId']!=null);
    syncId = json['SyncId'];
    recordVersion = json['RecordVersion'];
    super.load(json);
  }
  
  
  // Convert a databaseRecord object into a Map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['SyncId'] = syncId;
    data['RecordVersion'] = recordVersion;
    return data;
  }
}
