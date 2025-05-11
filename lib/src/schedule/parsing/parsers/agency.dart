import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/agency.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

/// {@tool placedef}
/// gtfs:2Dataset Files:table:agency.txt:2
/// {@end-tool}
class AgencyParser implements Parser {
  /// Creates the parser.
  const AgencyParser();

  @override
  Map<String, bool> get listenedFiles => {'agency.txt': true};

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) =>
      sourceDataset
        ..agencies = Agencies(resourceFile: availableFiles['agency.txt']!);
}
