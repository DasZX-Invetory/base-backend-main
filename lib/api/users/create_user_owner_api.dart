import 'dart:convert';
import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/models/user_model.dart';
import 'package:backend_daszx_inventory/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class CreateUserOwnerApi extends Api {
  final UserService _userService;
  CreateUserOwnerApi(this._userService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    final router = Router();

    // Cadastra novo usuário
    router.post('/api/user/create', (Request req) async {
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
        var user = UserModel.fromRequest(data);

        // Validações básicas
        if (user.email == null || user.email!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Email é obrigatório",
              "error_code": "MISSING_EMAIL",
              "data": null,
            }),
          );
        }

        if (user.password == null || user.password!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "Senha é obrigatória",
              "error_code": "MISSING_PASSWORD",
              "data": null,
            }),
          );
        }

        if (user.tenantId == null || user.tenantId!.isEmpty) {
          return Response(
            400,
            body: jsonEncode({
              "success": false,
              "message": "tenant_id é obrigatório",
              "error_code": "MISSING_TENANT_ID",
              "data": null,
            }),
          );
        }

        // Verifica se email já existe para o tenant
        if (await _userService.emailExists(user.email!, user.tenantId!)) {
          return Response(
            409,
            body: jsonEncode({
              "success": false,
              "message": "Este email já está cadastrado para esta empresa",
              "error_code": "EMAIL_EXISTS",
              "data": null,
            }),
          );
        }

        var result = await _userService.save(user);

        if (result) {
          return Response(
            201,
            body: jsonEncode({
              "success": true,
              "message": "Usuário criado com sucesso",
              "data": null,
            }),
          );
        } else {
          return Response.internalServerError(
            body: jsonEncode({
              "success": false,
              "message": "Erro ao criar usuário",
              "error_code": "CREATE_USER_ERROR",
              "data": null,
            }),
          );
        }
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({
            "success": false,
            "message": "Erro interno: ${e.toString()}",
            "error_code": "INTERNAL_ERROR",
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
