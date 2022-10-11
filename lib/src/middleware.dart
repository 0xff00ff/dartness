import 'dart:async';

import 'package:dartness/src/context.dart';
import 'package:dartness/src/callable.dart';

class Middleware {
  String name = '';
  final List<Callable> _middlewareStack = [];

  void add(Callable middleware) {
    _middlewareStack.add(middleware);
  }

  void addAll(List<Callable> middleware) {
    _middlewareStack.addAll(middleware);
  }

  Future<void> execute(Context context) async {
    var isError = false;
    context.error = null;

    for (var q = 0; q < _middlewareStack.length; q++) {
      final middleware = _middlewareStack[q];
      try {
        if (isError) {
          if (middleware.canCatchError()) {
            await middleware.call(context);
            isError = false;
            context.error = null;
          } else {
            continue;
          }
        } else if (!middleware.canCatchError()) {
          await middleware.call(context);
        }
      } catch (e) {
        isError = true;
        print('caught an error');
        print(e);
        context.error = AssertionError(e);
      }

      if (context.res.isClosed()) {
        break;
      }
    }

    final err = context.error;
    if (isError && err != null) {
      throw err;
    }
  }
}
