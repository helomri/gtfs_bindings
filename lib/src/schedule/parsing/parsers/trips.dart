import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/trips.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

class TripsParser implements Parser {
  const TripsParser();

  @override
  Map<String, bool> get listenedFiles => {'trips.txt': true};

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..trips = Trips(
        resourceFile: availableFiles['trips.txt']!,
        data: await ListCSVFile.parse(
          availableFiles.values.single,
          Trips.staticFieldDefinitions,
          sourceDataset,
          evaluateIndividualFields: doChecks,
        ),
      );
  }

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) => sourceDataset..trips = Trips(resourceFile: availableFiles['trips.txt']!);
}
