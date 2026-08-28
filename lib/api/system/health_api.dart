import 'dart:convert';

import 'package:backend_daszx_inventory/api/api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class HealthApi extends Api {
  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    final router = Router();

    router.get('/health', (Request req) {
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'API online',
          'data': {'status': 'ok'},
        }),
      );
    });

    return createHandler(router: router.call, middlewares: middlewares);
  }
}
