import 'dart:async';
import 'package:dartness/dartness.dart';

class Auth {

  static Future<void> checkAuthorization (Context context) async {
    if (null == context.req.headers.value('x-auth-token')) {
      throw new UnsupportedError('Acces denied');
    }
  }

}