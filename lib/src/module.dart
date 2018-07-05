import 'dart:async';

import 'package:dartness/src/callable.dart';
import 'package:dartness/src/context.dart';
import 'package:dartness/src/router.dart';
import 'package:dartness/src/route.dart';
import 'package:dartness/src/middleware.dart';

class Module implements Callable{
  @override
  bool catchError = false;
  Middleware middlewareChain = new Middleware();

  String _url;

  Module(this._url);

  void addMiddleware(Function middleware) {
    middlewareChain.add(new Callable(middleware));
  }

  void addRouter(Router router) {
    middlewareChain.add(router);
  }

  @override
  Future<void> call(Context context) async {

    final route = new Route('*', _url, (Context context) async {
      await middlewareChain.execute(context);
    });
    if (route.isMatching(context.req.method, context.req.requestedUri)) {
      await route.callback(context);
    }

  }
}