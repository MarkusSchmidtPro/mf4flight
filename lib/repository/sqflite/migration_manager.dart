import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';

import 'migration_set.dart';


/// Provides functionality to run a SQLite database migration (version upgrade).
class MigrationManager {
  final Logger _log = new Logger('DBMigration');

  MigrationManager(Database sqLiteDB, Iterable<MigrationStep> migrationSets)
      : _sqLiteDB = sqLiteDB,_migrationSets = migrationSets.toList();

  final Database _sqLiteDB;
  late final List<MigrationStep> _migrationSets;

  /// Upgrade a SQLite database by running all provided [MigrationStep]s.
  Future<void> upgradeDatabaseAsync(int oldVersion, int newVersion) async {
    _log.info('Upgrading DB from v$oldVersion to v$newVersion');
    int currentVersion = oldVersion;

    _migrationSets.sort( (a,b) => a.targetVersion.compareTo(b.targetVersion));
    for( var migrationSet in _migrationSets.where((s) => s.targetVersion>currentVersion)) {
      if (currentVersion >= newVersion) break;
        
        try {
          await _sqLiteDB.transaction((txn) async {
            _runAllScripts(txn, migrationSet.updateSchemaScript);
            _runAllScripts(txn, migrationSet.migrateDataScript);
            _runAllScripts(txn, migrationSet.commitScript);
          });
        } catch (e) {
          _log.severe(e);
          rethrow; // w/o failure the DB gets the new DB version
        }

        currentVersion = migrationSet.targetVersion;
    }
    
    _log.info('Upgrading DB finished.');
  }

  
  void _runAllScripts( Transaction txn, String? sqlScripts){
    if( sqlScripts == null ) return;
    for (var sqlStatement in sqlScripts.split("-- ###")) {
      //_log.finer(':' + sqlStatement);
      txn.execute(sqlStatement);
    }
  }
  
/*
  Future _createStandardTable(Database _sqLiteDB, String tableName, String payloadSql) async {
    await _sqLiteDB.execute("""
        create table $tableName
        (
            id                   TEXT(40)           not null
                constraint PK_$tableName primary key,
            $payloadSql ,
            Name                 TEXT(100)         not null,
            EMail                TEXT(100),
            RecordVersion        int     default 0 not null,
            RecordState          INTEGER default 0 not null,
            RecordLastUpdateUtc  DATETIME          not null,
            RecordCreatedDateUtc DATETIME          not null
        );
        """);
        create unique index Contact_EMail
            on Contact(EMail);
  }
 */
}
