import 'package:dartness/dartness.dart';

void main() {
  final app = new Dartness();
  final router = new Router();
  // add simple middleware that will catch all requests
  app.use((Context context) async {
    context.res.write('m1');
  });

  router.get('/', (Context ctx) async => ctx.res.write('r1'));
  app.use(router);

  app.listen();

}