import 'dart:io';
import 'dart:isolate';

import 'package:dartness/dartness.dart';
import 'package:{{projectName}}/routes.dart';

void main() async {

  final isolates = Platform.numberOfProcessors;

  start('');
  for (int i = 1; i < isolates; i++) {
    Isolate.spawn(start, '');
  }
  
}

void start(String arg) async {

  final app = new Dartness();

  // init routes
  routesBootstrap(app);

  app.listen(host: InternetAddress.anyIPv4, port: 4040);

  print('spawned dartness at http://localhost:4040/');
}
