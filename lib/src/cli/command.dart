import 'dart:io';
import 'dart:convert';

class Command {

  final List<String> _arguments;

  factory Command(List<String> args) {
    final command = args.first;
    final arguments = args.skip(1).toList();
    switch (command.toLowerCase()) {
      case 'init':
        return new Init(arguments);
      default:
        return new Command._internal(arguments);
    }
  }

  Command._internal(this._arguments);

  void run() {
    throw new UnsupportedError('Command not found');
  }
}

class Init extends Command {
  Init(List<String> args):super._internal(args);

  @override
  void run() async {
    print('running command!');
    print('command is: init');
    print('args are: ' + _arguments.join(', '));
    if (_arguments.isEmpty) {
      throw new UnsupportedError('Set a name for new project');
    }

    print('plan is:');

    final name = _arguments.first;
    final dir = Directory.current;
    final script = Platform.script;
    final sep = Platform.pathSeparator;

    print('directory is: ' + dir.path);
    final filedir = sep + script.pathSegments.take(script.pathSegments.length - 2).join(sep) + sep + 'lib' + sep + 'src' + sep + 'cli' + sep + 'templates' + sep;

    await Directory.fromUri(new Uri(path: dir.path + sep)).create(recursive: true);
    await Directory.fromUri(new Uri(path: dir.path + sep + 'lib/')).create(recursive: true);
    await Directory.fromUri(new Uri(path: dir.path + sep + 'lib/controllers/')).create(recursive: true);
    await Directory.fromUri(new Uri(path: dir.path + sep + 'lib/middlewares/')).create(recursive: true);

    await _copy(filedir + 'pubspec.yaml', dir.path + sep + 'pubspec.yaml', name);
    print('created pubspec.yaml');

    await _copy(filedir + 'analysis_options.yaml', dir.path + sep + 'analysis_options.yaml', name);
    print('created analysis_options.yaml');

    
    await _copy(filedir + 'server.dart.tpl', dir.path + sep + 'server.dart', name);
    print('created server.dart');
    
    await _copy(filedir + 'lib/routes.dart.tpl', dir.path + sep + 'lib/routes.dart', name);
    print('created lib/src/routes.dart');
    
    await _copy(filedir + 'lib/controllers/indexController.dart.tpl', dir.path + sep + 'lib/controllers/indexController.dart', name);
    print('created lib/src/controllers/index.dart');
    
    await _copy(filedir + 'lib/middlewares/result.dart.tpl', dir.path + sep + 'lib/middlewares/result.dart', name);
    print('created lib/src/middlewares/result.dart');
    
    await _copy(filedir + 'lib/middlewares/auth.dart.tpl', dir.path + sep + 'lib/middlewares/auth.dart', name);
    print('created lib/src/middlewares/auth.dart');
  }

  Future<void> _copy(String from, String to, String name) async {
    final file = File.fromUri(Uri.parse(from));
    final file2 = File.fromUri(Uri.parse(to)).openWrite();
    file.openRead()
      .transform(const Utf8Decoder())
      .transform(const LineSplitter())
      .listen((chunk) {
        chunk = chunk.replaceAll('{{projectName}}', name);
        file2.writeln(chunk);
      }, onDone: file2.close);
      
    return;
  }
}