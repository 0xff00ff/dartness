import 'package:dartness/dartness.dart';

class A {
  @Get('/')
  void index(Context c) {
    c.res.write('index');
  }

  @Get('/:param')
  void param(Context c, String param) {
    c.res.write(param);
  }
}

void main() {
  final app = new Dartness();
  final route = new Router();

  route.bind(new A());

  app.use(route);
  app.listen(port: 3030);
}
