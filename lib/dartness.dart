import 'dart:io';
import 'dart:async';

import 'package:body_parser/body_parser.dart';

import 'package:dartness/src/context.dart';
import 'package:dartness/src/callable.dart';
import 'package:dartness/src/router.dart';

export 'package:dartness/src/context.dart';
export 'package:dartness/src/callable.dart';
export 'package:dartness/src/router.dart';

class Dartness {
  final List<Callable> _middlewareStack = [];

  void use(Function middleware, {bool catchError: false}) {
    final callable = new Callable(middleware, catchError: catchError);
    _middlewareStack.add(callable);
  }

  void listen({InternetAddress host, int port = 4040}) async {
    print('spawned dartness ...');
    host ??= InternetAddress.ANY_IP_V4;

    final http = await HttpServer.bind(host, port, shared: true);
    await for (final HttpRequest req in http) {
      final start = new DateTime.now();
      final context = new Context(req);
      if (req.method == HttpMethod.post ||
          req.method == HttpMethod.put ||
          req.method == HttpMethod.patch) {
        final body = await parseBody(req);
        context.req.body = body.body;
      }
      var isError = false;
      context.error = null;
      for (var middleware in _middlewareStack) {
        try {
          if (isError) {
            if (middleware.catchError) {
              await middleware.call(context);
              isError = false;
              context.error = null;
            } else {
              continue;
            }
          } else if (middleware.catchError == false) {
            await middleware.call(context);
          }
        } catch (e) {
          print('catched an error');
          print(e);
          isError = true;
          context.error = e;
        }

        if (context.res.isClosed()) {
          break;
        }
      }

      if (!context.res.isClosed()) {
        context.res.close();
      }
      final finish = new DateTime.now().difference(start);
      print('[dartness] request time: ' + finish.inMilliseconds.toString());
    }
  }
}

Future<void> staticFileHandler(String path) async {
  final router = new Router();
  router.get(path, (Context context) {
    context.res.write('static');
    context.res.close();
  });
}
