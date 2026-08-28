abstract class DAO<T, ID> {
  Future<bool> create(T value);
  Future<T?> findOne(ID id);
  Future<List<T>> findAll();
  Future<bool> update(T value);
  Future<bool> delete(ID id);
}
