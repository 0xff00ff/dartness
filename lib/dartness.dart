import 'dart:io';
import 'dart:async';

import 'package:body_parser/body_parser.dart';
import 'package:http_parser/http_parser.dart';

import 'package:dartness/src/context.dart';
import 'package:dartness/src/callable.dart';
import 'package:dartness/src/router.dart';
import 'package:dartness/src/middleware.dart';
import 'package:dartness/src/httpMethod.dart';

export 'package:dartness/src/context.dart';
export 'package:dartness/src/callable.dart';
export 'package:dartness/src/router.dart';
export 'package:dartness/src/module.dart';
export 'package:dartness/src/meta.dart';
export 'package:dartness/src/httpMethod.dart';

export 'package:dartness/src/middlewares/cors.dart';

class Dartness {
  Middleware middlewareChain = new Middleware();

  HttpServer _http;

  void use(Function middleware, {bool catchError: false}) {
    final callable = new Callable(middleware, catchError: catchError);
    middlewareChain.add(callable);
  }

  void listen({InternetAddress host, int port = 4040}) async {
    // print('spawned dartness ...');
    host ??= InternetAddress.anyIPv4;

    _http = await HttpServer.bind(host, port, shared: true);
    await for (final HttpRequest req in _http) {
      // final start = new DateTime.now();
      final context = new Context(req);
      if (req.method == HttpMethod.post ||
          req.method == HttpMethod.put ||
          req.method == HttpMethod.patch) {
        final contentType = req.headers.contentType != null
            ? new MediaType.parse(req.headers.contentType.toString())
            : null;
        final body = await parseBodyFromStream(req, contentType, req.uri);
        context.req.body = body.body;
      }

      try {
        await middlewareChain.execute(context);
      } catch (e) {
        // log?
        context.res.statusCode = 500;
        context.res.write("Internal server error");
      }

      if (!context.res.isClosed()) {
        context.res.close();
      }
      // final finish = new DateTime.now().difference(start);
      // print('[dartness] request time: ' + finish.inMilliseconds.toString());
    }
  }

  Future close({bool force = false}) async => _http.close(force: force);
}

Future<void> staticFileHandler(String path) async {
  final router = new Router();
  router.get(path, (Context context) {
    context.res.write('static');
    context.res.close();
  });
}
