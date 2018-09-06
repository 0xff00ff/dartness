import 'package:dartness/src/callable.dart';
import 'package:dartness/src/middleware.dart';
import 'package:dartness/src/context.dart';

import 'dart:math';
import 'dart:async';

class Route {
  String path = '';
  String method = 'GET';
  Function callback;
  final List<Callable> _before = [];
  final List<Callable> _after = [];

  Map<String, String> params = {};

  Route(this.method, this.path, this.callback);

  bool isMatching(String method, Uri uri) {
    if (this.method != method && this.method != '*') {
      return false;
    }
    final pathParts = path.split('/');
    final uriPaths = uri.path.split('/');

    if (pathParts.length != uriPaths.length) {
      return false;
    }

    final len = min(pathParts.length, uriPaths.length);

    for (var q = 0; q < len; q++) {
      if (pathParts[q].startsWith(':')) {
        final key = pathParts[q].substring(1);
        params[key] = uriPaths[q];
        continue;
      }

      if (pathParts[q] == uriPaths[q]) {
        continue;
      } else {
        return false;
      }
    }

    return true;
  }

  Future<void> call(Context context) async {
    final stack = new Middleware();
    stack.addAll(_before);
    stack.add(new Callable(callback));
    stack.addAll(_after);
    return stack.execute(context);
  }

  Route useBefore(Function middleware, {bool catchError = false}) {
    _before.add(new Callable(middleware, catchError: catchError));
    return this;
  }

  Route useAfter(Function middleware, {bool catchError = false}) {
    _after.add(new Callable(middleware, catchError: catchError));
    return this;
  }
}
