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

  router.get('/:param1/:param2/:param3', (String param3, Context context, String param1, String param2) async {
    // you can use params direct trough function arguments, or get from
    // context.req.params = map {param1: 'value1', param2: value2, param3: value3}
    print('GET /' + context.req.params.toString());
  });

  router.get('/', (Context context) async => null);
  router.post(
      '/', (Context context) async => print(context.req.body)); // body is a map
  router
      .get('/secret',
          (Context context) async => context.res.write('secret word'))
      .useBefore((Context context) {
    if (context.req.headers.value('X-Secret-Code').isEmpty) {
      throw new StateError('You shall not pass!');
    }
  });
  router.get(r'/:blogId(\d+$)', (String blogId, Context context) {
    // will match on route: /some-blog-title-1234/
    // regex params can be used in function arguments as well
    final reqBlogId = context.req.params['blogId']; // 1234
    context.res.write('blogId is ' + blogId + ' and ' + reqBlogId);
  });

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
