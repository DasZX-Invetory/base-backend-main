import 'dart:convert';

import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/models/tenant_model.dart';
import 'package:backend_daszx_inventory/services/tenant_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TenantAdminApi extends Api {
  final TenantService _tenantService;
  TenantAdminApi(this._tenantService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    Router router = Router();

    // Atualiza um tenant
    router.put('/api/tenant/update', (Request req) async {
      var body = await req.readAsString();
      if (body.isEmpty) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "Body vazio",
            "error_code": "EMPTY_BODY",
            "data": null,
          }),
        );
      }
      var tenant = TenantModel.fromRequest(jsonDecode(body));
      if (tenant.id == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "ID do tenant é obrigatório para atualização",
            "error_code": "MISSING_TENANT_ID",
            "data": null,
          }),
        );
      }
      var result = await _tenantService.save(tenant);
      return result
          ? Response.ok(
              jsonEncode({
                "success": true,
                "message": "Tenant atualizado com sucesso",
                "data": null,
              }),
            )
          : Response.internalServerError(
              body: jsonEncode({
                "success": false,
                "message": "Falha ao atualizar tenant",
                "error_code": "UPDATE_TENANT_ERROR",
                "data": null,
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
