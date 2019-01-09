import 'dart:async';
import 'dart:mirrors';

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

class Callable {
  String _type = Types.function;
  // function properties
  Mirror _callable;
  bool catchError = false;
  // object properties
  Symbol _method;
  List<Argument> arguments = <Argument>[];

  Callable.function(Function callable, {this.catchError = false}) {
    _type = Types.function;
    _callable = reflect(callable);
    final ClosureMirror caller = _callable;
    caller.function.parameters.forEach((ParameterMirror p){
      final name = MirrorSystem.getName(p.simpleName);
      final type = MirrorSystem.getName(p.type.simpleName);
      arguments.add(new Argument(name, p.simpleName, type, p.type.simpleName));
    });
  }

  Callable.method(Mirror object, Symbol method, {this.catchError = false}) {
    _type = Types.method;
    _callable= object;
    _method = method;
    final InstanceMirror obj = _callable;
    obj.type.instanceMembers.forEach((key, value) {
      if (key == method) {
        value.parameters.forEach((p) {
          final name = MirrorSystem.getName(p.simpleName);
          final type = MirrorSystem.getName(p.type.simpleName);
          arguments.add(new Argument(name, p.simpleName, type, p.type.simpleName));
        });
      }
    });
  }

  Future<void> call(Context context) async { 
    if (_type == Types.function) {
      return _callFunction(context);
    }
    if (_type == Types.method) {
      return _callMethod(context);
    }
  }

  Future<Object> _callFunction(Context context) async {
    final ClosureMirror caller = _callable;
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

  Future<Object> _callMethod(Context context) async {
    if (_callable is InstanceMirror) {
      final InstanceMirror obj = _callable;
      final args = <dynamic>[];
      arguments.forEach((arg) {
        if (arg.type == 'Context') {
          args.add(context);
        }
        if (context.req.params.keys.contains(arg.name)) {
          args.add(context.req.params[arg.name]);
        }
      });
      return obj.invoke(_method, args);
    }
    return null;
  }
}
