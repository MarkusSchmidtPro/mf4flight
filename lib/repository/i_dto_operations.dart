/// Provides CRUD operations on a data store.
abstract class IDTOOperations<TDTO> {
  String get entityName => throw UnimplementedError();

  Future<List<TDTO>> fetchAsync({String? criteria});

  Future<TDTO> getAsync(String id);

  Future<String> saveAsync(TDTO dto);

  Future deleteSoftAsync(TDTO dto);
}
