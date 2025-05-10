import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

class DownloadableDataset extends GtfsDataset {
  final Uri uri;

  DownloadableDataset(this.uri);

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) async =>
      throw UnimplementedError(
        'Building datasets from by downloading them is not supported.',
      );
}
