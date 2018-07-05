import 'dart:async';

import 'package:dartness/src/context.dart';

class Callable {
  Function _callable;
  bool catchError = false;

  Callable(this._callable, {this.catchError = false});

  Future<void> call(Context context) async => _callable(context);
}
