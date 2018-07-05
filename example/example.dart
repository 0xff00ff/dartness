import 'dart:io';

import 'package:dartness/dartness.dart';

void main() {

  final app = new Dartness();

  app.use((Context context) async {
    print('middleware 1');
  }, catchError: false);

  app.use((Context context) async {
    print('middleware 2');
  });

  final router = new Router();

  router.get('/:param1/:param2/:param3', (Context context) async {
    print ('GET /' + context.req.params.toString()); // map {param1: 'value1', param2: value2, param3: value3}
  });

  router.get('/', (Context context) async => null);
  router.post('/', (Context context) async => print(context.req.body)); // body is a map

  app.use(router);

  app.use((Context context) async {
    // print('sending response');
    context.res
      ..headers.add(HttpHeaders.contentTypeHeader, 'application/json')
      ..write('{"qe": "asd", "zxc": 4}')
      ..close();
  });

  app.use((Context context) async {
    print('wow, here is was an error!');
    context.res.write('middleware 2');
  }, catchError: true);

  app.listen(host: InternetAddress.anyIPv4, port: 4040);

}

