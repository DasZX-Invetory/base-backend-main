import 'package:backend_daszx_inventory/infra/dependency_injector/dependency_injector.dart';
import 'package:backend_daszx_inventory/infra/security/security_service.dart';
import 'package:shelf/shelf.dart';

abstract class Api {
  // Método que toda API deve implementar
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  });

  // Método auxiliar para criar o handler com middlewares e segurança
  Handler createHandler({
    required Handler router,
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    middlewares ??= [];

    // Se a rota precisa de segurança, adiciona os middlewares de JWT
    if (isSecurity) {
      var securityService = DependencyInjector().get<SecurityService>();
      middlewares.addAll([
        securityService.authorization,
        securityService.verifyJwt,
        securityService.verifyStatus,
      ]);

      // Se tiver role obrigatória, adiciona o middleware de verificação
      if (requiredRole != null) {
        middlewares.add(securityService.requireRole(requiredRole));
      }
    }

    var pipeline = Pipeline();
    for (var m in middlewares) {
      pipeline = pipeline.addMiddleware(m);
    }

    return pipeline.addHandler(router);
  }
}
