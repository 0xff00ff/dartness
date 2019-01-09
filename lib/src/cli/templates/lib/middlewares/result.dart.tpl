import 'dart:async';
import 'dart:convert';
import 'package:dartness/dartness.dart';

class Result {

  static Future<void> success (Context context) async {
    final result = <String, Object>{
      'data': context.locals,
      'error': null,
    };

    if (context.locals.isNotEmpty) {
      context.res.write(jsonEncode(result));
    }
  }

  static Future<void> error (Context context) async {
    // send 422 response
    final result = <String, Object>{
      'data': null,
      'error': context.error.toString(),
    };
    context.res.statusCode = 422;
    context.res.write(jsonEncode(result));
  }
}
