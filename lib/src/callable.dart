import 'dart:async';
import 'dart:mirrors';

import 'package:dartness/dartness.dart';
import 'package:dartness/src/context.dart';

class Types {
  static const String function = 'function';
  static const String method = 'method';
}

class Argument {
  final String name;
  final Symbol symbolName;
  final String type;
  final Symbol symbolType;

  const Argument(this.name, this.symbolName, this.type, this.symbolType);
}

abstract class Callable {
  Future<void> call(Context context) async {
    throw new UnimplementedError('method call is unimplemented');
  }

  bool canCatchError() => false;
}

class MethodCallable implements Callable {
  final InstanceMirror instance;
  final MethodMirror _callable;
  bool catchError = false;
  List<Argument> arguments = <Argument>[];

  MethodCallable.init(this.instance, this._callable,
      {this.catchError = false}) {
    _callable.parameters.forEach((p) {
      final name = MirrorSystem.getName(p.simpleName);
      final type = MirrorSystem.getName(p.type.simpleName);
      arguments.add(new Argument(name, p.simpleName, type, p.type.simpleName));
    });
  }

  @override
  Future<dynamic> call(Context context) async {
    final args = <dynamic>[];
    arguments.forEach((arg) {
      if (arg.type == 'Context') {
        args.add(context);
      }
      if (context.req.params.keys.contains(arg.name)) {
        args.add(context.req.params[arg.name]);
      }
    });

    return instance.invoke(_callable.simpleName, args);
  }

  @override
  bool canCatchError() => catchError;
}

class FunctionCallable implements Callable {
  ClosureMirror? _callable;
  bool catchError = false;
  List<Argument> arguments = <Argument>[];

  FunctionCallable.init(Function callable, {this.catchError = false}) {
    final c = reflect(callable);
    if (c is ClosureMirror) {
      _callable = c;
      _callable?.function.parameters.forEach((ParameterMirror p) {
        final name = MirrorSystem.getName(p.simpleName);
        final type = MirrorSystem.getName(p.type.simpleName);
        arguments
            .add(new Argument(name, p.simpleName, type, p.type.simpleName));
      });
    }
  }

  @override
  Future<dynamic> call(Context context) async {
    final caller = _callable!;
    final args = <dynamic>[];
    arguments.forEach((arg) {
      if (arg.type == 'Context') {
        args.add(context);
      }
      if (context.req.params.keys.contains(arg.name)) {
        args.add(context.req.params[arg.name]);
      }
    });
    return caller.apply(args).reflectee;
  }

  @override
  bool canCatchError() => catchError;
}
