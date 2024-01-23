import 'dart:io';

import 'package:args/command_runner.dart';

class FormatCommand extends Command {
  StringBuffer? sb;
  String? markdown;

  String format = "";
  String fileName = "";
  String issueType = "";
  String? cbu = "";
  String? ibu = "";
  bool addIssueLink = true;
  bool addCommitLink = true;
  String? header;
  String? footer;

  @override
  String get description =>
      "Formats a git log output to reausable markdown text.";

  @override
  String get name => "format";

  FormatCommand() {
    argParser.addOption(
      'fname',
      mandatory: true,
    );
    argParser.addOption(
      'format',
      abbr: 'f',
      defaultsTo: "%s %H by %an",
      help: "foooo",
    );
    argParser.addOption(
      'issueType',
      abbr: 'i',
      defaultsTo: "JIRA",
      allowed: [
        "JIRA",
        "GITHUB",
        "GITLAB",
      ],
    );
    argParser.addOption(
      'ibu',
    );
    argParser.addOption(
      'cbu',
    );
    argParser.addOption(
      'addIssueLink',
      defaultsTo: "true",
    );
    argParser.addOption(
      'addCommitLink',
      defaultsTo: "true",
    );
    argParser.addOption(
      'header',
      defaultsTo: null,
    );
    argParser.addOption(
      'footer',
      defaultsTo: null,
    );
  }

/*%H: Commit hash (full).
%h: Abbreviated commit hash.
%T: Tree hash.
%t: Abbreviated tree hash.
%P: Parent hashes.
%p: Abbreviated parent hashes.
%an: Author name.
%ae: Author email.
%ad: Author date (default format).
%ar: Author date, relative.
%cn: Committer name.
%ce: Committer email.
%cd: Committer date (default format).
%cr: Committer date, relative.
%s: Subject (commit message).
%b: Body (commit message).
%N: Newline.
*/

  @override
  void run() {
    setUpArgs();
    var lines = readFileContent();
    markdown = formatLines(lines);
    writeFileContent();
  }

  String formatLines(
    List<String> lines, {
    bool addCommitLink = true,
  }) {
    var splittedFormat = format.split(" ");
    sb = StringBuffer();
    var lb = StringBuffer();
    for (var l in lines) {
      if (l.isEmpty) {
        continue;
      }
      var m = getValuesFromLine(l);
      for (var s in splittedFormat) {
        switch (s) {
          case "%s":
            var subject = m["s"];
            lb.write(subject);
            if (addIssueLink) {
              var issue = getIssue(l);
              if (issue != null) {
                var link = issueType == "JIRA" ? issue : issue.substring(1);
                lb.write(" ($issue)[$ibu$link]");
              }
            }
            break;
          case "%H":
            var hash = m["H"];
            if (addCommitLink) {
              lb.write("(Commit)[$cbu$hash]");
            } else {
              lb.write(hash);
            }
            break;
          case "%an":
            lb.write(m["an"]);
            break;
          default:
            lb.write(s);
        }
        lb.write(" ");
      }
      sb!.writeln("- ${lb.toString().trim()}");
      lb.clear();
    }
    return sb.toString();
  }

  List<String> readFileContent() {
    return File(fileName).readAsLinesSync();
  }

  Map<String, String> getValuesFromLine(String l) {
    var m = <String, String>{};
    var splitted = l.split(";");
    for (var s in splitted) {
      var kV = s.split("=");
      m.putIfAbsent(
        kV.elementAt(0),
        () => kV.elementAt(1),
      );
    }

    return m;
  }

  void setUpArgs() {
    format = argResults!['format'] as String;
    cbu = argResults!['cbu'] as String;
    ibu = argResults!['ibu'] as String;
    addCommitLink = argResults!['addCommitLink'] == "true";
    addIssueLink = argResults!['addIssueLink'] == "true";
    issueType = argResults!['issueType'];
    header = argResults!['header'];
    footer = argResults!['footer'];
    fileName = argResults!['fileName'];
  }

  String? getIssue(String l) {
    RegExp regex;
    switch (issueType) {
      case "JIRA":
        regex = RegExp("r'((?<!([A-Za-z]{1,10})-?)[A-Z]+-\d+)");
        break;
      default:
        regex = RegExp(r'(#\d+)');
    }

    RegExpMatch? match = regex.firstMatch(l);

    if (match == null) {
      return null;
    }
    var issue = match.group(1);
    if (issue == null) {
      return null;
    }
    return issue;
  }

  void writeFileContent() {
    File(fileName).writeAsString(markdown!);
  }
}
