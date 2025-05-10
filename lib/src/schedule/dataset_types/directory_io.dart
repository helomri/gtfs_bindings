import 'dart:async';
import 'dart:io';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:path/path.dart';

class DirectoryDataset extends GtfsDataset {
  final String directoryPath;

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
