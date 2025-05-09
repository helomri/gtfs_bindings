import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

abstract class Parser {
  const Parser();

  /// All of the files to provide to a parser with whether they are required.
  /// If a file is conditionally forbidden/required, use [false] and do your
  /// checks in [parseAndApplyFromAvailable]
  Map<String, bool> get listenedFiles;

  /// Gives the information necessary to be able to query the dataset later about
  /// data that would be loaded on-demand (the exact same one that would have
  /// been loaded in memory by [parseAndApplyFromAvailable].)
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  );

  /// Extracts ALL of the data contained inside [availableFiles] and adds those
  /// models right into [sourceDataset].
  ///
  /// Used to test/benchmark the file, SHOULD NOT BE USED FOR THE USER (excepted
  /// from "essential" data which is lite and required often enough to quickly
  /// be loaded in memory).
  FutureOr<GtfsDataset> parseAndApplyFromAvailable(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles, {
    bool doChecks = false,
  });
}
