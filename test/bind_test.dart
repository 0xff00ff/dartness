import 'package:test/test.dart';
import 'package:dartness/dartness.dart';
import 'dart:io';
import 'dart:convert' show utf8;

class A {
  @Get('/')
  void index(Context c) {
    c.res.write('index');
  }

  @Get('/:param')
  void param(Context c, String param) {
    c.res.write(param);
  }
}

void main() {
  print('start bind test');

  final app = new Dartness();
  final router = new Router();
  router.bind(new A());
  app.use(router);

  setUp(() {
    app.listen(port: 4041);
  });

  test('index method executed', () async {
    final client = new HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:4041'));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();
    print(result);
    expect(result, 'index');
  });

  test('param method executed', () async {
    final client = new HttpClient();
    final request =
        await client.getUrl(Uri.parse('http://localhost:4041/param3'));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();
    print(result);
    expect(result, 'param3');
  });

  tearDown(() async {
    await app.close();
  });
}
