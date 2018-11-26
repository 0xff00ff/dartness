import 'package:dartness/src/httpMethod.dart';

class Route {
  final String path;
  final String method;

  const Route(this.method, this.path);
}

class Get extends Route {
  const Get(String path): super(HttpMethod.get, path);
}

class Post extends Route {
  const Post(String path): super(HttpMethod.post, path);
}

class Patch extends Route {
  const Patch(String path): super(HttpMethod.patch, path);
}

class Put extends Route {
  const Put(String path): super(HttpMethod.put, path);
}

class Delete extends Route {
  const Delete(String path): super(HttpMethod.delete, path);
}