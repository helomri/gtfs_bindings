import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
///
/// This dataset can be loaded from a list of [FileOpener]s.
class RawDataset extends GtfsDataset {
  /// The file openers from which read the dataset.
  final List<FileOpener> fileOpeners;

  /// Creates the dataset.
  RawDataset({required this.fileOpeners});

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) => fileOpeners;
}
