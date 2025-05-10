import 'dart:async';

import 'package:gtfs_bindings/schedule.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/agency.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/calendar.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/routes.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/stops.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/trips.dart';
import 'package:logging/logging.dart';

abstract class GtfsDataset {
  static final baseLogger = Logger('GtfsBinding');

  late Agencies agencies;
  late Routes routes;
  late Trips trips;
  late Stops stops;
  late StopTimes stopTimes;
  late Calendar calendar;

  late List<String> fileNameList;

  FutureOr<List<FileOpener>> getSource({String? tempDir});

  static final _logger = Logger('GtfsBinding.DatasetPiper');

  static List<FieldDefinition> bindingToFieldDefinitions(LazyBinding binding) =>
      switch (binding.runtimeType) {
        Agencies _ => Agencies.staticFieldDefinitions,
        Routes _ => Routes.staticFieldDefinitions,
        Trips _ => Trips.staticFieldDefinitions,
        Stops _ => Stops.staticFieldDefinitions,
        StopTimes _ => Stops.staticFieldDefinitions,
        RegularCalendar _ => RegularCalendar.staticFieldDefinitions,
        OccasionalCalendar _ => OccasionalCalendar.staticFieldDefinitions,
        _ => [],
      };

  Future<void> populateList(
    List<LazyBinding> bindings, {
    bool doValidationChecks = false,
  }) async {
    for (final binding in bindings) {
      await binding.populateIfEmpty(
        doValidationChecks: doValidationChecks,
        dataset: this,
      );
    }
  }

  List<LazyBinding> get primaryBindings => [
    agencies,
    routes,
    if (calendar.regularCalendar != null) calendar.regularCalendar!,
    if (calendar.occasionalCalendar != null) calendar.occasionalCalendar!,
  ];

  List<LazyBinding> get bindings => [
    agencies,
    routes,
    trips,
    stops,
    stopTimes,
    if (calendar.regularCalendar != null) calendar.regularCalendar!,
    if (calendar.occasionalCalendar != null) calendar.occasionalCalendar!,
  ];

  final List<Parser> parsers = const [
    AgencyParser(),
    StopsParser(),
    RoutesParser(),
    StopTimesParser(),
    TripsParser(),
    CalendarParser(),
  ];

  Future<GtfsDataset> pipe({String? tempDir}) async {
    final dataset = await getSource(tempDir: tempDir);

    GtfsDataset currentDataset = this;

    final pipingWatch = Stopwatch();
    final totalWatch = Stopwatch();
    pipingWatch.start();
    totalWatch.start();
    for (final parser in parsers) {
      final files = <String, FileOpener>{};
      for (final fileEntry in parser.listenedFiles.entries) {
        if (dataset.any((element) => element.name == fileEntry.key) ||
            fileEntry.value) {
          files[fileEntry.key] = dataset.firstWhere(
            (element) => element.name == fileEntry.key,
            orElse: () => throw MissingFileException(fileEntry.key),
          );
        }
      }

      currentDataset = await parser.initializeDataStream(currentDataset, files);
      _logger.info(
        'Finished piping with ${parser.runtimeType} in ${pipingWatch.elapsedMilliseconds} ms',
      );
      pipingWatch.reset();
    }

    for (final binding in bindings) {
      await binding.prepare();
    }

    totalWatch.stop();
    _logger.info('Piping done in ${totalWatch.elapsedMilliseconds} ms');

    return currentDataset;
  }
}
