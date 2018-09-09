import 'package:test/test.dart';
import 'package:dartness/src/routeMatcher.dart';

void main() {
  final matcher = new RouteMatcher();

  test('simple route', () async {
    matcher.match('/', '/');
    expect(matcher.matched, true);
    expect(matcher.params.length, 0);
  });

  test('simple route with param', () async {
    matcher.match('/:id', '/1');
    expect(matcher.matched, true);
    expect(matcher.params.length, 1);
    expect(matcher.params.containsKey('id'), true);
  });

  test('simple route with many params', () async {
    matcher.match('/:name/:id', '/qwe/2');
    expect(matcher.matched, true);
    expect(matcher.params.length, 2);
    expect(matcher.params.containsKey('name'), true);
    expect(matcher.params.containsKey('id'), true);
  });

  test('simple route with regexp', () async {
    matcher.match('/:name(.*)', '/qwe');
    expect(matcher.matched, true);
    expect(matcher.params.length, 1);
    expect(matcher.params.containsKey('name'), true);
  });

  test('regexp routes', () async {
    matcher.match('/:name(^.{1})', '/qwe');
    expect(matcher.matched, true);
    expect(matcher.params.length, 1);
    expect(matcher.params.containsKey('name'), true);
    expect(matcher.params['name'], 'q');

    matcher.match(r'/:name(^\d)', '/qwe');
    expect(matcher.matched, false);
    expect(matcher.params.length, 0);

    matcher.match(r'/:name(^\d)', '/3qwe2');
    expect(matcher.matched, true);
    expect(matcher.params.length, 1);
    expect(matcher.params.containsKey('name'), true);
    expect(matcher.params['name'], '3');
  });
}
