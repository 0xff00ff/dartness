import 'dart:io';

import 'package:dartness/dartness.dart';

void main() {

  final app = new Dartness();

  app.use((Context context) async {
    //print('middleware 1');
  }, catchError: false);

  app.use((Context context) async {
    //print('middleware 1.5');
  });

  final router = new Router();

  router.get('/:param1/:param2/:param3', (Context context) async {
    print ('GET /:hello ' + context.req.params.toString());
  });

  router.get('/', (Context context) async => null);
  router.post('/', (Context context) async => print(context.req.body['message']['text']));

  app.use(router);

  app.use((Context context) async {
    // print('sending response');
    context.res..headers.add(HttpHeaders.CONTENT_TYPE, 'application/json')
      ..write('{"qe": "asd", "zxc": 4}')
      ..close();
  });

  app.use((Context context) async {
    print('wow, here is was an error!');
    context.res.write('middleware 2');
  }, catchError: true);

  app.listen(host: InternetAddress.ANY_IP_V4, port: 4040);

}

