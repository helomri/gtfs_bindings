import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/routes.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// TODO: route_networks
class RoutesParser implements Parser {
  const RoutesParser();

  @override
  Map<String, bool> get listenedFiles => {
    'routes.txt': true,
    'route_networks.txt': false,
  };

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..routes = Routes(
        resourceFile: availableFiles['routes.txt']!,
        data: await ListCSVFile.parse(
          availableFiles['routes.txt']!,
          Routes.staticFieldDefinitions,
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
        ..routes = Routes(resourceFile: availableFiles['routes.txt']!);
}
