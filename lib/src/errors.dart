/// The exception that triggers when a dataset doesn't contain a file it is
/// supposed to have.
class MissingFileException implements Exception {
  /// The name of the missing file.
  final String fileName;

  /// Creates the exception.
  const MissingFileException(this.fileName);

  @override
  String toString() => 'Missing file in dataset: $fileName';
}
