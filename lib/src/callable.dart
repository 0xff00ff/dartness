import 'dart:async';
import 'dart:mirrors';

import 'package:dartness/src/context.dart';

class Callable {
  Function _callable;
  bool catchError = false;

  Callable(this._callable, {this.catchError = false});

  Future<void> call(Context context) async { 
    // _callable(context);

    // check caller with mirrors
    final ClosureMirror caller = reflect(_callable);

    final params = <dynamic>[];
    caller.function.parameters.forEach((ParameterMirror p){
      final name = MirrorSystem.getName(p.simpleName);
      final type = MirrorSystem.getName(p.type.simpleName);
      if (type == 'String') {
        if (context.req.params.containsKey(name)) {
          params.add(context.req.params[name]);
        } else {
          params.add('');
        }
      } else if (type == 'Context') {
        params.add(context);
      }
    });

    return caller.apply(params).reflectee;

  }
}
