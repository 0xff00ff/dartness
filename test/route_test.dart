import 'package:test/test.dart';
import 'package:dartness/dartness.dart';
import 'dart:io';
import 'dart:convert' show utf8;

class TestError extends Error {}

void main() {
  print('start route test');

  final app = new Dartness();
  final router = new Router();

  app.use((Context context) async {
    context.res.write('m1');
  });

  router.get('/', (Context ctx) async => ctx.res.write('r1'));
  router
      .get('/middleware', (Context ctx) async => ctx.res.write('r2'))
      .useBefore((Context ctx) => ctx.res.write('m21'))
      .useAfter((Context ctx) => ctx.res.write('m22'));

  router
      .get('/middleware/broken', (Context ctx) async => ctx.res.write('r2'))
      .useBefore((Context ctx) => throw new TestError())
      .useAfter((Context ctx) => ctx.res.write('m22'), catchError: true);

  router
      .get('/middleware/newer', (Context ctx) async => ctx.res.write('r2'))
      .useBefore((Context ctx) => throw new TestError())
      .useAfter((Context ctx) => ctx.res.write('m22'));

  router.get('/:q/:w/:e', (Context ctx) {
    if (!ctx.req.params.containsKey('q')) {
      print('q');
      throw new TestError();
    }
    if (!ctx.req.params.containsKey('w')) {
      print('w');
      throw new TestError();
    }
    if (!ctx.req.params.containsKey('e')) {
      print('e');
      throw new TestError();
    }
    return ctx.req.params['q'] + ctx.req.params['w'] + ctx.req.params['e'];
  });

  router.get('/:qwe:(\\w)/:asd(\\w)', (Context ctx) {
    if (!ctx.req.params.containsKey('qwe')) {
      print('qwe');
      throw new TestError();
    }
    if (!ctx.req.params.containsKey('asd')) {
      print('asd');
      throw new TestError();
    }
    return ctx.req.params['qwe'] + ctx.req.params['asd'];
  }, useRegexp: true);

  app.use(router);

  app.use((Context ctx) {
    ctx.res.write('err');
  }, catchError: true);

  setUp(() {
    app.listen(port: 4042);
  });

  test('route can be checked', () async {
    final client = new HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:4042/'));
    final response = await request.close();
    final result =
        await response.cast<List<int>>().transform(utf8.decoder).join();

    expect(result, 'm1r1');
  });

  test('route can\'t be checked', () async {
    final client = new HttpClient();
    final request =
        await client.getUrl(Uri.parse('http://localhost:4042/fake'));
    final response = await request.close();
    final result =
        await response.cast<List<int>>().transform(utf8.decoder).join();

    expect(result, 'm1');
  });

  test('route use middleware', () async {
    final client = new HttpClient();
    final request =
        await client.getUrl(Uri.parse('http://localhost:4042/middleware'));
    final response = await request.close();
    final result =
        await response.cast<List<int>>().transform(utf8.decoder).join();

    expect(result, 'm1m21r2m22');
  });

  test('middleware breaking route', () async {
    final client = new HttpClient();
    final request = await client
        .getUrl(Uri.parse('http://localhost:4042/middleware/broken'));
    final response = await request.close();
    final result =
        await response.cast<List<int>>().transform(utf8.decoder).join();

    expect(result, 'm1m22');
  });

  test('route with middleware can\'t be checked', () async {
    final client = new HttpClient();
    final request = await client
        .getUrl(Uri.parse('http://localhost:4042/middleware/newer'));
    final response = await request.close();
    final result =
        await response.cast<List<int>>().transform(utf8.decoder).join();
    expect(result, 'm1err');
  });

  tearDown(() async {
    await app.close(force: true);
  });
}
