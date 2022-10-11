import 'package:dartness/src/callable.dart';
import 'package:dartness/src/middleware.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/routeMatcher.dart';

import 'dart:async';

class RouteItem {
  String path = '';
  String method = 'GET';
  Callable callback;
  final List<Callable> _before = [];
  final List<Callable> _after = [];
  bool useRegexp = false;
  Map<String, String> params = {};

  RouteItem(this.method, this.path, this.callback, {this.useRegexp = false});

  bool isMatching(String method, Uri uri) {
    if (this.method != method && this.method != '*') {
      return false;
    }
    final matcher = new RouteMatcher();
    matcher.match(path, uri.path);
    params = matcher.params;
    return matcher.matched;
  }

  Future<void> call(Context context) async {
    final stack = new Middleware();
    stack.addAll(_before);
    stack.add(callback);
    stack.addAll(_after);
    return stack.execute(context);
  }

  RouteItem useBefore(Function middleware, {bool catchError = false}) {
    _before.add(new FunctionCallable.init(middleware, catchError: catchError));
    return this;
  }

  RouteItem useAfter(Function middleware, {bool catchError = false}) {
    _after.add(new FunctionCallable.init(middleware, catchError: catchError));
    return this;
  }
}
