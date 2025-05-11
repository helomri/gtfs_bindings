import 'dart:async';

import 'package:archive/archive.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
///
/// This dataset can be loaded from a ZIP archive.
class ArchiveDataset extends GtfsDataset {
  /// The archive from which we read the dataset.
  final Archive archive;

  /// Creates the dataset.
  ArchiveDataset({required this.archive});

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) => archive
      .map(
        (e) => (
          stream: () => Stream.value(e.getContent()!.toUint8List().cast<int>()),
          name: e.name,
        ),
      )
      .toList(growable: false);
}
