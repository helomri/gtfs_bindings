import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/agency.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

class AgencyParser implements Parser {
  const AgencyParser();

  @override
  Map<String, bool> get listenedFiles => {'agency.txt': true};

  @override
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  }) async {
    return sourceDataset
      ..agencies = Agencies(
        resourceFile: availableFiles['agency.txt']!,
        data: await ListCSVFile.parse(
          availableFiles['agency.txt']!,
          Agencies.staticFieldDefinitions,
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
        ..agencies = Agencies(resourceFile: availableFiles['agency.txt']!);
}
