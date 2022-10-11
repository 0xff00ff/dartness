import 'dart:io';
import 'dart:async';
import 'package:mapper/mapper.dart';
import 'package:logging/logging.dart';

class ContextRequest {
  final HttpRequest _req;
  Map<String, dynamic> body = <String, dynamic>{};
  Map<String, String> params = {};

  ContextRequest(this._req);

  HttpRequest get request => _req;
  String get method => _req.method;
  Uri get requestedUri => _req.requestedUri;
  HttpHeaders get headers => _req.headers;

  T getPostAs<T>() => decode<T>(body)!;
}

class ContextResponse {
  HttpResponse res;
  bool _closed = false;
  bool _statusCodeChanged = false;

  ContextResponse(this.res) {
    res.statusCode = 404;
  }

  HttpResponse get response => res;
  HttpHeaders get headers => res.headers;

  int get statusCode => res.statusCode;

  set statusCode(int code) {
    res.statusCode = code;
    _statusCodeChanged = true;
  }

  void write(Object obj) {
    if (!_statusCodeChanged) {
      res.statusCode = 200;
      _statusCodeChanged = true;
    }
    res.write(obj);
  }

  void writeJson(Object obj) {
    if (!_statusCodeChanged) {
      res.statusCode = 200;
      _statusCodeChanged = true;
    }
    res.write(obj);
  }

  Future<dynamic> close() {
    if (!_closed) {
      _closed = true;
      return res.close();
    }

    return Future<dynamic>.value(null);
  }

  bool isClosed() => _closed;
}

class Context {
  ContextRequest req;
  ContextResponse res;
  Logger? log;

  Map<String, Object> locals = {};

  Context(HttpRequest request, {Logger? logger = null}):
        req = new ContextRequest(request), res = new ContextResponse(request.response) {
    if (logger != null) {
      log = logger;
    }
  }

  Error? error;
}
