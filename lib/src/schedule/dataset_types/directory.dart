import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

class DirectoryDataset extends GtfsDataset {
  final String directoryPath;

  DirectoryDataset({required this.directoryPath});

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) =>
      throw UnimplementedError(
        'Building datasets from a directory is not supported.',
      );
}
