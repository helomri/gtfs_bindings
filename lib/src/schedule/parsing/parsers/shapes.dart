import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/shapes.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:shapes.txt:2
/// {@end-tool}
class ShapesParser extends Parser {
  /// Creates the parser.
  const ShapesParser();

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) {
    if (availableFiles.isEmpty) return sourceDataset..shapes = null;

    return sourceDataset
      ..shapes = Shapes(resourceFile: availableFiles.values.single);
  }

  @override
  Map<String, bool> get listenedFiles => {'shapes.txt': false};
}
