
/// Provides functionality to migrate a data store 
/// from one version to a newer version.
abstract class IStoreMigration {
  Future<void> executeAsync( int oldVersion, int newVersion);
}