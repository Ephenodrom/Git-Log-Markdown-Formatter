import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:test/test.dart';

import '../bin/src/format_command.dart';

void main() {
  var log1 = '''
s=Prepare release 5.7.0;H=6a5034927857a08f3bdf5a177529e361179f6dab;an=Ephenodrom
s=Merge pull request #105 from Nikoo00o/master;H=42e43ce8cd8efbc05a604ff34c2f43f8f1846536;an=Ephenodrom
s=Added the new "notBefore" parameter to the "generateSelfSignedCertificate" method to enable custom certificate validity. Also implemented a small validity test.;H=7aebce4400694508e2422a10b3caeac8718ab2a5;an=Nikoo00o
s=Merge pull request #101 from romgrm/master;H=e03ba499fd3238879ca3f2f2badf7457d61b0e7f;an=Ephenodrom
s=Merge branch 'feature-impl-ecdsa-pkcs8-converting';H=f2d9429a6bd955d12c2d82d481a46547cca51ccf;an=romgrm
''';

  var expected1 = '''
- Prepare release 5.7.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/6a5034927857a08f3bdf5a177529e361179f6dab) by Ephenodrom
- Merge pull request #105 from Nikoo00o/master [#105](https://github.com/Ephenodrom/Dart-Basic-Utils/issues/105) [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/42e43ce8cd8efbc05a604ff34c2f43f8f1846536) by Ephenodrom
- Added the new "notBefore" parameter to the "generateSelfSignedCertificate" method to enable custom certificate validity. Also implemented a small validity test. [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/7aebce4400694508e2422a10b3caeac8718ab2a5) by Nikoo00o
- Merge pull request #101 from romgrm/master [#101](https://github.com/Ephenodrom/Dart-Basic-Utils/issues/101) [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/e03ba499fd3238879ca3f2f2badf7457d61b0e7f) by Ephenodrom
- Merge branch 'feature-impl-ecdsa-pkcs8-converting' [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/f2d9429a6bd955d12c2d82d481a46547cca51ccf) by romgrm''';

  var log2 = '''
s=Merge branch 'develop';H=70426ddbc0eafb0d360de225f5558bca1bb404dc;an=group_1_bot_abcde;
s=Update versions for release;H=cac4d0a7c2ac58c841c249fa8e1fdb4295eee6ed;an=group_1_bot_abcde;
s=Merge branch 'JIRA-2' into 'develop';H=aa1114f4d27a049ac4e01fa78402eee965a1528a;an=Ephenodrom;
s=Update .gitlab-ci.yml;H=c491eb38b129b85a21e6482c8e7e7a8cdd02e03a;an=Ephenodrom;
s=Update for next development version;H=7d5cfa5a997bc9b415bb906fc6380a0118f24aed;an=group_1_bot_abcde;
s=Merge tag '1.64.0' into develop;H=9a3370fc25c4931a7d3d1861de4546ade29a92e9;an=group_1_bot_abcde;
''';

  var expected2 = '''
# Release test_maven (1.0.0)

- Merge branch 'develop' [Commit](https://gitlab.com/subgroup/test_maven/-/commit/70426ddbc0eafb0d360de225f5558bca1bb404dc) by group_1_bot_abcde
- Update versions for release [Commit](https://gitlab.com/subgroup/test_maven/-/commit/cac4d0a7c2ac58c841c249fa8e1fdb4295eee6ed) by group_1_bot_abcde
- Merge branch 'JIRA-2' into 'develop' [JIRA-2](https://jira.com/browse/JIRA-2) [Commit](https://gitlab.com/subgroup/test_maven/-/commit/aa1114f4d27a049ac4e01fa78402eee965a1528a) by Ephenodrom
- Update .gitlab-ci.yml [Commit](https://gitlab.com/subgroup/test_maven/-/commit/c491eb38b129b85a21e6482c8e7e7a8cdd02e03a) by Ephenodrom
- Update for next development version [Commit](https://gitlab.com/subgroup/test_maven/-/commit/7d5cfa5a997bc9b415bb906fc6380a0118f24aed) by group_1_bot_abcde
- Merge tag '1.64.0' into develop [Commit](https://gitlab.com/subgroup/test_maven/-/commit/9a3370fc25c4931a7d3d1861de4546ade29a92e9) by group_1_bot_abcde''';

  var log3 = '''
H=fb4408cd36195d9097572fd198521051fd12d3cd;h=fb4408c;T=ac78827842adc11a6c8a9cfbdf69291414895046;t=ac78827;P=8b858e37b6b97bf1ec9f3d603cff9a714b5ca3c6 1efc56a4bbececbccbbcc08c7ac226bbe4d761da;p=8b858e3 1efc56a;an=Ephenodrom;ae=30625794+Ephenodrom@users.noreply.github.com;ad=Mon May 8 09:10:37 2023 +0200;ar=9 months ago;cn=GitHub;ce=noreply@github.com;cd=Mon May 8 09:10:37 2023 +0200;cr=9 months ago;s=Merge pull request #90 from arkare/master;b=Fix nextInt misuse
H=1efc56a4bbececbccbbcc08c7ac226bbe4d761da;h=1efc56a;T=ac78827842adc11a6c8a9cfbdf69291414895046;t=ac78827;P=8b858e37b6b97bf1ec9f3d603cff9a714b5ca3c6;p=8b858e3;an=arkare;ae=132831512+arkare@users.noreply.github.com;ad=Sun May 7 14:46:32 2023 +0000;ar=9 months ago;cn=arkare;ce=132831512+arkare@users.noreply.github.com;cd=Sun May 7 14:46:32 2023 +0000;cr=9 months ago;s=#89;b=
H=8b858e37b6b97bf1ec9f3d603cff9a714b5ca3c6;h=8b858e3;T=1a73796e879ef797365dfb46cd487de68804ce2e;t=1a73796;P=d52e8d557f994984c23a71627dd4069e60a50a72;p=d52e8d5;an=Ephenodrom;ae=foo@bar.de;ad=Fri Apr 14 18:25:37 2023 +0200;ar=10 months ago;cn=Ephenodrom;ce=foo@bar.de;cd=Fri Apr 14 18:25:37 2023 +0200;cr=10 months ago;s=Prepare release 5.5.4;b=
H=d52e8d557f994984c23a71627dd4069e60a50a72;h=d52e8d5;T=ec20d14e81624f370b5e76784e1529df9bec9319;t=ec20d14;P=8364e60d6bfa8986765d8b4e23bb7db84bed0562;p=8364e60;an=Ephenodrom;ae=foo@bar.de;ad=Tue Mar 28 08:34:20 2023 +0200;ar=10 months ago;cn=Ephenodrom;ce=foo@bar.de;cd=Tue Mar 28 08:34:20 2023 +0200;cr=10 months ago;s=Improve checkX509Signature;b=
H=8364e60d6bfa8986765d8b4e23bb7db84bed0562;h=8364e60;T=d790c88b025af638105daec2a2fdb13c0b987dcd;t=d790c88;P=aa02142d28d1f162c0ffe00dd85bf16db9023d4d;p=aa02142;an=Ephenodrom;ae=foo@bar.de;ad=Thu Mar 23 19:40:04 2023 +0100;ar=10 months ago;cn=Ephenodrom;ce=foo@bar.de;cd=Thu Mar 23 19:40:04 2023 +0100;cr=10 months ago;s=Prepare release 5.5.3;b=
H=aa02142d28d1f162c0ffe00dd85bf16db9023d4d;h=aa02142;T=c08405c7eba3b3106b247b496f5983756058dba5;t=c08405c;P=7d42992d3102979b9b7291675e1c43ec70936acc;p=7d42992;an=Ephenodrom;ae=foo@bar.de;ad=Mon Mar 20 19:40:47 2023 +0100;ar=10 months ago;cn=Ephenodrom;ce=foo@bar.de;cd=Mon Mar 20 19:40:47 2023 +0100;cr=10 months ago;s=Prepare release 5.5.2;b=
''';

  var expected3 = '''
- [#90](https://github.com/Ephenodrom/Dart-Basic-Utils/issues/90) [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/fb4408cd36195d9097572fd198521051fd12d3cd) by Ephenodrom
- [#89](https://github.com/Ephenodrom/Dart-Basic-Utils/issues/89) [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/1efc56a4bbececbccbbcc08c7ac226bbe4d761da) by arkare
- Prepare release 5.5.4 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/8b858e37b6b97bf1ec9f3d603cff9a714b5ca3c6) by Ephenodrom
- Improve checkX509Signature [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/d52e8d557f994984c23a71627dd4069e60a50a72) by Ephenodrom
- Prepare release 5.5.3 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/8364e60d6bfa8986765d8b4e23bb7db84bed0562) by Ephenodrom
- Prepare release 5.5.2 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/aa02142d28d1f162c0ffe00dd85bf16db9023d4d) by Ephenodrom''';

  var log4 = '''
s=Prepare release 5.7.0;H=6a5034927857a08f3bdf5a177529e361179f6dab;an=Ephenodrom;b=


''';

  var expected4 = '''
- Prepare release 5.7.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/6a5034927857a08f3bdf5a177529e361179f6dab) by Ephenodrom''';

  var expected5 = '''
- Merge branch 'JIRA-2' into 'develop' [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/aa1114f4d27a049ac4e01fa78402eee965a1528a) by Ephenodrom
- Update .gitlab-ci.yml [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/c491eb38b129b85a21e6482c8e7e7a8cdd02e03a) by Ephenodrom''';

  var expected6 = '''
- Prepare release 1.3.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/057591671b2480912eb8813e4cc1800a7b9159e9) by Ephenodrom
- Prepare release 1.2.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/5487684ade026e08cebef020d13e29750c470fd6) by Ephenodrom''';

  var log8 = '''
s=Prepare release 5.7.0;H=6a5034927857a08f3bdf5a177529e361179f6dab;an=Ephenodrom
s=JIRA-1234;H=e03ba499fd3238879ca3f2f2badf7457d61b0e7f;an=Ephenodrom
s=JIRA-1234;H=f2d9429a6bd955d12c2d82d481a46547cca51ccf;an=romgrm
s=JIRA-1234: Fix Unit Test;H=e03ba499fd3238879ca3f2f2badf7457d61b0e7f;an=Ephenodrom
s=JIRA-1234: Fix Typo;H=f2d9429a6bd955d12c2d82d481a46547cca51ccf;an=romgrm
''';

  var expected8 = '''
- Prepare release 5.7.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/6a5034927857a08f3bdf5a177529e361179f6dab) by Ephenodrom
- JIRA-1234 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/e03ba499fd3238879ca3f2f2badf7457d61b0e7f) by Ephenodrom
- JIRA-1234: Fix Unit Test [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/e03ba499fd3238879ca3f2f2badf7457d61b0e7f) by Ephenodrom
- JIRA-1234: Fix Typo [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/f2d9429a6bd955d12c2d82d481a46547cca51ccf) by romgrm''';

  test('test formatLines()', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    cmd.addIssueLink = "APPEND";
    var markdown = cmd.formatLines(log1.split("\n"));
    expect(markdown, expected1);
  });

  test('test formatLines() 2', () {
    var cmd = FormatCommand();

    cmd.cbu = "https://gitlab.com/subgroup/test_maven/-/commit/";
    cmd.ibu = "https://jira.com/browse/";
    cmd.issueType = "JIRA";
    cmd.addIssueLink = "APPEND";
    cmd.template = "- %s %H by %an";
    cmd.header = "# Release test_maven (1.0.0)";
    var markdown = cmd.formatLines(log2.split("\n"));
    expect(markdown, expected2);
  });

  test('test formatLines() 3', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    var markdown = cmd.formatLines(log3.split("\n"));
    expect(markdown, expected3);
  });

  test('test formatLines() 4', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    cmd.addIssueLink = "APPEND";
    var markdown = cmd.formatLines(log4.split("\n"));
    expect(markdown, expected4);
  });

  test('test formatLines() 5', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    cmd.addIssueLink = "APPEND";
    cmd.authorRegex = "Ephenodrom";
    var markdown = cmd.formatLines(log4.split("\n"));
    expect(markdown, "");
    cmd.authorRegex = ".*enodrom";
    markdown = cmd.formatLines(log4.split("\n"));
    expect(markdown, "");

    markdown = cmd.formatLines([
      "s=Prepare release 5.7.0;H=6a5034927857a08f3bdf5a177529e361179f6dab;an=;b="
    ]);
    expect(
      markdown,
      "- Prepare release 5.7.0 [Commit](https://github.com/Ephenodrom/Dart-Basic-Utils/commit/6a5034927857a08f3bdf5a177529e361179f6dab) by NULL",
    );
  });

  test('test formatLines() 6', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    cmd.addIssueLink = "APPEND";
    cmd.authorRegex = ".*bot.*";
    var markdown = cmd.formatLines(log2.split("\n"));
    expect(markdown, expected5);
  });

  test('test formatLines() 7', () async {
    var args = <String>[
      "format",
      "-otest_resources/test_notes.md",
      "--iBaseUrl=https://github.com/Ephenodrom/Dart-Basic-Utils/issues/",
      "--cBaseUrl=https://github.com/Ephenodrom/Dart-Basic-Utils/commit/",
      '--from=1.1.0',
      '--to=1.3.0',
    ];

    var runner = CommandRunner("glmf", "A simple git log to markdown formatter")
      ..addCommand(FormatCommand());
    await runner.run(args);
    await Future.delayed(Duration(seconds: 1));
    var testNotes = File("test_resources/test_notes.md");
    var content = testNotes.readAsStringSync();
    expect(expected6, content);
    testNotes.deleteSync();
  });

  test('test formatLines() 8 remove duplicates', () async {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "- %s %H by %an";
    cmd.addIssueLink = "APPEND";
    cmd.filterDuplicates = true;
    var markdown = cmd.formatLines(log8.split("\n"));
    expect(markdown, expected8);
  });
}
