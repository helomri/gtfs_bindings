import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/stops.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

// TODO: Add support for locations.geojson.
class StopsParser implements Parser {
  const StopsParser();

  @override
  Map<String, bool> get listenedFiles => {
    'stops.txt': true /*false*/ /*'locations.geojson': false*/,
  };

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..stops = Stops(
        resourceFile: availableFiles['stops.txt']!,
        data: await ListCSVFile.parse(
          availableFiles['stops.txt']!,
          Stops.staticFieldDefinitions,
          sourceDataset,
          evaluateIndividualFields: doChecks,
        ),
      );
  }

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) => sourceDataset..stops = Stops(resourceFile: availableFiles['stops.txt']!);
}
