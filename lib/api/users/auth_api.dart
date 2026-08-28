import 'dart:convert';
import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/infra/security/security_service.dart';
import 'package:backend_daszx_inventory/services/login_service.dart';
import 'package:backend_daszx_inventory/services/user_service.dart';
import 'package:backend_daszx_inventory/to/auth_to.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthApi extends Api {
  final SecurityService _securityService;
  final LoginService _loginService;
  final UserService _userService;

  AuthApi(this._securityService, this._loginService, this._userService);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    Router router = Router();

    // Login do usuário
    router.post('/api/auth/login', (Request req) async {
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

      var authTO = AuthTo.fromRequest(body);
      var user = await _loginService.authenticate(authTO);

      // Primeiro verifica se o usuário existe
      if (user == null) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Credenciais inválidas",
            "error_code": "INVALID_CREDENTIALS",
            "data": null,
          }),
        );
      }

      // Verifica o status da conta
      if (user.active == false) {
        return Response.forbidden(
          jsonEncode({
            "success": false,
            "message":
                "Sua conta está inativa. Entre em contato com o administrador.",
            "error_code": "USER_INACTIVE",
            "data": null,
          }),
        );
      }

      // Atualiza o último login
      await _userService.updateLastLogin(user.id!);

      var accessToken = await _securityService.generateAccessToken(
        user.id.toString(),
        user.role ?? 'technician',
        (user.active == true) ? 1 : 2,
      );
      var refreshToken = await _securityService.generateRefreshToken(
        user.id.toString(),
      );

      // Resposta seguindo o padrão da documentação
      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Login realizado com sucesso",
          "data": {
            "access_token": accessToken,
            "refresh_token": refreshToken,
            "expires_in": 900,
            "user": user.toLoginResponse(),
          },
        }),
      );
    });

    // Logout do usuário
    router.post('/api/auth/logout', (Request req) {
      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Logout realizado com sucesso",
          "data": null,
        }),
      );
    });

    // Refresh token
    router.post('/api/auth/refresh', (Request req) async {
      var body = await req.readAsString();
      var map = jsonDecode(body);
      var refreshToken = map['refresh_token'];

      if (refreshToken == null) {
        return Response(
          400,
          body: jsonEncode({
            "success": false,
            "message": "refresh_token é obrigatório",
            "error_code": "MISSING_REFRESH_TOKEN",
            "data": null,
          }),
        );
      }

      var decodedJwt = await _securityService.validateJWT(refreshToken);
      if (decodedJwt == null) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Token inválido ou expirado",
            "error_code": "INVALID_TOKEN",
            "data": null,
          }),
        );
      }

      var userId = decodedJwt.payload['userID'];
      var user = await _userService.findOne(int.parse(userId));

      if (user == null) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Usuário não encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      if (user.active == false) {
        return Response.forbidden(
          jsonEncode({
            "success": false,
            "message": "Sua conta está inativa.",
            "error_code": "USER_INACTIVE",
            "data": null,
          }),
        );
      }

      var newAccessToken = await _securityService.generateAccessToken(
        user.id.toString(),
        user.role ?? 'technician',
        (user.active!) ? 1 : 2,
      );

      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Token atualizado com sucesso",
          "data": {"access_token": newAccessToken, "expires_in": 900},
        }),
      );
    });

    // Verificar se o access token é válido
    router.get('/api/auth/verify', (Request req) async {
      String? authHeader = req.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Token não fornecido",
            "error_code": "MISSING_TOKEN",
            "data": null,
          }),
        );
      }

      String token = authHeader.substring(7);
      var decodedJwt = await _securityService.validateJWT(token);

      if (decodedJwt == null) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Token inválido ou expirado",
            "error_code": "INVALID_TOKEN",
            "data": null,
          }),
        );
      }

      var payload = decodedJwt.payload;
      var userId = payload['userID'];
      var user = await _userService.findOne(int.parse(userId));

      if (user == null) {
        return Response(
          401,
          body: jsonEncode({
            "success": false,
            "message": "Usuário não encontrado",
            "error_code": "USER_NOT_FOUND",
            "data": null,
          }),
        );
      }

      if (user.active == false) {
        return Response.forbidden(
          jsonEncode({
            "success": false,
            "message": "Sua conta está inativa.",
            "error_code": "USER_INACTIVE",
            "data": null,
          }),
        );
      }

      return Response.ok(
        jsonEncode({
          "success": true,
          "message": "Token válido",
          "data": {
            "user_id": userId,
            "role": payload['role'],
            "active": true,
            "issued_at": payload['iat'],
            "expires_at": payload['exp'],
          },
        }),
      );
    });

    return createHandler(router: router.call, middlewares: middlewares);
  }
}
