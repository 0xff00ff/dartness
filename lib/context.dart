import 'dart:io';

class Context {
  HttpRequest req;
  HttpResponse response;

  Context(HttpRequest request) {
    this.req = request;
    this.response = request.response;
  }
}