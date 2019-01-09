import 'package:dartness/src/context.dart';
import 'package:dartness/src/routeMatcher.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'dart:math';

class StaticMiddleware {
  String _directory;
  String _uri;
  String _index;
  final String _dir = Directory.current.path.substring(0, Directory.current.path.length - 0);

  StaticMiddleware(String directory, {String uri, String index}) {
    if (!directory.startsWith('/')) {
      directory = '/' + directory;
    }
    _uri = uri;
    if (null == uri) {
      _uri = directory;
    } 
    _directory = directory;
    _index = index;

    final indexUri = Uri.parse(_dir + _directory + '/' + _index);
    print(indexUri.path);
    final file = File.fromUri(indexUri);
    if (!file.existsSync()) {
      throw new Error();
    }
  }

  void call(Context ctx) async {
    final matcher = new RouteMatcher();

    var uriParts = _uri.split('/');
    uriParts.removeWhere((str) => str.isEmpty);
    var pathParts = ctx.req.requestedUri.path.split('/');
    pathParts.removeWhere((str) => str.isEmpty);
    final minLength = min(uriParts.length, pathParts.length);
    uriParts = uriParts.sublist(0, minLength);
    pathParts = pathParts.sublist(0, minLength);

    print(uriParts.join('/') + '=' + pathParts.join('/'));

    matcher.match(uriParts.join('/'), pathParts.join('/'));
    if (matcher.matched) {
      var path = ctx.req.requestedUri.path;
      if (_directory != _uri) {
        path = path.replaceFirst(_uri, _directory);
      }
      final uri = Uri.parse(_dir + path);
      var file = File.fromUri(uri);
      final fileExists = file.existsSync();
      if (!fileExists) {
        final uri = Uri.parse(_dir + _directory + '/' + _index);
        file = File.fromUri(uri);
      }
      final mime = lookupMimeType(file.path);
      ctx.res.headers.add('content-type', mime);
      ctx.res.statusCode = 200;
      await ctx.res.response.addStream(file.openRead());
      ctx.res.close();
    }
  }
}