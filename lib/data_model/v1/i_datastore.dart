abstract class IDataStore{
  Future<void> openAsync();
  Future<String> saveToFile(String filename);
  void close();
}