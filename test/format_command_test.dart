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

  test('test formatLines()', () {
    var cmd = FormatCommand();
    cmd.cbu = "https://github.com/Ephenodrom/Dart-Basic-Utils/commit/";
    cmd.ibu = "https://github.com/Ephenodrom/Dart-Basic-Utils/issues/";
    cmd.format = "%s %H by %an";
    var markdown = cmd.formatLines(log1.split("\n"));
    expect(markdown, expected1);
  });
}
