import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

class RawDataset extends GtfsDataset {
  final List<FileOpener> fileOpeners;

  RawDataset({required this.fileOpeners});

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) => fileOpeners;
}
