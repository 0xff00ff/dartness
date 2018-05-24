import 'package:dartness/dartness.dart';

void main() {
  final app = new Dartness();

  // add simple middleware that will catch all requests
  app.use((Context ctx) {
    ctx.res.write('Hello world');
  });

  app.listen();

}