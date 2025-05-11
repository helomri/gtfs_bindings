import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

/// The bridge between the [GtfsDataset] and the [LazyBinding]s.
abstract class Parser {
  /// Creates the parser.
  const Parser();

  /// All of the files to provide to a parser with whether they are required.
  /// If a file is conditionally forbidden/required, use [false] and do your
  /// checks in [initializeDataStream].
  Map<String, bool> get listenedFiles;

  /// Gives the information necessary to be able to query the dataset later about
  /// data that would be loaded .
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  );
}
