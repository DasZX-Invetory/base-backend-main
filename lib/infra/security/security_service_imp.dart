import 'dart:convert';

import 'package:backend_daszx_inventory/core/config/app_env_keys.dart';
import 'package:backend_daszx_inventory/core/security/app_roles.dart';
import 'package:backend_daszx_inventory/infra/security/security_service.dart';
import 'package:backend_daszx_inventory/utils/custom_env.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

class SecurityServiceImpl implements SecurityService<JWT> {
  int _getRoleLevel(String role) {
    switch (role.toLowerCase()) {
      case AppRoles.owner:
        return 1;
      case AppRoles.admin:
        return 2;
      case AppRoles.technician:
        return 3;
      case AppRoles.user:
        return 4;
      default:
        return 99;
    }
  }

  @override
  // GERAR TOKEN DE ACESSO
  Future<String> generateAccessToken(
    String userID,
    String role,
    int active,
  ) async {
    // Cria o payload do token
    var jwt = JWT({
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch ~/
          1000,
      'userID': userID,
      'role': role,
      'active': active,
    });

    // Obtém a chave secreta do .env
    String key = await CustomEnv.get(key: AppEnvKeys.jwtKey);
    return jwt.sign(SecretKey(key));
  }

  // GERAR TOKEN DE REFRESH
  @override
  Future<String> generateRefreshToken(String userID) async {
    var jwt = JWT({
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
      'userID': userID,
    });

    String key = await CustomEnv.get(key: AppEnvKeys.jwtKey);
    return jwt.sign(SecretKey(key));
  }

  // VALIDAR TOKEN
  @override
  Future<JWT?> validateJWT(String token) async {
    String key = await CustomEnv.get(key: AppEnvKeys.jwtKey);

    try {
      return JWT.verify(token, SecretKey(key));
    } on JWTInvalidException {
      return null;
    } on JWTExpiredException {
      return null;
    } on JWTNotActiveException {
      return null;
    } on JWTUndefinedException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // MIDDLEWARE: EXTRAIR JWT DO HEADER
  @override
  Middleware get authorization {
    return (Handler handler) {
      return (Request req) async {
        String? authHeader = req.headers['Authorization'];
        JWT? jwt;

        if (authHeader != null && authHeader.startsWith('Bearer ')) {
          String token = authHeader.substring(7);
          jwt = await validateJWT(token);
        }

        // Adiciona o JWT ao contexto da requisição
        var request = req.change(context: {'jwt': jwt});
        return handler(request);
      };
    };
  }

  // MIDDLEWARE: VERIFICAR SE TEM JWT
  @override
  Middleware get verifyJwt => createMiddleware(
    requestHandler: (Request req) {
      if (req.context['jwt'] == null) {
        return Response.forbidden(
          jsonEncode({
            "success": false,
            "message": "Token inválido ou expirado",
            "error_code": "INVALID_TOKEN",
            "data": null,
          }),
        );
      }
      return null; // Continua para o próximo handler
    },
  );

  // MIDDLEWARE: VERIFICAR ROLE
  @override
  Middleware requireRole(String requiredRole) {
    return createMiddleware(
      requestHandler: (Request req) {
        JWT? jwt = req.context['jwt'] as JWT?;

        if (jwt == null) {
          return Response.forbidden(
            jsonEncode({
              "success": false,
              "message": "Não autorizado - token ausente ou inválido",
              "error_code": "INVALID_TOKEN",
              "data": null,
            }),
          );
        }

        String? userRoleString = jwt.payload['role'] as String?;

        int userLevel = _getRoleLevel(userRoleString ?? '');
        int requiredLevel = _getRoleLevel(requiredRole);

        if (userLevel > requiredLevel) {
          return Response.forbidden(
            jsonEncode({
              "success": false,
              "message": "Acesso negado - permissão insuficiente",
              "error_code": "INSUFFICIENT_PERMISSION",
              "data": null,
            }),
          );
        }

        return null;
      },
    );
  }

  @override
  Middleware get verifyStatus => createMiddleware(
    requestHandler: (Request req) {
      JWT? jwt = req.context['jwt'] as JWT?;

      if (jwt == null) {
        return Response.forbidden(
          jsonEncode({
            "success": false,
            "message": "Não autorizado - token ausente ou inválido",
            "error_code": "INVALID_TOKEN",
            "data": null,
          }),
        );
      }

      int? active = jwt.payload['active'] as int?;

      switch (active) {
        case 1:
          return null;
        case 2:
          return Response.forbidden(
            jsonEncode({
              "success": false,
              "message": "Sua conta está inativa.",
              "error_code": "USER_INACTIVE",
              "data": null,
            }),
          );
        default:
          return Response.forbidden(
            jsonEncode({
              "success": false,
              "message": "Status de conta desconhecido.",
              "error_code": "UNKNOWN_STATUS",
              "data": null,
            }),
          );
      }
    },
  );
}
