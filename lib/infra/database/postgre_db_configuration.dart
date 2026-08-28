import 'package:backend_daszx_inventory/core/config/app_env_keys.dart';
import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/utils/custom_env.dart';
import 'package:postgres/postgres.dart';

class PostgreDbConfiguration implements DbConfiguration {
  Connection? _connection;

  @override
  Future<dynamic> get connection async {
    // Verifica se conexão existe e está aberta
    if (_connection == null || !_connection!.isOpen) {
      _connection = await createConnection();
    }
    return _connection!;
  }

  @override
  Future<Connection> createConnection() async {
    final host = await CustomEnv.get<String>(key: AppEnvKeys.dbHost);
    final port = await CustomEnv.get<int>(key: AppEnvKeys.dbPort);
    final user = await CustomEnv.get<String>(key: AppEnvKeys.dbUser);
    final password = await CustomEnv.get<String>(key: AppEnvKeys.dbPassword);
    final database = await CustomEnv.get<String>(key: AppEnvKeys.dbSchema);

    final endpoint = Endpoint(
      host: host,
      port: port,
      database: database,
      username: user,
      password: password,
    );

    try {
      return await Connection.open(
        endpoint,
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
    } catch (e) {
      throw Exception('[ERRO/DB] -> Falha ao conectar PostgreSQL: $e');
    }
  }

  @override
  Future<Result> execQuery(String sql, [List<dynamic>? params]) async {
    final conn = await connection as Connection;

    if (params == null || params.isEmpty) {
      return await conn.execute(sql);
    }

    // Converter placeholders ? para @p1, @p2, etc. (PostgreSQL named parameters)
    final pgSql = _convertPlaceholders(sql);
    final namedParams = _buildNamedParams(params);

    return await conn.execute(Sql.named(pgSql), parameters: namedParams);
  }

  /// Converte placeholders ? para @p1, @p2, etc.
  String _convertPlaceholders(String sql) {
    int index = 0;
    return sql.replaceAllMapped(RegExp(r'\?'), (match) {
      index++;
      return '@p$index';
    });
  }

  /// Constrói map de parâmetros nomeados
  Map<String, dynamic> _buildNamedParams(List<dynamic> params) {
    final Map<String, dynamic> namedParams = {};
    for (int i = 0; i < params.length; i++) {
      namedParams['p${i + 1}'] = params[i];
    }
    return namedParams;
  }

  /// Fecha a conexão
  Future<void> close() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
    }
  }
}

/// Extensão para acessar os campos como Map
extension PostgresRowExtension on ResultRow {
  Map<String, dynamic> get fields {
    final map = <String, dynamic>{};
    for (var i = 0; i < schema.columns.length; i++) {
      final colName = schema.columns[i].columnName;
      map[colName ?? 'col_$i'] = this[i];
    }
    return map;
  }
}
