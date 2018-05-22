Dartness

minimalist web middleware based micro framework

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

Roadmap:
* add regexp routes
* add logger
* add middleware to single route/routes list
* add nester routes
* add middleware chains

Full Example:
```dart
import 'package:dartness/dartness.dart';
  
void main() {
 
  final app = new Dartness();
  
  app.use((Context context) async {
    // will be called first
  }, catchError: false);
  
  app.use((Context context) async {
    // will be called second
    // catchError = false by dedault
    throw new Error(); // will be called first middleware with catchError = true 
  });
  
  final router = new Router();
  
  router.get('/:param1/:param2/:param3', (Context context) async {
    // context.req.params = {'param1': 'value', 'param2': 'value2', 'param3': 'value3'}
    print (context.req.params.toString());
  }); 
  
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