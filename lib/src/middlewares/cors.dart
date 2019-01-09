import 'package:dartness/src/context.dart';

class CorsMiddleware {
  List<String> _origins = [];
  List<String> _methods = [];
  final List<String> _headers = [
    'X-Auth-Token',
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization'
  ];

  CorsMiddleware.full() {
    _origins = ['*'];
    _methods = ['GET', 'PUT', 'POST', 'DELETE', 'PATCH', 'OPTIONS'];
  }

  CorsMiddleware.exact(List<String> origins, List<String> methods) {
    _origins = origins;
    _methods = methods;
  }

  void call(Context ctx) {
    ctx.res.headers.set('Access-Control-Allow-Origin', _origins.join(', '));
    ctx.res.headers.set('Access-Control-Allow-Headers', _headers.join(', '));
    ctx.res.headers.set('Access-Control-Allow-Methods', _methods.join(', '));
  }
}
