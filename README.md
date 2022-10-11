Dartness

Minimalist, middleware based, web framework 

```dart
import 'package:dartness/dartness.dart';

void main() {

  final app = new Dartness();
  final router = new Router();
  
  router.get('/', (Context context) async => null);
  
  app.use(router);
  
  app.listen(port: 4040);

}
```

* uses middleware to create working flow
* simple 

Basic features:
* all parts is middleware
* errors can be captured on any step
* can be used simple dynamic routes
* router skips followed routes, if one was matched
* middleware can be grouped into modules

Roadmap:
* add binding routes to class methods
* add logger
* add nester routes
* add middleware chains
* add post/get parameters as arguments to routes
* function result as response
* use isolates

Full Example:
```dart
import 'package:dartness/dartness.dart';
  
void main() {
 
  final app = new Dartness();
  
  app.use((Context context) async {
    // will be called first
  }, catchError: false);
  
  final router = new Router();
  
  router.get('/:param1/:param2/:param3', (String param3, Context context, String param1, String param2) async {
    // you can use params direct trough function arguments, or get from
    // context.req.params = map {param1: 'value1', param2: value2, param3: value3}
    print('GET /' + context.req.params.toString());
  });
  
  router.get(r'/:blogId(\d+$)', (String blogId, Context context) {
    // will match on route: /some-blog-title-1234/
    // regex params can be get as function arguments as well
    context.req.params['blogId']; // 1234
  });

  router.get(r'/secret/:id', (int id, Context context){
    if (id != 2) {
      // will be called first middleware with catchError = true
      throw new Error(); 
    }
  })
  .useBefore((Context context) { /* will be called before route */ })
  .useAfter((Context context) { /* will be called after route */ });

  // simple ger request
  router.get('/', (Context context) async => null);
    
  // simple post request
  // uses body_parser to decode:
  // application/json 
  // application/x-www-form-urlencoded
  // multipart/form-data
  router.post('/', (Context context) async => print(context.req.body['message']['text']));
 
  app.use(router); // you can use more than one router
 
  app.use((Context context) async {
    // will be called only if error will be thrown
  }, catchError: true);
  
  app.listen(port: 4040);
}
```

Class bonding example
```dart
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
```