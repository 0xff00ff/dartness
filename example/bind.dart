import 'package:dartness/dartness.dart';

class A {
  @Get('/a_get')
  void get(Context ctx) {
    ctx.res.write('a_get');
  }
}

void main() {
  final app = new Dartness();
  final route = new Router();

  route.bind(new A());

  app.use(route);
  app.listen(port: 3030);
}