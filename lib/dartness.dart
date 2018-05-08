import 'dart:io';
import 'dart:async';
import 'dart:isolate';

import 'package:dartness/context.dart';

class Dartness {

  Context _context;
  var _middlewareStack = new List();

  Dartness();

  void use(middleware){
    this._middlewareStack.add(middleware);
  }

  void listen() async {
      final HttpServer httpd = await HttpServer.bind(InternetAddress.ANY_IP_V4, 4040, shared: true);
      await for (final HttpRequest req in httpd) {
        Context context = new Context(req);
        for (int q = 0; q < this._middlewareStack.length; q++) {
          var middleware = this._middlewareStack[q];
          context = middleware(context);
        }
        context.req.response.close();
      }
  }
}
