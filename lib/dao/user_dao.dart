import 'package:backend_daszx_inventory/dao/dao.dart';
import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/infra/database/postgre_db_configuration.dart';
import 'package:backend_daszx_inventory/models/user_model.dart';
import 'package:postgres/postgres.dart';

class UserDao implements DAO<UserModel, int> {
  final DbConfiguration _dbConfiguration;
  UserDao(this._dbConfiguration);

  // Cria um novo usuário
  @override
  Future<bool> create(UserModel value) async {
    Result result = await _dbConfiguration.execQuery(
      '''INSERT INTO users 
         (tenant_id, name, email, password_hash, avatar_url, birth_date, role, is_active) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        value.tenantId,
        value.name,
        value.email,
        value.password,
        value.avatarUrl,
        value.birthDate?.toUtc(),
        value.role ?? 'technician',
        value.active ?? true,
      ],
    );
    return result.affectedRows > 0;
  }

  // Soft delete - atualiza deleted_at ao invés de deletar
  @override
  Future<bool> delete(int id) async {
    Result result = await _dbConfiguration.execQuery(
      'UPDATE users SET deleted_at = CURRENT_TIMESTAMP, is_active = false WHERE id = ?',
      [id],
    );
    return result.affectedRows > 0;
  }

  // Busca todos os usuários
  @override
  Future<List<UserModel>> findAll() async {
    Result result = await _dbConfiguration.execQuery(
      '''SELECT u.*, t.name as tenant_name 
         FROM users u 
         LEFT JOIN tenants t ON u.tenant_id = t.id''',
    );
    return result.map((r) => UserModel.fromMap(r.fields)).toList();
  }

  // Busca usuário por ID
  @override
  Future<UserModel?> findOne(int id) async {
    Result result = await _dbConfiguration.execQuery(
      '''SELECT u.*, t.name as tenant_name 
         FROM users u 
         LEFT JOIN tenants t ON u.tenant_id = t.id 
         WHERE u.id = ?''',
      [id],
    );
    return result.isEmpty ? null : UserModel.fromMap(result.first.fields);
  }

  // Monta a query dinamicamente para não sobrescrever password_hash com null
  @override
  Future<bool> update(UserModel value) async {
    final fields = <String>[];
    final params = <dynamic>[];

    if (value.tenantId != null) {
      fields.add('tenant_id = ?');
      params.add(value.tenantId);
    }
    if (value.name != null) {
      fields.add('name = ?');
      params.add(value.name);
    }
    if (value.email != null) {
      fields.add('email = ?');
      params.add(value.email);
    }
    if (value.password != null && value.password!.isNotEmpty) {
      fields.add('password_hash = ?');
      params.add(value.password);
    }
    if (value.avatarUrl != null) {
      fields.add('avatar_url = ?');
      params.add(value.avatarUrl);
    }
    if (value.birthDate != null) {
      fields.add('birth_date = ?');
      params.add(value.birthDate!.toUtc());
    }
    if (value.role != null) {
      fields.add('role = ?');
      params.add(value.role);
    }
    if (value.active != null) {
      fields.add('is_active = ?');
      params.add(value.active);
    }

    if (fields.isEmpty) return false;

    params.add(value.id);

    Result result = await _dbConfiguration.execQuery(
      'UPDATE users SET ${fields.join(', ')} WHERE id = ?',
      params,
    );
    return result.affectedRows > 0;
  }

  /// Busca usuário pelo email para login
  Future<UserModel?> findByEmail(String email) async {
    Result result = await _dbConfiguration.execQuery(
      '''SELECT u.id, u.tenant_id, u.name, u.email, u.password_hash, u.avatar_url, u.role, u.is_active, t.name as tenant_name 
         FROM users u 
         LEFT JOIN tenants t ON u.tenant_id = t.id 
         WHERE u.email = ? AND u.deleted_at IS NULL''',
      [email],
    );
    return result.isEmpty ? null : UserModel.fromEmail(result.first.fields);
  }

  /// Atualiza o último login do usuário
  Future<void> updateLastLogin(int userId) async {
    await _dbConfiguration.execQuery(
      'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?',
      [userId],
    );
  }

  /// Reativa um usuário (limpa deleted_at e ativa is_active)
  Future<bool> activate(int id) async {
    Result result = await _dbConfiguration.execQuery(
      'UPDATE users SET deleted_at = NULL, is_active = true WHERE id = ?',
      [id],
    );
    return result.affectedRows > 0;
  }

  /// Verifica se email já existe para o tenant
  Future<bool> emailExists(String email, String tenantId) async {
    Result result = await _dbConfiguration.execQuery(
      '''SELECT COUNT(*) as count FROM users 
         WHERE email = ? AND tenant_id = ? AND deleted_at IS NULL''',
      [email, tenantId],
    );
    if (result.isEmpty) return false;
    final count = result.first.toColumnMap()['count'] as int;
    return count > 0;
  }
}
