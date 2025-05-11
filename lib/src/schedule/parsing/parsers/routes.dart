import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/routes.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

// TODO: route_networks
/// {@tool placedef}
/// gtfs:2Dataset Files:table:routes.txt:2
/// {@end-tool}
///
/// {@tool placedef}
/// gtfs:2Dataset Files:table:route_networks.txt:2
/// {@end-tool}
class RoutesParser implements Parser {
  /// Creates the parser.
  const RoutesParser();

  @override
  Map<String, bool> get listenedFiles => {
    'routes.txt': true,
    'route_networks.txt': false,
  };

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) =>
      sourceDataset
        ..routes = Routes(resourceFile: availableFiles['routes.txt']!);
}
