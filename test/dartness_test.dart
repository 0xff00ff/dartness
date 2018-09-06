import 'package:test/test.dart';
import 'package:dartness/dartness.dart';
import 'dart:io';
import 'dart:convert' show utf8;

void main() {
  print('start dartness test');

  final app = new Dartness();

  setUp(() {
    app.listen(port: 4041);
    app.use((Context context) async {
      context.res.write('dartness is working');
    });
  });

  test('dartness starts and can be shut down', () async {
    final client = new HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:4041'));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();

    expect('dartness is working', result);
  });

  tearDown(() async {
    await app.close();
  });
}
