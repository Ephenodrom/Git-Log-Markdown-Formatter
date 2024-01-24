import 'dart:io';

import 'package:args/command_runner.dart';

import 'src/format_command.dart';

void main(List<String> arguments) {
  CommandRunner("glmf", "A simple git log to markdown formatter")
    ..addCommand(FormatCommand())
    ..run(arguments).catchError(
      (error) {
        if (error is! UsageException) throw error;
        // Print usage information if an invalid argument was provided.
        print(error.message);
        exit(64); // Exit code 64 indicates a usage error.
      },
    );
}
