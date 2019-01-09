import 'dart:io';
import 'dart:async';
import 'package:mapper/mapper.dart';

class ContextRequest {
  HttpRequest _req;
  Map<String, dynamic> body = <String, dynamic>{};
  Map<String, String> params = {};

  ContextRequest(this._req);

  HttpRequest get request => _req;
  String get method => _req.method;
  Uri get requestedUri => _req.requestedUri;
  HttpHeaders get headers => _req.headers;

  T getPostAs<T>() => decode<T>(body);
}

class ContextResponse {
  HttpResponse _res;
  bool _closed = false;
  bool _statusCodeChanged = false;

  ContextResponse(HttpResponse res) {
    _res = res;
    _res.statusCode = 404;
  }

  HttpResponse get response => _res;
  HttpHeaders get headers => _res.headers;

  int get statusCode => _res.statusCode;

  set statusCode (int code) {
    _res.statusCode = code;
    _statusCodeChanged = true;
  }

  void write(Object obj) {
    if (!_statusCodeChanged) {
      _res.statusCode = 200;
      _statusCodeChanged = true;
    }
    _res.write(obj);
  }

  Future<dynamic> close() {
    if (!_closed) {
      _closed = true;
      return _res.close();
    }

    return null;
  }

  bool isClosed() => _closed;
}

class Context {
  ContextRequest req;
  ContextResponse res;

  Map<String, Object> locals = {};

  Context(HttpRequest request) {
    req = new ContextRequest(request);
    res = new ContextResponse(request.response);
  }

  Object error;
}
