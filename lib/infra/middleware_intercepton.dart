import 'package:shelf/shelf.dart';

class MiddlewareInterception {
  static Middleware get contentTypeJson => createMiddleware(
    responseHandler: (Response res) =>
        res.change(headers: {'content-type': 'application/json'}),
  );

  static Middleware get cors {
    final headersPermitidos = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };

    Response? handleOptions(Request req) {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: headersPermitidos);
      }
      return null; // Continua para o próximo handler
    }

    Response addCorsHeaders(Response res) =>
        res.change(headers: headersPermitidos);

    return createMiddleware(
      requestHandler: handleOptions,
      responseHandler: addCorsHeaders,
    );
  }
}

/// Mantido para compatibilidade com versoes anteriores do projeto.
class MiddlewareIntercepton extends MiddlewareInterception {}
