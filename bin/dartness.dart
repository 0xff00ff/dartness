import 'package:cli_util/cli_logging.dart';
import 'package:dartness/src/cli/command.dart';

void main(List<String> args) {
  final logger = new Logger.standard();
  final ansi = new Ansi(true);

  if (args.isEmpty) {
    logger.stdout('you can generate new project typing:');
    logger.stdout('dartness init <name> [path]');
    logger.stdout('  name - project name');
    logger.stdout('  path - project directory (can be ommited, by default .)');
    return;
  }

  try {
    final command = new Command(args);
    command.run();
  } catch (e) {
    logger.stderr(ansi.red + e.toString() + ansi.noColor);
  }
}
