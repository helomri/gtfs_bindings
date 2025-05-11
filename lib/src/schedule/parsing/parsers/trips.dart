import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/trips.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:trips.txt:2
/// {@end-tool}
class TripsParser implements Parser {
  /// Creates the parser.
  const TripsParser();

  @override
  Map<String, bool> get listenedFiles => {'trips.txt': true};

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) => sourceDataset..trips = Trips(resourceFile: availableFiles['trips.txt']!);
}
