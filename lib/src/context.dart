import 'dart:io';
import 'dart:async';

class ContextRequest {

  HttpRequest _req;
  Map<String, dynamic> body = <String, dynamic>{};

  ContextRequest(this._req);

  HttpRequest get request => _req;
  String get method => _req.method;
  Uri get requestedUri => _req.requestedUri;
  HttpHeaders get headers => _req.headers;

}

class ContextResponse {

  HttpResponse _res;
  bool _closed = false;

  ContextResponse(this._res);

  HttpResponse get response => _res;
  HttpHeaders get headers => _res.headers;

  void write(Object obj) => _res.write(obj);

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
  Map<String, String> uriParams = {};

  Map<String, Object> locals = {};

  Context(HttpRequest request) {

    req = new ContextRequest(request);
    res = new ContextResponse(request.response);
  }
}