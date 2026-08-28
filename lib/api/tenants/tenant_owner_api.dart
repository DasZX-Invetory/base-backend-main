import 'dart:convert';

import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/models/tenant_model.dart';
import 'package:backend_daszx_inventory/services/tenant_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class TenantOwnerApi extends Api {
  final TenantService _tenantService;
  TenantOwnerApi(this._tenantService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    Router router = Router();
    // Busca todos os tenants para o Owner
    router.get('/api/tenant/search', (Request req) async {
      var tenants = await _tenantService.findAll();
      var tenantMap = tenants.map((e) => e.toJson()).toList();

      if (tenants.isEmpty) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Nenhum tenant encontrado",
            "error_code": "TENANT_NOT_FOUND",
            "data": null,
          }),
        );
      }
      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Tenants encontrados",
          "data": {"tenants": tenantMap},
        }),
      );
    });

    // Cadastra novo tenant
    router.post('/api/tenant/create', (Request req) async {
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

      try {
        var data = jsonDecode(body);
        var tenant = TenantModel.fromRequest(data);

        if (tenant.name == null || tenant.name!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Nome do tenant é obrigatório",
              "error_code": "MISSING_TENANT_NAME",
              "data": null,
            }),
          );
        }
        if (tenant.document == null || tenant.document!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Documento do tenant é obrigatório",
              "error_code": "MISSING_TENANT_DOCUMENT",
              "data": null,
            }),
          );
        }
        if (tenant.emailContact == null || tenant.emailContact!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Email de contato do tenant é obrigatório",
              "error_code": "MISSING_TENANT_EMAIL_CONTACT",
              "data": null,
            }),
          );
        }
        if (tenant.planType == null || tenant.planType!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Plano do tenant é obrigatório",
              "error_code": "MISSING_TENANT_PLAN_TYPE",
              "data": null,
            }),
          );
        }

        var result = await _tenantService.save(tenant);

        if (result) {
          return Response(
            201,
            body: jsonEncode({
              "success": true,
              "message": "Tenant criado com sucesso",
              "data": null,
            }),
          );
        } else {
          return Response.internalServerError(
            body: jsonEncode({
              "success": false,
              "message": "Erro ao criar tenant",
              "error_code": "TENANT_CREATION_FAILED",
              "data": null,
            }),
          );
        }
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({
            "success": false,
            "message": "Erro ao processar requisição: ${e.toString()}",
            "error_code": "REQUEST_PROCESSING_ERROR",
            "data": null,
          }),
        );
      }
    });

    // Soft delete - desativa o tenant (não remove do banco)
    router.delete('/api/tenant/delete', (Request req) async {
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

      var result = await _tenantService.delete(tenantId);

      if (result) {
        return Response.ok(
          jsonEncode({
            "success": true,
            "message": "Tenant deletado com sucesso",
            "data": null,
          }),
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            "success": false,
            "message": "Erro ao deletar tenant",
            "error_code": "DELETE_TENANT_ERROR",
            "data": null,
          }),
        );
      }
    });

    router.put('/api/tenant/update', (Request req) async {
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
      var result = await _tenantService.activate(tenantId);
      if (result) {
        return Response.ok(
          jsonEncode({
            "success": true,
            "message": "Tenant reativado com sucesso",
            "data": null,
          }),
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            "success": false,
            "message": "Erro ao reativar tenant",
            "error_code": "REACTIVATE_TENANT_ERROR",
            "data": null,
          }),
        );
      }
    });

    return createHandler(
      router: router.call,
      isSecurity: isSecurity,
      middlewares: middlewares,
      requiredRole: requiredRole,
    );
  }
}
