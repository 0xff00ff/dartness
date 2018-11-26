import 'package:dartness/dartness.dart';

void main() {
  final app = new Dartness();

  // middleware generates an error
  app.use((Context ctx) {
    throw Error();
  });

  // this middleware will newer be called, because of exception
  app.use((Context ctx) {
    ctx.res.write('all is good!');
  });

  // this middleware will be called only if an error will be thrown
  app.use((Context ctx) {
    ctx.res.write('oops, error!');
  }, catchError: true);

  app.listen(port: 3030);
}
