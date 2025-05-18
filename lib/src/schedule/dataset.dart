import 'dart:async';

import 'package:gtfs_bindings/schedule.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/agency.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/calendar.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/fares.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/routes.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/stops.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parsers/trips.dart';
import 'package:logging/logging.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
abstract class GtfsDataset {
  /// The base logger for all GTFS Schedule related debug info.
  static final baseLogger = Logger('GtfsBinding');

  /// The list of agencies.
  late Agencies agencies;

  /// The list of routes.
  late Routes routes;

  /// The list of trips.
  late Trips trips;

  /// The list of stops.
  late Stops stops;

  /// The list of stop times.
  late StopTimes stopTimes;

  /// The calendar of service rules.
  late Calendar calendar;

  /// The list of fares.
  late Fares fares;

  /// The list of the files contained inside the dataset.
  late List<String> fileNameList;

  /// Gets all the files reader factories depending on the method used to open
  /// them.
  FutureOr<List<FileOpener>> getSource({String? tempDir});

  static final _logger = Logger('GtfsBinding.DatasetPiper');

  /// Loads [bindings] in memory.
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

  /// A selection of the most frequently-accessed bindings which are still generally
  /// small in size.
  List<LazyBinding> get primaryBindings => [
    agencies,
    routes,
    if (calendar.regularCalendar != null) calendar.regularCalendar!,
    if (calendar.occasionalCalendar != null) calendar.occasionalCalendar!,
    ...fares.bindings,
  ];

  /// A list of all the bindings available in the dataset.
  List<LazyBinding> get bindings => [
    agencies,
    routes,
    trips,
    stops,
    stopTimes,
    if (calendar.regularCalendar != null) calendar.regularCalendar!,
    if (calendar.occasionalCalendar != null) calendar.occasionalCalendar!,
    ...fares.bindings,
  ];

  /// All the parsers that create bindings by detected necessary files.
  final List<Parser> parsers = const [
    AgencyParser(),
    StopsParser(),
    RoutesParser(),
    StopTimesParser(),
    TripsParser(),
    CalendarParser(),
    // Must be after RoutesParser.
    FaresParser(),
  ];

  /// Retrieves the [FileOpener] via [getSource] and uses the [parsers] to
  /// create load the bindings in the dataset.
  ///
  /// We "pipe" the raw files to their corresponding binding(s).
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
