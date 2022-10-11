import 'dart:async';
import 'dart:mirrors';

import 'package:dartness/src/callable.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/routeItem.dart';
import 'package:dartness/src/httpMethod.dart';
import 'package:dartness/src/meta.dart';

class Router extends Callable {
  final List<RouteItem> _routes = [];
  String _basePath = '';
  List<Argument> arguments = <Argument>[];

  Router({String basePath: ''}) {
    _basePath = basePath;
  }

  RouteItem get(String path, Function callback, {bool useRegexp = false}) =>
      _route(HttpMethod.get, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem post(String path, Function callback, {bool useRegexp = false}) =>
      _route(HttpMethod.post, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem patch(String path, Function callback, {bool useRegexp = false}) =>
      _route(HttpMethod.patch, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem put(String path, Function callback, {bool useRegexp = false}) =>
      _route(HttpMethod.put, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem delete(String path, Function callback, {bool useRegexp = false}) =>
      _route(HttpMethod.delete, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem route(String method, String path, Function callback,
          {bool useRegexp = false}) =>
      _route(method, path, FunctionCallable.init(callback),
          useRegexp: useRegexp);

  RouteItem _route(String method, String path, Callable callback,
      {bool useRegexp = false}) {
    final correctedPath = '/' +
        (_basePath + path)
            .replaceAll(new RegExp('(^\/+|\/+\$)'), '')
            .replaceAll('//', '/');

    final route =
        new RouteItem(method, correctedPath, callback, useRegexp: useRegexp);
    _routes.add(route);

    return route;
  }

  @override
  Future<void> call(Context context) async {
    var called = false;
    for (var routeItem in _routes) {
      if (!called &&
          routeItem.isMatching(context.req.method, context.req.requestedUri)) {
        called = true;
        context.req.params = routeItem.params;
        await routeItem(context);
      }
    }
  }

  void bind(Object obj) {
    final instance = reflect(obj);
    instance.type.instanceMembers.forEach((Symbol name, MethodMirror method) {
      Route? r;
      method.metadata.forEach((InstanceMirror metaItem) {
        final dynamic ref = metaItem.reflectee;
        if (ref is Route) {
          r = ref;
        }
      });
      if (r != null) {
        route(r!.method, r!.path, MethodCallable.init(instance, method));
      }
    });
  }
}
