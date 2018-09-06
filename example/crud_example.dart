import 'package:dartness/dartness.dart';

class CrudService {
  int _counter = 1;
  final Map<String, Object> _data = {};

  String insert(Object data) {
    final index = _counter.toString();
    _counter++;
    _data[index] = data;
    return index;
  }

  Map<String, Object> getAll() => _data;

  Object getOne(String key) {
    if (_data.containsKey(key)) {
      return _data[key];
    }
    return null;
  }

  bool delete(String id) {
    if (_data.containsKey(id)) {
      _data.remove(id);
      return true;
    }
    return false;
  }
}

void main() {
  final app = new Dartness();

  final router = new Router();

  final service = new CrudService();

  router.get('/', (Context ctx) {
    print('GET /');
    ctx.locals['data'] = service.getAll();
  });

  router.get('/name', (Context ctx) {
    print('GET /name!!');
    //ctx.locals['data'] = service.getOne(0);
  });

  router.get('/:id', (Context ctx) {
    final id = ctx.req.params['id'];
    print('GET /' + id);
    ctx.locals['data'] = service.getOne(id);
  });

  router.delete('/:id', (Context ctx) {
    final id = ctx.req.params['id'];
    print('DELETE /' + id);
    ctx.locals['data'] = service.delete(id);
  });
  router.post('/', (Context ctx) {
    print('POST /');
    if (ctx.req.body.containsKey('data')) {
      final id = service.insert(ctx.req.body['data']);
      ctx.locals['data'] = id;
    } else {
      throw new Error();
    }
  });

  app.use(router);

  /*
  app.use((Context ctx){
    ctx.res.write(jsonEncode(ctx.locals));
  });
  */

  app.use((Context ctx) {
    ctx.res.write('oops, an error occured.');
  }, catchError: true);

  app.listen();
}
