import 'dart:async';

import 'package:dartness/src/callable.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/router.dart';
import 'package:dartness/src/routeItem.dart';
import 'package:dartness/src/middleware.dart';

class Module implements Callable {
  @override
  bool catchError = false;
  Middleware middlewareChain = new Middleware();
  final String _url;
  @override
  List<Argument> arguments = <Argument>[];

  Module(this._url);

  void addMiddleware(Function middleware) {
    middlewareChain.add(new Callable.function(middleware));
  }

  void addRouter(Router router) {
    middlewareChain.add(router);
  }

  @override
  Future<void> call(Context context) async {
    final callable = new Callable.function((Context context) async {
      await middlewareChain.execute(context);
    });
    final route = new RouteItem('*', _url, callable);
    if (route.isMatching(context.req.method, context.req.requestedUri)) {
      await route.callback(context);
    }
  }
}
