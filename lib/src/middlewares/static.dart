import 'package:dartness/src/context.dart';
import 'package:dartness/src/routeMatcher.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'dart:math';

class StaticMiddleware {
  String directory;
  String uri = '';
  String index;
  final String _dir = Directory.current.path.substring(0, Directory.current.path.length - 0);

  StaticMiddleware(this.directory, {String? uri, this.index = ''}) {
    if (!directory.startsWith('/')) {
      directory = '/' + directory;
    }

    this.uri = directory;
    if (uri != null) {
      this.uri = uri;
    }

    final indexUri = Uri.parse(_dir + directory + '/' + index);
    final file = File.fromUri(indexUri);
    if (!file.existsSync()) {
      throw new Error();
    }
  }

  void call(Context ctx) async {
    final matcher = new RouteMatcher();

    var uriParts = uri.split('/');
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
      if (directory != this.uri) {
        path = path.replaceFirst(this.uri, directory);
      }
      final uri = Uri.parse(_dir + path);
      var file = File.fromUri(uri);
      final fileExists = file.existsSync();
      if (!fileExists) {
        final uri = Uri.parse(_dir + directory + '/' + index);
        file = File.fromUri(uri);
      }
      final mime = lookupMimeType(file.path);
      ctx.res.headers.add('content-type', mime!);
      ctx.res.statusCode = 200;
      await ctx.res.response.addStream(file.openRead());
      ctx.res.close();
    }
  }
}