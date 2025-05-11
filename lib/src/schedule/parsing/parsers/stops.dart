import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/stops.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

// TODO: Add support for locations.geojson.
/// {@tool placedef}
/// gtfs:2Dataset Files:table:stops.txt:2
/// {@end-tool}
class StopsParser implements Parser {
  /// Creates the parser.
  const StopsParser();

  @override
  Map<String, bool> get listenedFiles => {
    'stops.txt': true /*false*/ /*'locations.geojson': false*/,
  };

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) => sourceDataset..stops = Stops(resourceFile: availableFiles['stops.txt']!);
}
