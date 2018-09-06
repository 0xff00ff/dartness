import 'dart:async';

import 'package:dartness/src/callable.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/route.dart';

class HttpMethod {
  static String get = 'GET';
  static String post = 'POST';
  static String patch = 'PATCH';
  static String put = 'PUT';
  static String delete = 'DELETE';
  static String options = 'OPTIONS';
}

class Router implements Callable {
  final List<Route> _routes = [];
  @override
  bool catchError = false;
  String _basePath = '';

  Router({String basePath: ''}) {
    _basePath = basePath;
  }

  Route get(String path, Function callback) =>
      route(HttpMethod.get, path, callback);

  Route post(String path, Function callback) =>
      route(HttpMethod.post, path, callback);

  Route patch(String path, Function callback) =>
      route(HttpMethod.patch, path, callback);

  Route put(String path, Function callback) =>
      route(HttpMethod.put, path, callback);

  Route delete(String path, Function callback) =>
      route(HttpMethod.delete, path, callback);

  Route route(String method, String path, Function callback) {
    final correctedPath = '/' +
        (_basePath + path)
            .replaceAll(new RegExp('(^\/+|\/+\$)'), '')
            .replaceAll('//', '/');
    final route = new Route(method, correctedPath, callback);
    _routes.add(route);
    return route;
  }

  @override
  Future<void> call(Context context) async {
    for (var routeItem in _routes) {
      if (routeItem.isMatching(context.req.method, context.req.requestedUri)) {
        context.req.params = routeItem.params;
        await routeItem(context);
      }
    }
  }
}
