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

  //TODO: add ability to use this
  String _basePath = '';

  Router({String basePath: ''}) {
    _basePath = basePath;
  }

  void get(String path, Function callback) async =>
      route(HttpMethod.get, path, callback);
  void post(String path, Function callback) async =>
      route(HttpMethod.post, path, callback);
  void patch(String path, Function callback) async =>
      route(HttpMethod.patch, path, callback);
  void put(String path, Function callback) async =>
      route(HttpMethod.put, path, callback);
  void delete(String path, Function callback) async =>
      route(HttpMethod.delete, path, callback);

  void route(String method, String path, Function callback) async {
    path = _basePath + path.replaceAll(new RegExp('(^\/|\/\$)'), '');
    path = path.replaceAll('//', '/');

    _routes.add(new Route(method, path, callback));
  }

  @override
  Future<void> call(Context context) async {
    for (var routeItem in _routes) {
      if (routeItem.isMatching(context.req.method, context.req.requestedUri)) {
        context.req.params = routeItem.params;
        return routeItem.callback(context);
      }
    }
  }
}
