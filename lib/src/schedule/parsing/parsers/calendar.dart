import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/calendar.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:calendar.txt:2
/// {@end-tool}
///
/// {@tool placedef}
/// gtfs:2Dataset Files:table:calendar_dates.txt:2
/// {@end-tool}
class CalendarParser implements Parser {
  /// Creates the parser.
  const CalendarParser();

  @override
  Map<String, bool> get listenedFiles => {
    'calendar.txt': false,
    'calendar_dates.txt': false,
  };

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) =>
      sourceDataset
        ..calendar = Calendar(
          regularCalendar:
              availableFiles.containsKey('calendar.txt')
                  ? RegularCalendar(
                    resourceFile: availableFiles['calendar.txt']!,
                  )
                  : null,
          occasionalCalendar:
              availableFiles.containsKey('calendar_dates.txt')
                  ? OccasionalCalendar(
                    resourceFile: availableFiles['calendar_dates.txt']!,
                  )
                  : null,
        );
}
