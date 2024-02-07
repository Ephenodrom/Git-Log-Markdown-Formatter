import 'package:args/command_runner.dart';

import '../meta.dart';

class VersionCommand extends Command {
  @override
  String get description => "Prints the current version";

  @override
  String get name => "version";

  VersionCommand();

  @override
  void run() async {
    print("Version ${meta['version']}");
  }
}
