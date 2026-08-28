abstract class DbConfiguration {
  Future<dynamic> createConnection();
  Future<dynamic> get connection;
  Future<dynamic> execQuery(String sql, [List<dynamic>? params]);
}
