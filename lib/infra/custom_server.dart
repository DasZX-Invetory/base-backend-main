import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class CustomServer {
  Future<void> initialize({
    required Handler handler,
    required String address,
    required int port,
  }) async {
    final server = await shelf_io.serve(handler, address, port);
    print(
      '[SERVER] API iniciada em http://${server.address.host}:${server.port}',
    );
    print('[SERVER] Healthcheck: GET /health');
  }
}
