
/// Represent a database migration step to a [targetVersion].
/// It can contain up three SQLite script to perform the migration.
/// 1. [updateSchemaScript] - Rename (save) existing tables, 
/// 1create new tables instead.
/// 2. [migrateDataScript]  - Migrate existing data from 
/// the existing (old) tables to the new tables
/// 3. [commitScript] - Commit all updates to the database, 
/// and drop tables if necessary.
/// All three actions are executed in a DB transaction.
class MigrationStep {
  /// Get the version of the database after the scripts have run.
  final int targetVersion;

  final String? updateSchemaScript;
  final String? migrateDataScript;
  final String? commitScript;

  MigrationStep(this.targetVersion,
      [this.updateSchemaScript, this.migrateDataScript, this.commitScript]);
}
