import 'dart:io';

void main() {
  try {
    // Read the pubspec.yaml file
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();

    // Use a regular expression to extract the version
    final versionMatch = RegExp(r'version: (.+)').firstMatch(pubspecContent);

    // Check if a match was found
    if (versionMatch != null) {
      final version = versionMatch.group(1)!;
      print(version);
    } else {
      print('Version not found in pubspec.yaml');
    }
  } catch (e) {
    print('Error: $e');
  }
}
