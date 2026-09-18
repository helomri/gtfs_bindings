import 'dart:async';

import 'package:archive/archive.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

/// The representation of a GTFS-Schedule dataset. It contains or can load all
/// the information contained inside a GTFS-dataset.
///
/// This dataset can be loaded from a URL.
///
/// **WARNING!**: Request in the Web are required to comply with CORS policies.
class DownloadableDataset extends GtfsDataset {
  static final _logger = Logger('GtfsBinding.DatasetDownloader');

  /// The URL from which we download and read the dataset.
  final Uri uri;

  /// Creates the dataset.
  DownloadableDataset(this.uri);

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) async {
    _logger.info('Downloading dataset...');
    final response = await MultipartRequest('GET', uri).send();
    
    final archive = ZipDecoder().decodeStream(
      InputMemoryStream(await response.stream.toBytes()),
    );

    _logger.info('Finished downloading dataset.');

    final archiveFileList = archive.map(
      (e) => (stream: () => Stream.value(e.content), name: e.name),
    );

    fileNameList = archiveFileList.map((e) => e.name).toList(growable: false);

    return archiveFileList.toList(growable: false);
  }
}
