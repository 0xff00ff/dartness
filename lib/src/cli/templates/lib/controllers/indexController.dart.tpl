import 'package:dartness/dartness.dart' show Context;

class IndexController {

  static void index(Context ctx) async {
    ctx.locals['version'] = '0.0.1';
    ctx.locals['message'] = 'Hello world';
  }

  static void secret(Context ctx) async {
    ctx.locals['version'] = '0.0.1';
    ctx.locals['message'] = 'Secret hello world';
  }

}