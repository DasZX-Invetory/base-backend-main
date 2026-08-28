import 'dart:convert';

import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/services/tenant_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TenantUserApi extends Api {
  final TenantService _tenantService;
  TenantUserApi(this._tenantService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    Router router = Router();

    // Busca tenant pelo id
    router.get('/api/tenant/search/id', (Request req) async {
      String? tenantId = req.url.queryParameters['id'];
      if (tenantId == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "Insira o ID do tenant",
            "error_code": "MISSING_TENANT_ID",
            "data": null,
          }),
        );
      }

      var tenant = await _tenantService.findOne(tenantId);

      if (tenant == null) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Tenant não encontrado",
            "error_code": "TENANT_NOT_FOUND",
            "data": null,
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Tenant encontrado",
          "data": {"tenant": tenant.toJson()},
        }),
      );
    });

    return createHandler(
      router: router.call,
      isSecurity: isSecurity,
      middlewares: middlewares,
      requiredRole: requiredRole,
    );
  }
}
