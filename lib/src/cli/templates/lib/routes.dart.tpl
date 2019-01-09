import 'package:dartness/dartness.dart';

import 'package:{{projectName}}/controllers/indexController.dart';
import 'package:{{projectName}}/middlewares/result.dart';
import 'package:{{projectName}}/middlewares/auth.dart';


void routesBootstrap(Dartness app) {

  app.use(new CorsMiddleware.full());

  final router = new Router();

  router.get('/', IndexController.index);
  router.get('/secret', IndexController.secret)
    .useBefore(Auth.checkAuthorization);

  app.use(router);

  app.use(Result.success);
  app.use(Result.error, catchError: true);
}