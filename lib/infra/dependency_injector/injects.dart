import 'package:backend_daszx_inventory/api/tenants/tenant_admin_api.dart';
import 'package:backend_daszx_inventory/api/tenants/tenant_user_api.dart';
import 'package:backend_daszx_inventory/api/tenants/tenant_owner_api.dart';
import 'package:backend_daszx_inventory/api/system/health_api.dart';
import 'package:backend_daszx_inventory/api/users/auth_api.dart';
import 'package:backend_daszx_inventory/api/users/create_user_owner_api.dart';
import 'package:backend_daszx_inventory/api/users/user_owner_api.dart';
import 'package:backend_daszx_inventory/dao/tenant_dao.dart';
import 'package:backend_daszx_inventory/dao/user_dao.dart';
import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/infra/database/postgre_db_configuration.dart';
import 'package:backend_daszx_inventory/infra/dependency_injector/dependency_injector.dart';
import 'package:backend_daszx_inventory/infra/security/security_service.dart';
import 'package:backend_daszx_inventory/infra/security/security_service_imp.dart';
import 'package:backend_daszx_inventory/services/login_service.dart';
import 'package:backend_daszx_inventory/services/tenant_service.dart';
import 'package:backend_daszx_inventory/services/user_service.dart';

class Injects {
  static DependencyInjector initialize() {
    final di = DependencyInjector();

    // Healthcheck
    di.register<HealthApi>(() => HealthApi());

    // BANCO DE DADOS (PostgreSQL)
    di.register<DbConfiguration>(() => PostgreDbConfiguration());

    // SEGURANÇA
    di.register<SecurityService>(() => SecurityServiceImpl());

    // USUÁRIOS (DAO → Service → API)
    di.register<UserDao>(() => UserDao(di<DbConfiguration>()));
    di.register<UserService>(() => UserService(di<UserDao>()));
    di.register<CreateUserOwnerApi>(
      () => CreateUserOwnerApi(di<UserService>()),
    );
    di.register<UserOwnerApi>(() => UserOwnerApi(di<UserService>()));

    // LOGIN (usa UserService + SecurityService)
    di.register<LoginService>(() => LoginService(di<UserService>()));
    di.register<AuthApi>(
      () =>
          AuthApi(di<SecurityService>(), di<LoginService>(), di<UserService>()),
    );

    // Tenants (DAO → Service → API)
    di.register<TenantDao>(() => TenantDao(di<DbConfiguration>()));
    di.register<TenantService>(() => TenantService(di<TenantDao>()));
    di.register<TenantOwnerApi>(() => TenantOwnerApi(di<TenantService>()));
    di.register<TenantUserApi>(() => TenantUserApi(di<TenantService>()));
    di.register<TenantAdminApi>(() => TenantAdminApi(di<TenantService>()));

    return di;
  }
}
