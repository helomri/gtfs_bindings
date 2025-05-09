import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/calendar.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

class CalendarParser implements Parser {
  const CalendarParser();

  @override
  Map<String, bool> get listenedFiles => {
    'calendar.txt': false,
    'calendar_dates.txt': false,
  };

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..calendar = Calendar(
        regularCalendar:
            availableFiles.containsKey('calendar.txt')
                ? RegularCalendar(
                  resourceFile: availableFiles['calendar.txt']!,
                  data: await ListCSVFile.parse(
                    availableFiles['calendar.txt']!,
                    RegularCalendar.staticFieldDefinitions,
                    sourceDataset,
                    evaluateIndividualFields: doChecks,
                  ),
                )
                : null,
        occasionalCalendar:
            availableFiles.containsKey('calendar_dates.txt')
                ? OccasionalCalendar(
                  resourceFile: availableFiles['calendar_dates.txt']!,
                  data: await ListCSVFile.parse(
                    availableFiles['calendar_dates.txt']!,
                    OccasionalCalendar.staticFieldDefinitions,
                    sourceDataset,
                    evaluateIndividualFields: doChecks,
                  ),
                )
                : null,
      );
  }

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
