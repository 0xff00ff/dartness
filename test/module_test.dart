import 'package:test/test.dart';
import 'package:dartness/dartness.dart';
import 'dart:io';
import 'dart:convert' show utf8;

void main () {

  print('start module test');

  final app = new Dartness();
  final router = new Router(basePath: '/module');
  final module = new Module('/module');

  app.use((Context context) async => context.res.write('m1'));

  router.get('/', (Context ctx) async => ctx.res.write('r1'));
  module.addRouter(router);
  app.use(module);

  setUp(() {
    app.listen(port: 4042);
  });

  test('dartness starts and route can be checked', () async {

    final client = new HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:4042/module'));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();

    expect(result, 'm1r1');

  });

  test('dartness starts and route can\'t be checked', () async {

    final client = new HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:4042/'));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();

    expect(result, 'm1');

  });

  tearDown(() async {
    await app.close(force: true);
  });



}