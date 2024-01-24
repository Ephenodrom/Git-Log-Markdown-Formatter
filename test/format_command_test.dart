import 'package:args/args.dart';
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
- Prepare release 5.7.0 (Commit)[https://github.com/Ephenodrom/Dart-Basic-Utils/commit/6a5034927857a08f3bdf5a177529e361179f6dab] by Ephenodrom
- Merge pull request #105 from Nikoo00o/master (#105)[https://github.com/Ephenodrom/Dart-Basic-Utils/issues/105] (Commit)[https://github.com/Ephenodrom/Dart-Basic-Utils/commit/42e43ce8cd8efbc05a604ff34c2f43f8f1846536] by Ephenodrom
- Added the new "notBefore" parameter to the "generateSelfSignedCertificate" method to enable custom certificate validity. Also implemented a small validity test. (Commit)[https://github.com/Ephenodrom/Dart-Basic-Utils/commit/7aebce4400694508e2422a10b3caeac8718ab2a5] by Nikoo00o
- Merge pull request #101 from romgrm/master (#101)[https://github.com/Ephenodrom/Dart-Basic-Utils/issues/101] (Commit)[https://github.com/Ephenodrom/Dart-Basic-Utils/commit/e03ba499fd3238879ca3f2f2badf7457d61b0e7f] by Ephenodrom
- Merge branch 'feature-impl-ecdsa-pkcs8-converting' (Commit)[https://github.com/Ephenodrom/Dart-Basic-Utils/commit/f2d9429a6bd955d12c2d82d481a46547cca51ccf] by romgrm
''';

  var log2 = '''
s=Merge branch 'develop';H=70426ddbc0eafb0d360de225f5558bca1bb404dc;an=group_1_bot_abcde
s=Update versions for release;H=cac4d0a7c2ac58c841c249fa8e1fdb4295eee6ed;an=group_1_bot_abcde
s=Merge branch 'JIRA-2' into 'develop';H=aa1114f4d27a049ac4e01fa78402eee965a1528a;an=Ephenodrom
s=Update .gitlab-ci.yml;H=c491eb38b129b85a21e6482c8e7e7a8cdd02e03a;an=Ephenodrom
s=Update for next development version;H=7d5cfa5a997bc9b415bb906fc6380a0118f24aed;an=group_1_bot_abcde
s=Merge tag '1.64.0' into develop;H=9a3370fc25c4931a7d3d1861de4546ade29a92e9;an=group_1_bot_abcde
''';

  var expected2 = '''
# Release test_maven (1.0.0)
- Merge branch 'develop' (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/70426ddbc0eafb0d360de225f5558bca1bb404dc] by group_1_bot_abcde
- Update versions for release (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/cac4d0a7c2ac58c841c249fa8e1fdb4295eee6ed] by group_1_bot_abcde
- Merge branch 'JIRA-2' into 'develop' (JIRA-2)[https://jira.com/browse/JIRA-2] (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/aa1114f4d27a049ac4e01fa78402eee965a1528a] by Ephenodrom
- Update .gitlab-ci.yml (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/c491eb38b129b85a21e6482c8e7e7a8cdd02e03a] by Ephenodrom
- Update for next development version (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/7d5cfa5a997bc9b415bb906fc6380a0118f24aed] by group_1_bot_abcde
- Merge tag '1.64.0' into develop (Commit)[https://gitlab.com/subgroup/test_maven/-/commit/9a3370fc25c4931a7d3d1861de4546ade29a92e9] by group_1_bot_abcde
''';

  test('test formatLines()', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.template = "%s %H by %an";
    var markdown = cmd.formatLines(log1.split("\n"));
    expect(markdown, expected1);
  });

  test('test formatLines() 2', () {
    var cmd = FormatCommand();

    cmd.cbu = "https://gitlab.com/subgroup/test_maven/-/commit/";
    cmd.ibu = "https://jira.com/browse/";
    cmd.issueType = "JIRA";
    cmd.template = "%s %H by %an";
    cmd.header = "# Release test_maven (1.0.0)";
    var markdown = cmd.formatLines(log2.split("\n"));
    print(markdown);
    expect(markdown, expected2);
  });
}
