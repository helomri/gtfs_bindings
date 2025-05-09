class MissingFileException implements Exception {
  final String fileName;

  const MissingFileException(this.fileName);

  @override
  String toString() => 'Missing file in dataset: $fileName';
}
