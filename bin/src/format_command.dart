import 'dart:io';

import 'package:args/command_runner.dart';

class FormatCommand extends Command {
  StringBuffer? sb;
  String? markdown;

  String template = "";
  String? file = "";
  String? outputfile;
  String issueType = "";
  String? cbu;
  String? ibu;
  String addIssueLink = "REPLACE";
  String addCommitLink = "REPLACE";
  String? header;
  String? footer;
  String? from;
  String? to;

  @override
  String get description =>
      "Formats a git log output to reausable markdown text.";

  @override
  String get name => "format";

  FormatCommand() {
    argParser.addOption(
      'inputfile',
      abbr: 'i',
      help: "The file containing the git log output.",
      hide: true,
    );
    argParser.addOption(
      'outputfile',
      abbr: 'o',
      help:
          "The file to write the markdown to. If left, the markdown will override the file containing the git log.",
    );
    argParser.addOption(
      'template',
      abbr: 't',
      defaultsTo: "- %s %H by %an",
      help:
          "The template to use for each line. Supported placeholders are: %s, %H, %an.",
    );
    argParser.addOption(
      'issueType',
      defaultsTo: "JIRA",
      allowed: [
        "JIRA",
        "GITHUB",
        "GITLAB",
      ],
      help: "The issue management software you use.",
    );
    argParser.addOption(
      'issueBaseUrl',
      defaultsTo: null,
      help: "The base url to display the issue. Required if addIssueLink=true.",
    );
    argParser.addOption(
      'commitBaseUrl',
      defaultsTo: null,
      mandatory: false,
      help:
          "The base url to display the commit. Required if addCommitLink=true.",
    );
    argParser.addOption(
      'addIssueLink',
      defaultsTo: "REPLACE",
      allowed: [
        "NONE",
        "REPLACE",
        "PREPEND",
        "APPEND",
      ],
      help: "To add a issue link at the end of the subject (%s).",
    );
    argParser.addOption(
      'addCommitLink',
      defaultsTo: "REPLACE",
      allowed: [
        "NONE",
        "REPLACE",
        "PREPEND",
        "APPEND",
      ],
      help: "Whether to replace the commit hash as a link to the commit.",
    );
    argParser.addOption(
      'header',
      defaultsTo: null,
      help: "String to append at the beginning of the markdown.",
    );
    argParser.addOption(
      'footer',
      defaultsTo: null,
      help: "String to append at the end of the markdown.",
    );
    argParser.addOption(
      'from',
      defaultsTo: null,
      help: "The tag to start from",
    );
    argParser.addOption(
      'to',
      defaultsTo: null,
      help: "The tag until to include commits",
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
  void run() async {
    setUpArgs();
    validateArgs();
    var lines = await readFileContent();

    markdown = formatLines(lines);
    writeFileContent();
  }

  String formatLines(List<String> lines) {
    var splittedFormat = template.split(" ");
    sb = StringBuffer();
    if (header != null) {
      sb!.writeln(header);
      sb!.writeln();
    }
    var lb = StringBuffer();
    for (var l in lines) {
      if (l.isEmpty) {
        continue;
      }
      var m = getValuesFromLine(l);
      for (var s in splittedFormat) {
        switch (s) {
          case "%s":
            processModoluS(m["s"], lb, l);
            break;
          case "%H":
            processModoluUpperH(m["H"], lb);
            break;
          case "%an":
            processModoluAn(m["an"], lb);
            break;
          default:
            lb.write(s);
        }
        lb.write(" ");
      }

      sb!.writeln(lb.toString().trim());
      lb.clear();
    }
    if (footer == null) {
      return sb!.toString();
    } else {
      sb!.writeln();
      sb!.writeln(footer);
      return sb!.toString();
    }
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
    template = argResults!['template'] as String;
    cbu = argResults!['commitBaseUrl'] as String?;
    ibu = argResults!['issueBaseUrl'] as String?;
    addCommitLink = argResults!['addCommitLink'];
    addIssueLink = argResults!['addIssueLink'];
    issueType = argResults!['issueType'];
    header = argResults!['header'];
    footer = argResults!['footer'];
    file = argResults!['inputfile'];
    outputfile = argResults!['outputfile'];
  }

  String? getIssue(String l) {
    RegExp regex;
    switch (issueType) {
      case "JIRA":
        regex = RegExp(r'((?<!([A-Za-z]{1,10})-?)[A-Z]+-\d+)');
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

  Future<List<String>> readFileContent() async {
    if (file != null) {
      return File(file!).readAsLinesSync();
    }
    var parameters = <String>[];
    parameters.add("log");
    if (from != null && to != null) {
      parameters.add("$from..$to");
    } else if (from != null && to == null) {
      parameters.add("$from..");
    } else if (from == null && to != null) {
      parameters.add("..$to");
    }
    parameters.add(
        '--format=H=%H;h=%h;T=%T;t=%t;P=%P;p=%p;an=%an;ae=%ae;ad=%ad;ar=%ar;cn=%cn;ce=%ce;cd=%cd;cr=%cr;s=%s;b=%b"');
    ProcessResult result = await Process.run(
      'git',
      parameters,
    );
    if (result.exitCode == 0) {
      var log = result.stdout as String;
      return log.split("\n");
    } else {
      throw UsageException("Could not generate git log", usage);
    }
  }

  void writeFileContent() {
    if (outputfile != null) {
      File(outputfile!).writeAsString(markdown!);
    } else {
      print(markdown!);
    }
  }

  void processModoluS(String? m, StringBuffer lb, String line) {
    var issue = getIssue(line);
    var link = "";
    if (issue != null && issue.length > 1) {
      link = issueType == "JIRA" ? issue : issue.substring(1);
    }
    if (issue != null && addIssueLink == "REPLACE") {
      lb.write("[$issue]($ibu$link)");
    } else if (issue != null && addIssueLink == "PREPEND") {
      lb.write(" [$issue]($ibu$link) $m");
    } else if (issue != null && addIssueLink == "APPEND") {
      lb.write("$m [$issue]($ibu$link)");
    } else {
      lb.write(m);
    }
  }

  void processModoluUpperH(String? m, StringBuffer lb) {
    switch (addCommitLink) {
      case "REPLACE":
        lb.write("[Commit]($cbu$m)");
        break;
      case "PREPEND":
        lb.write("[Commit]($cbu$m) $m");
        break;
      case "APPEND":
        lb.write("$m [Commit]($cbu$m)");
        break;
      case "NONE":
      default:
        lb.write(m);
    }
  }

  void processModoluAn(String? m, StringBuffer lb) {
    lb.write(m);
  }

  void validateArgs() {
    if (addCommitLink != "NONE" && cbu == null) {
      throw UsageException("Option commitBaseUrl is required.", usage);
    }
    if (addIssueLink != "NONE" && ibu == null) {
      throw UsageException("Option issueBaseUrl is required.", usage);
    }
  }
}
