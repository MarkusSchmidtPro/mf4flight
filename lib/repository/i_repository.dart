abstract class IRepository<TModel> {
  Future<void> save(TModel m);
  Future<TModel?> find(String grid);
}