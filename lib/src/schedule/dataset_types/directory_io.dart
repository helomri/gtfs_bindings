import 'dart:async';
import 'dart:io';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:path/path.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
///
/// This dataset can be loaded from a directory.
class DirectoryDataset extends GtfsDataset {
  /// The directory path from which we read the dataset.
  final String directoryPath;

  /// Creates the dataset.
  DirectoryDataset({required this.directoryPath});

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) {
    return Directory(directoryPath)
        .listSync()
        .whereType<File>()
        .map((e) => (stream: () => e.openRead(), name: basename(e.path)))
        .toList(growable: false);
  }
}
