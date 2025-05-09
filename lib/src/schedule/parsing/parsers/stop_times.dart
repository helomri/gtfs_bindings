import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

class StopTimesParser implements Parser {
  const StopTimesParser();

  @override
  Map<String, bool> get listenedFiles => {'stop_times.txt': true};

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..stopTimes = StopTimes(
        resourceFile: availableFiles['stop_times.txt']!,
        data: await ListCSVFile.parse(
          availableFiles['stop_times.txt']!,
          StopTimes.staticFieldDefinitions,
          sourceDataset,
          evaluateIndividualFields: doChecks,
        ),
      );
  }

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) =>
      sourceDataset
        ..stopTimes = StopTimes(
          resourceFile: availableFiles['stop_times.txt']!,
        );
}
