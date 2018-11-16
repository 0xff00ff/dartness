import 'dart:async';
import 'dart:mirrors';

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

  Route get(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.get, path, callback, useRegexp: useRegexp);

  Route post(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.post, path, callback, useRegexp: useRegexp);

  Route patch(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.patch, path, callback, useRegexp: useRegexp);

  Route put(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.put, path, callback, useRegexp: useRegexp);

  Route delete(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.delete, path, callback, useRegexp: useRegexp);

  Route route(String method, String path, Function callback,
      {bool useRegexp = false}) {

    // check caller with mirrors
    final ClosureMirror _caller = reflect(callback);

    final parameters = _caller.function.parameters;
    parameters.forEach((ParameterMirror p){
      final type = MirrorSystem.getName(p.type.simpleName);
      if (type != 'String' && type != 'Context') {
        throw new ArgumentError("'$type' unsupported type in route arguments ($method $path)");
      }
    });


    final correctedPath = '/' +
        (_basePath + path)
            .replaceAll(new RegExp('(^\/+|\/+\$)'), '')
            .replaceAll('//', '/');

    final route =
        new Route(method, correctedPath, callback, useRegexp: useRegexp);
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




