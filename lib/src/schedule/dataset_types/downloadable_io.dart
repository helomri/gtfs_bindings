import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

class DownloadableDataset extends GtfsDataset {
  static final _logger = Logger('GtfsBinding.DatasetDownloader');

  final Uri uri;

  DownloadableDataset(this.uri);

  @override
  FutureOr<List<FileOpener>> getSource({String? tempDir}) async {
    final client = Client();

    final headResponse = await client.head(uri);
    String? fileName;
    DateTime? lastModified;
    if (headResponse.statusCode == HttpStatus.ok) {
      fileName = headResponse.headers['content-disposition']!
          .split('; ')
          .firstWhere(
            (element) => element.startsWith('filename='),
            orElse: () => 'filename=${uri.path.split('/').last}',
          )
          .substring(9);
      final format = DateFormat(
        "${DateFormat.ABBR_WEEKDAY}, ${DateFormat.DAY} ${DateFormat.ABBR_MONTH} ${DateFormat.YEAR} ${DateFormat.HOUR24}:${DateFormat.MINUTE}:${DateFormat.SECOND}' GMT'",
      );
      lastModified = format.parse(headResponse.headers['last-modified']!, true);
    } else {
      _logger.warning('Query URL did not accept HEAD request...');
    }

    var gtfsDirectory =
        tempDir != null ? Directory(join(tempDir, fileName)) : null;

    bool shouldDownload;
    if (await gtfsDirectory?.exists() ?? false) {
      final datasetDate =
          (await File(join(gtfsDirectory!.path, 'agency.txt')).stat()).modified;
      if (lastModified == null) {
        shouldDownload =
            DateTime.now().difference(datasetDate) > Duration(days: 1);
      } else {
        shouldDownload = !datasetDate.isAtSameMomentAs(lastModified);
      }
    } else {
      shouldDownload = true;
    }

    Iterable<FileOpener>? archiveFileList;

    if (!shouldDownload) {
      _logger.info('Acceptable dataset already in cache, skipping download...');
    } else {
      _logger.info('Downloading dataset...');
      final response = await MultipartRequest('GET', uri).send();

      if (fileName == null) {
        fileName = response.headers['content-disposition']!
            .split('; ')
            .firstWhere((element) => element.startsWith('filename='))
            .substring(9);
        gtfsDirectory =
            tempDir != null ? Directory(join(tempDir, fileName)) : null;
      }

      final archive = ZipDecoder().decodeStream(
        InputMemoryStream(await response.stream.toBytes()),
      );

      _logger.info('Finished downloading dataset.');
      if (gtfsDirectory != null) {
        extractArchiveToDiskSync(archive, gtfsDirectory.absolute.path);
        archiveFileList = gtfsDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .map((e) {
              e.setLastModifiedSync(lastModified ?? DateTime.now());
              return (stream: () => e.openRead(), name: basename(e.path));
            });
      } else {
        archiveFileList = archive.map(
          (e) => (stream: () => Stream.value(e.content), name: e.name),
        );
      }
    }

    archiveFileList ??= gtfsDirectory!
        .listSync(recursive: true)
        .whereType<File>()
        .map((e) => (stream: () => e.openRead(), name: basename(e.path)));
    fileNameList = archiveFileList.map((e) => e.name).toList(growable: false);

    return archiveFileList.toList(growable: false);
  }
}
