import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/core/config/app_env_keys.dart';
import 'package:backend_daszx_inventory/utils/custom_env.dart';
import 'package:dbcrypt/dbcrypt.dart';

class BootstrapService {
  final DbConfiguration _dbConfiguration;

  BootstrapService(this._dbConfiguration);

  Future<void> initDefaultData() async {
    // 1. Verifica se já existe algum owner no banco
    final result = await _dbConfiguration.execQuery(
      'SELECT COUNT(id) FROM users WHERE role = ?',
      ['owner'],
    );

    // Se count for maior que 0, o sistema já foi inicializado. Interrompe a função.
    if ((result.first[0] as int) > 0) return;

    print('[BOOTSTRAP] Banco sem owner detectado. Iniciando bootstrap...');

    final tenantName = await CustomEnv.get<String>(
      key: AppEnvKeys.defaultTenantName,
    );
    final tenantCnpj = await CustomEnv.get<String>(
      key: AppEnvKeys.defaultTenantCnpj,
    );
    final ownerName = await CustomEnv.get<String>(
      key: AppEnvKeys.defaultOwnerName,
    );
    final ownerEmail = await CustomEnv.get<String>(
      key: AppEnvKeys.defaultOwnerEmail,
    );
    final plainPassword = await CustomEnv.get<String>(
      key: AppEnvKeys.defaultOwnerPassword,
    );

    // 2. Criar o Tenant Padrão
    final tenantResult = await _dbConfiguration.execQuery(
      '''INSERT INTO tenants (name, document, email_contact, plan_type)
         VALUES (?, ?, ?, ?)
         RETURNING id''',
      [tenantName, tenantCnpj, ownerEmail, 'enterprise'],
    );

    // Pega o UUID gerado pelo banco para o Tenant
    final tenantId = tenantResult[0][0];

    // 3. Criar o Usuário Owner Padrão
    final hash = DBCrypt().hashpw(plainPassword, DBCrypt().gensalt());

    await _dbConfiguration.execQuery(
      '''INSERT INTO users (tenant_id, name, email, password_hash, role)
         VALUES (?, ?, ?, ?, ?)''',
      [tenantId, ownerName, ownerEmail, hash, 'owner'],
    );

    print('[BOOTSTRAP] Tenant e Owner padrão criados com sucesso.');
  }
}
