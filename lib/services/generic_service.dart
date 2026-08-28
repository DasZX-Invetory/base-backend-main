abstract class GenericService<T, ID> {
  Future<T?> findOne(ID id);
  Future<List<T>> findAll();
  Future<bool> save(T value);
  Future<bool> delete(ID id);
}
