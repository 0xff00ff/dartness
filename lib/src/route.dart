import 'dart:math';

class Route {

  String path = '';
  String method = 'GET';
  Function callback;

  Map<String, String> params = {};

  Route(this.method, this.path, this.callback);

  bool isMatching(String method, Uri uri) {
    if (this.method != method) {
      return false;
    }
    final pathParts = path.split('/');
    final uriPaths = uri.path.split('/');

    if (pathParts.length != uriPaths.length) {
      return false;
    }

    final len = min(pathParts.length, uriPaths.length);

    for (var q = 0; q < len; q++) {
      if (pathParts[q].startsWith(':')) {
        final key = pathParts[q].substring(1);
        params[key] = uriPaths[q];
        continue;
      }

      if (pathParts[q] == uriPaths[q]) {
        continue;
      } else {
        return false;
      }
    }

    return true;
  }


}