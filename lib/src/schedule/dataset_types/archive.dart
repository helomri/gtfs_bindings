import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

class ArchiveDataset extends GtfsDataset {
  final Archive archive;

  ArchiveDataset({required this.archive});

  @override
  FutureOr<List<FileOpener>> getSource({Directory? tempDir}) => archive
      .map(
        (e) => (
          stream: () => Stream.value(e.getContent()!.toUint8List().cast<int>()),
          name: e.name,
        ),
      )
      .toList(growable: false);
}
