import 'dart:async';
import 'dart:mirrors';

import 'package:dartness/src/callable.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/routeItem.dart';
import 'package:dartness/src/httpMethod.dart';
import 'package:dartness/src/meta.dart';

class Router implements Callable {
  final List<RouteItem> _routes = [];
  @override
  bool catchError = false;
  String _basePath = '';

  Router({String basePath: ''}) {
    _basePath = basePath;
  }

  RouteItem get(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.get, path, callback, useRegexp: useRegexp);

  RouteItem post(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.post, path, callback, useRegexp: useRegexp);

  RouteItem patch(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.patch, path, callback, useRegexp: useRegexp);

  RouteItem put(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.put, path, callback, useRegexp: useRegexp);

  RouteItem delete(String path, Function callback, {bool useRegexp = false}) =>
      route(HttpMethod.delete, path, callback, useRegexp: useRegexp);

  RouteItem route(String method, String path, Function callback,
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
        new RouteItem(method, correctedPath, callback, useRegexp: useRegexp);
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

  void bind(Object obj) {
    final instance = reflect(obj);
    instance.type.instanceMembers.forEach((Symbol name, MethodMirror method) {
      method.metadata.forEach((InstanceMirror metaItem){
        if (metaItem.reflectee is Route) {
          Route inst = metaItem.reflectee;
          route(inst.method, inst.path, (Context ctx) {
            instance.invoke(name, <Context>[ctx]);
          });
        }
      });
    });
  }
}




