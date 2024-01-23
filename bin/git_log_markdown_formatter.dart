import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'src/format_command.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart git_log_markdown_formatter.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  CommandRunner("dgit", "A dart implementation of distributed version control.")
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
