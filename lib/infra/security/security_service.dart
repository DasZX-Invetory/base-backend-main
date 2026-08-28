import 'package:shelf/shelf.dart';

abstract class SecurityService<T> {
  // GERAÇÃO DE TOKENS SEPARADOS
  Future<String> generateAccessToken(String userID, String role, int active);
  Future<String> generateRefreshToken(String userID);

  // Valida um token e retorna os dados decodificados
  Future<T?> validateJWT(String token);

  // Middleware que extrai o JWT do header e adiciona ao contexto
  Middleware get authorization;

  // Middleware que verifica se existe um JWT válido no contexto
  Middleware get verifyJwt;

  // Middleware que verifica se está ativo ou não
  Middleware get verifyStatus;

  // Middleware que verifica se o usuário tem a role necessária
  Middleware requireRole(String requiredRole);
}
