import 'dart:convert';

import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/models/user_model.dart';
import 'package:backend_daszx_inventory/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserOwnerApi extends Api {
  final UserService _userService;
  UserOwnerApi(this._userService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    Router router = Router();

    // Busca todos os usuários para o Owner
    router.get('/api/user/search', (Request req) async {
      var users = await _userService.findAll();
      var userMap = users.map((e) => e.toJson()).toList();

      if (users.isEmpty) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Nenhum usuário encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Usuários encontrados",
          "data": {"users": userMap},
        }),
      );
    });

    // Busca um usuário pelo id
    router.get('/api/user/search/id', (Request req) async {
      String? userId = req.url.queryParameters['id'];
      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "Insira o ID do usuário",
            "error_code": "MISSING_USER_ID",
            "data": null,
          }),
        );
      }
      var user = await _userService.findOne(int.parse(userId));

      if (user == null) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Usuário não encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Usuário encontrado",
          "data": {"user": user.toMap()},
        }),
      );
    });

    // Atualiza o usuário
    router.put('/api/user/update', (Request req) async {
      var body = await req.readAsString();
      if (body.isEmpty) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "body vazio",
            "error_code": "EMPTY_BODY",
            "data": null,
          }),
        );
      }

      var user = UserModel.fromRequest(jsonDecode(body));

      if (user.id == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "O campo 'id' é obrigatório para atualização",
            "error_code": "MISSING_USER_ID",
            "data": null,
          }),
        );
      }

      var result = await _userService.save(user);
      return result
          ? Response.ok(
              jsonEncode({
                "success": true,
                "message": "Usuário atualizado com sucesso",
                "data": null,
              }),
            )
          : Response.internalServerError(
              body: jsonEncode({
                "success": false,
                "message": "Erro ao atualizar usuário",
                "error_code": "UPDATE_USER_ERROR",
                "data": null,
              }),
            );
    });

    // Soft delete - desativa o usuário (não remove do banco)
    router.delete('/api/user/delete', (Request req) async {
      String? userId = req.url.queryParameters['id'];

      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "O parâmetro 'id' é obrigatório",
            "error_code": "MISSING_USER_ID",
            "data": null,
          }),
        );
      }

      // Converte e valida o id
      int? id = int.tryParse(userId);
      if (id == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "O 'id' precisa ser um número válido",
            "error_code": "INVALID_USER_ID",
            "data": null,
          }),
        );
      }

      // Verifica se o usuário existe antes de tentar deletar
      var user = await _userService.findOne(id);
      if (user == null) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Usuário não encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      var result = await _userService.delete(id);
      return result
          ? Response.ok(
              jsonEncode({
                "success": true,
                "message": "Usuário desativado com sucesso",
                "data": null,
              }),
            )
          : Response.internalServerError(
              body: jsonEncode({
                "success": false,
                "message": "Erro ao desativar usuário",
                "error_code": "DEACTIVATE_USER_ERROR",
                "data": null,
              }),
            );
    });

    // Reativar usuário desativado
    router.put('/api/user/activate', (Request req) async {
      String? userId = req.url.queryParameters['id'];

      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "O parâmetro 'id' é obrigatório",
            "error_code": "MISSING_USER_ID",
            "data": null,
          }),
        );
      }

      int? id = int.tryParse(userId);
      if (id == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "O 'id' precisa ser um número válido",
            "error_code": "INVALID_USER_ID",
            "data": null,
          }),
        );
      }

      var user = await _userService.findOne(id);
      if (user == null) {
        return Response(
          404,
          body: jsonEncode({
            "success": false,
            "message": "Usuário não encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      if (user.active == true) {
        return Response(
          409,
          body: jsonEncode({
            "success": false,
            "message": "Usuário já está ativo",
            "error_code": "USER_ALREADY_ACTIVE",
            "data": null,
          }),
        );
      }

      var result = await _userService.activate(id);
      return result
          ? Response.ok(
              jsonEncode({
                "success": true,
                "message": "Usuário ativado com sucesso",
                "data": null,
              }),
            )
          : Response.internalServerError(
              body: jsonEncode({
                "success": false,
                "message": "Erro ao ativar usuário",
                "error_code": "ACTIVATE_USER_ERROR",
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
