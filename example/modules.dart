import 'dart:async';

import 'package:dartness/dartness.dart';

void main() {
  final app = new Dartness();

  final route1 = new Router();
  final route2 = new Router();

  final module1 = new Module('/api');

  route1.route('*', '/', () async => print('111'));
  route2.route('*', '/', () async => print('222'));

  Future<void> middleware1(Context ctx) async {
    print('api middleware1');
  }

  Future<void> middleware2(Context ctx) async {
    print('api middleware2');
  }

  Future<void> middleware3(Context ctx) async {
    print('main middleware before 1');
  }

  module1.addRouter(route1);
  module1.addMiddleware(middleware1);
  module1.addMiddleware(middleware2);
  module1.addRouter(route2);

  // will be called before module and routes added to module
  app.use(middleware3); 

  app.use(module1);

  app.use((Context ctx) async {
    print('end');
  });

  app.listen();
}
