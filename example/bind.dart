import 'package:dartness/dartness.dart';

class A {
  @Get('/')
  void index(Context c) async {
    print('index');
    c.res.write('index');
  }

  @Get('/:param')
  Future<void> param(Context c, String param) async {
      print('param');
      c.res.write(param);
  }
}

void main() {
  final app = new Dartness(level: Level.ALL);
  final route = new Router();

  route.bind(new A());

  app.use(route);
  app.listen(port: 3030);
}
