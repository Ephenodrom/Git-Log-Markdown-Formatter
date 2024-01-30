class GitException implements Exception {
  final String message;
  final String gitCommand;

  GitException(this.message, this.gitCommand);

  @override
  String toString() =>
      'Got the following error for call "$gitCommand" :\n$message';
}
