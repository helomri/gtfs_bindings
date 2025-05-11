import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
///
/// This dataset can be loaded from a URL.
class DownloadableDataset extends GtfsDataset {
  /// The URL from which we download and read the dataset.
  final Uri uri;

  /// Creates the dataset.
  DownloadableDataset(this.uri);

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) async =>
      throw UnimplementedError(
        'Building datasets from by downloading them is not supported.',
      );
}
