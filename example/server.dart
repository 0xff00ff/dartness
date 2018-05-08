import 'package:dartness/dartness.dart';
import 'package:dartness/context.dart';

void main() {
  Dartness app = new Dartness();
  app.use((Context context) {
    context.req.response.write('middleware 1');
    return context;
  });
  app.use((Context context) {
    context.req.response.write('middleware 2');
    return context;
  });
  app.listen();
}
