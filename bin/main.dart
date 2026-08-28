import 'package:backend_daszx_inventory/api/tenants/tenant_admin_api.dart';
import 'package:backend_daszx_inventory/api/tenants/tenant_user_api.dart';
import 'package:backend_daszx_inventory/api/tenants/tenant_owner_api.dart';
import 'package:backend_daszx_inventory/api/system/health_api.dart';
import 'package:backend_daszx_inventory/api/users/auth_api.dart';
import 'package:backend_daszx_inventory/api/users/create_user_owner_api.dart';
import 'package:backend_daszx_inventory/api/users/user_owner_api.dart';
import 'package:backend_daszx_inventory/core/config/app_env_keys.dart';
import 'package:backend_daszx_inventory/core/security/app_roles.dart';
import 'package:backend_daszx_inventory/infra/custom_server.dart';
import 'package:backend_daszx_inventory/infra/dependency_injector/injects.dart';
import 'package:backend_daszx_inventory/infra/middleware_intercepton.dart';
import 'package:backend_daszx_inventory/utils/custom_env.dart';
import 'package:shelf/shelf.dart';

void main() async {
  final di = Injects.initialize();

  // Obtem as APIs do container de DI
  var cascade = Cascade()
      .add(di<HealthApi>().getHandler())
      .add(di<AuthApi>().getHandler())
      .add(
        di<CreateUserOwnerApi>().getHandler(
          isSecurity: true,
          requiredRole: AppRoles.owner,
        ),
      )
      .add(
        di<UserOwnerApi>().getHandler(
          isSecurity: true,
          requiredRole: AppRoles.owner,
        ),
      )
      .add(
        di<TenantOwnerApi>().getHandler(
          isSecurity: true,
          requiredRole: AppRoles.owner,
        ),
      )
      .add(
        di<TenantAdminApi>().getHandler(
          isSecurity: true,
          requiredRole: AppRoles.admin,
        ),
      )
      .add(di<TenantUserApi>().getHandler(isSecurity: true))
      .handler;

  // Pipeline de middlewares
  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(MiddlewareInterception.contentTypeJson)
      .addMiddleware(MiddlewareInterception.cors)
      .addHandler(cascade);

  // Le configuracoes do .env com fallback padrao para facilitar bootstrap
  final address = await CustomEnv.getOrDefault<String>(
    key: AppEnvKeys.serverAddress,
    defaultValue: '0.0.0.0',
  );
  final port = await CustomEnv.getOrDefault<int>(
    key: AppEnvKeys.serverPort,
    defaultValue: 8080,
  );

  // Inicia o servidor
  await CustomServer().initialize(
    handler: handler,
    address: address,
    port: port,
  );
}
