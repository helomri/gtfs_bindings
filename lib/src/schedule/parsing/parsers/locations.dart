import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/locations.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:locations.geojson:2
/// {@end-tool}
class LocationsParser extends Parser {
  /// Creates the parser.
  const LocationsParser();

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) {
    if (!availableFiles.containsKey('locations.geojson')) {
      return sourceDataset..locations = null;
    }

    return sourceDataset
      ..locations = Locations(
        resourceFile: availableFiles['locations.geojson']!,
      );
  }

  @override
  Map<String, bool> get listenedFiles => {'locations.geojson': false};
}
