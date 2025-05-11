import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:stop_times.txt:2
/// {@end-tool}
class StopTimesParser implements Parser {
  /// Creates the parser.
  const StopTimesParser();

  @override
  Map<String, bool> get listenedFiles => {'stop_times.txt': true};

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
