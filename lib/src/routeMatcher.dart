import 'dart:math';

class RouteMatcher {
  Map<String, String> params = {};
  bool matched = true;

  void match(String route, String uri) {
    // reset state
    matched = true;
    params = {};

    final pathParts = route.split('/');
    pathParts.removeWhere((i) => i.isEmpty);
    final uriPaths = uri.split('/');
    uriPaths.removeWhere((i) => i.isEmpty);

    if (pathParts.length != uriPaths.length) {
      matched = false;
      return;
    }

    final len = min(pathParts.length, uriPaths.length);

    for (var q = 0; q < len; q++) {
      if (pathParts[q].startsWith(':')) {
        final key = pathParts[q].replaceAllMapped(
            new RegExp('^:([a-z]+).*\$'), (Match match) => match.group(1));

        // check if key is regexp value
        if (new RegExp('^:[a-z]+\$', caseSensitive: false)
            .hasMatch(pathParts[q])) {
          // it's simple pattern
          params[key] = uriPaths[q];
        } else {
          // it's regexp value, use it
          final regexp = pathParts[q].replaceFirst(new RegExp('^:[a-z]+'), '');
          if (new RegExp(regexp).hasMatch(uriPaths[q])) {
            final match = new RegExp(regexp).firstMatch(uriPaths[q]);
            params[key] = match.groupCount > 0 ? match.group(1) : '';
          } else {
            matched = false;
            return;
          }
        }
        continue;
      } else if (pathParts[q] == uriPaths[q]) {
        continue;
      } else {
        matched = false;
        return;
      }
    }
  }
}
