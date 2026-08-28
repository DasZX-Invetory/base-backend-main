import 'package:backend_daszx_inventory/dao/dao.dart';
import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/infra/database/postgre_db_configuration.dart';
import 'package:backend_daszx_inventory/models/tenant_model.dart';
import 'package:postgres/postgres.dart';

class TenantDao implements DAO<TenantModel, String> {
  final DbConfiguration _dbConfiguration;
  TenantDao(this._dbConfiguration);

  // Cria um novo tenant
  @override
  Future<bool> create(TenantModel value) async {
    Result result = await _dbConfiguration.execQuery(
      '''INSERT INTO tenants (name, document, email_contact, plan_type, is_active) VALUES (?, ?, ?, ?, ?)''',
      [
        value.name,
        value.document,
        value.emailContact,
        value.planType,
        value.active ?? true,
      ],
    );
    return result.affectedRows > 0;
  }

  // Soft delete - atualiza deleted_at ao invés de deletar
  @override
  Future<bool> delete(String id) async {
    Result result = await _dbConfiguration.execQuery(
      'UPDATE tenants SET deleted_at = CURRENT_TIMESTAMP, is_active = false WHERE id = ?',
      [id],
    );
    return result.affectedRows > 0;
  }

  // Reativa o tenant - atualiza deleted_at para NULL e is_active para true
  Future<bool> activate(String id) async {
    Result result = await _dbConfiguration.execQuery(
      'UPDATE tenants SET deleted_at = NULL, is_active = true WHERE id = ?',
      [id],
    );
    return result.affectedRows > 0;
  }

  // Busca todos os tenants
  @override
  Future<List<TenantModel>> findAll() async {
    Result result = await _dbConfiguration.execQuery('SELECT * FROM tenants');
    return result.map((r) => TenantModel.fromMap(r.fields)).toList();
  }

  // Busca tenant por ID
  @override
  Future<TenantModel?> findOne(String id) async {
    Result result = await _dbConfiguration.execQuery(
      'SELECT * FROM tenants WHERE id = ?',
      [id],
    );
    return result.isEmpty ? null : TenantModel.fromMap(result.first.fields);
  }

  // Monta a query dinamicamente para não sobrescrever campos com null
  @override
  Future<bool> update(TenantModel value) async {
    final fields = <String>[];
    final params = <dynamic>[];

    if (value.name != null) {
      fields.add('name = ?');
      params.add(value.name);
    }
    if (value.document != null) {
      fields.add('document = ?');
      params.add(value.document);
    }
    if (value.emailContact != null) {
      fields.add('email_contact = ?');
      params.add(value.emailContact);
    }
    if (value.planType != null) {
      fields.add('plan_type = ?');
      params.add(value.planType);
    }
    if (value.active != null) {
      fields.add('is_active = ?');
      params.add(value.active);
    }

    if (fields.isEmpty) return false;
    fields.add('updated_at = CURRENT_TIMESTAMP');
    params.add(value.id);

    Result result = await _dbConfiguration.execQuery(
      'UPDATE tenants SET ${fields.join(', ')} WHERE id = ?',
      params,
    );
    return result.affectedRows > 0;
  }
}
