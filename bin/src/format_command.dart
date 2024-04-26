import 'dart:io';

import 'package:args/command_runner.dart';

import 'exception/git_exception.dart';

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
  String? authorRegex;
  String? noMerges = "false";
  bool filterDuplicates = false;

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
      'iBaseUrl',
      defaultsTo: null,
      help: "The base url to display the issue. Required if addIssueLink=true.",
    );
    argParser.addOption(
      'cBaseUrl',
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
        "REPLACE_ALL",
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
    argParser.addOption(
      'excludeAuthor',
      defaultsTo: null,
      help:
          "The author to exclude. You can use * to perform a 'like' search. Example *bot*",
    );
    argParser.addOption(
      'noMerges',
      defaultsTo: "false",
      allowed: [
        "true",
        "false",
      ],
      help: "Ignore merge requests",
    );
    argParser.addOption(
      'filterDuplicates',
      defaultsTo: "false",
      allowed: [
        "true",
        "false",
      ],
      help: "Remove entries with already existing commit messages",
    );
  }

  @override
  void run() async {
    setUpArgs();
    validateArgs();
    var lines = await readFileContent();

    markdown = formatLines(lines);
    writeFileContent();
  }

  String formatLines(List<String> lines) {
    var alreadyAddedSubjects = <String>[];
    sb = StringBuffer();
    if (header != null) {
      sb!.writeln(header);
      sb!.writeln();
    }
    for (var l in lines) {
      if (l.isEmpty) {
        continue;
      }
      if (authorRegex != null) {
        RegExp regex = RegExp("an=($authorRegex?);");
        if (regex.hasMatch(l)) {
          continue;
        }
      }
      var formattedLine = template.toString();

      var m = getValuesFromLine(l);
      if (m["s"] != null) {
        if (filterDuplicates && alreadyAddedSubjects.contains(m["s"])) {
          continue;
        } else {
          alreadyAddedSubjects.add(m["s"]!);
        }
      }

      for (var s in m.keys) {
        switch (s) {
          case "s":
            formattedLine = processModoluS(m["s"], formattedLine, l);
            break;
          case "H":
            formattedLine = processModoluH(m["H"], formattedLine);
            break;
          case "an":
            formattedLine = formattedLine.replaceAll("%an", m["an"] ?? "NULL");
            break;
          case "ae":
            formattedLine = formattedLine.replaceAll("%ae", m["ae"] ?? "NULL");
            break;
          case "h":
            formattedLine = processModoluH(m["h"], formattedLine, value: "%h");
            break;
          case "T":
            formattedLine = formattedLine.replaceAll("%T", m["T"] ?? "NULL");
            break;
          case "t":
            formattedLine = formattedLine.replaceAll("%t", m["t"] ?? "NULL");
            break;
          case "P":
            formattedLine = formattedLine.replaceAll("%P", m["P"] ?? "NULL");
            break;
          case "p":
            formattedLine = formattedLine.replaceAll("%p", m["p"] ?? "NULL");
            break;
          case "ad":
            formattedLine = formattedLine.replaceAll("%ad", m["ad"] ?? "NULL");
            break;
          case "ar":
            formattedLine = formattedLine.replaceAll("%ar", m["ar"] ?? "NULL");
            break;
          case "cn":
            formattedLine = formattedLine.replaceAll("%cn", m["cn"] ?? "NULL");
            break;
          case "ce":
            formattedLine = formattedLine.replaceAll("%ce", m["ce"] ?? "NULL");
            break;
          case "cd":
            formattedLine = formattedLine.replaceAll("%cd", m["cd"] ?? "NULL");
            break;
          case "cr":
            formattedLine = formattedLine.replaceAll("%cr", m["cr"] ?? "NULL");
            break;
        }
      }
      sb!.writeln(formattedLine);
    }
    var content = "";
    if (footer == null) {
      content = sb!.toString();
    } else {
      sb!.writeln();
      sb!.writeln(footer);
      content = sb!.toString();
    }
    if (content.endsWith("\n")) {
      content = content.substring(0, content.length - 1);
    }
    return content;
  }

  Map<String, String?> getValuesFromLine(String l) {
    var m = <String, String?>{};
    var splitted = l.split(";");
    for (var s in splitted) {
      if (s.contains("=")) {
        var kV = s.split("=");
        if (kV.length == 2) {
          m.putIfAbsent(
            kV.elementAt(0),
            () => kV.elementAt(1).isEmpty ? null : kV.elementAt(1),
          );
        }
      }
    }

    return m;
  }

  void setUpArgs() {
    template = argResults!['template'] as String;
    cbu = argResults!['cBaseUrl'] as String?;
    ibu = argResults!['iBaseUrl'] as String?;
    addCommitLink = argResults!['addCommitLink'];
    addIssueLink = argResults!['addIssueLink'];
    issueType = argResults!['issueType'];
    header = argResults!['header'];
    footer = argResults!['footer'];
    file = argResults!['inputfile'];
    outputfile = argResults!['outputfile'];
    from = argResults!['from'] as String?;
    to = argResults!['to'] as String?;
    noMerges = argResults!['noMerges'] as String?;
    filterDuplicates =
        bool.tryParse(argResults!['filterDuplicates'] as String) ?? false;

    var value = argResults!['excludeAuthor'] as String?;
    if (value != null) {
      authorRegex = value.replaceAll("*", ".*");
    }
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
    if (noMerges == "true") {
      parameters.add("--no-merges");
    }

    parameters.add(
        '--format=H=%H;h=%h;T=%T;t=%t;P=%P;p=%p;an=%an;ae=%ae;ad=%ad;ar=%ar;cn=%cn;ce=%ce;cd=%cd;cr=%cr;s=%s');
    ProcessResult result = await Process.run(
      'git',
      parameters,
    );
    if (result.exitCode == 0) {
      var log = result.stdout as String;
      return log.split("\n");
    } else {
      var msg = result.stderr as String;
      throw GitException(msg, "git log");
    }
  }

  void writeFileContent() {
    if (outputfile != null) {
      var file = File(outputfile!);
      if (!file.existsSync()) {
        file.createSync();
      }
      file.writeAsString(markdown!);
    } else {
      print(markdown!);
    }
  }

  String processModoluS(String? m, String formattedLine, String line) {
    var issue = getIssue(line);
    var link = "";
    m ??= "NULL";
    if (issue != null && issue.length > 1) {
      link = issueType == "JIRA" ? issue : issue.substring(1);
    }
    if (issue != null && addIssueLink == "REPLACE") {
      var tmp = m.replaceAll(issue, "[$issue]($ibu$link)");
      formattedLine = formattedLine.replaceAll("%s", tmp);
    } else if (issue != null && addIssueLink == "REPLACE_ALL") {
      formattedLine = formattedLine.replaceAll("%s", "[$issue]($ibu$link)");
    } else if (issue != null && addIssueLink == "PREPEND") {
      formattedLine = formattedLine.replaceAll("%s", " [$issue]($ibu$link) $m");
    } else if (issue != null && addIssueLink == "APPEND") {
      formattedLine = formattedLine.replaceAll("%s", "$m [$issue]($ibu$link)");
    } else {
      formattedLine = formattedLine.replaceAll("%s", m);
    }
    return formattedLine;
  }

  String processModoluH(String? m, String formattedLine,
      {String value = "%H"}) {
    switch (addCommitLink) {
      case "REPLACE":
        formattedLine = formattedLine.replaceAll(value, "[Commit]($cbu$m)");
        break;
      case "PREPEND":
        formattedLine = formattedLine.replaceAll(value, "[Commit]($cbu$m) $m");
        break;
      case "APPEND":
        formattedLine = formattedLine.replaceAll(value, "$m [Commit]($cbu$m)");
        break;
      case "NONE":
      default:
        formattedLine = formattedLine.replaceAll(value, m ?? "NULL");
    }
    return formattedLine;
  }

  void validateArgs() {
    if (addCommitLink != "NONE" && cbu == null) {
      throw UsageException("Option cBaseUrl is required.", usage);
    }
    if (addIssueLink != "NONE" && ibu == null) {
      throw UsageException("Option iBaseUrl is required.", usage);
    }
  }
}
