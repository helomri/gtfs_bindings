import 'dart:async';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';
import 'package:logging/logging.dart';

/// A simple record to map a [Stream<List<int>>] factory to a file `name`.
typedef FileOpener = ({Stream<List<int>> Function() stream, String name});

/// A [MapRecord] maps every single record value to the [String] name of the
/// field as a key.
typedef MapRecord = Map<String, String>;

/// Transforms a [ListRecord] into a [MapRecord] using the [header] as order
/// reference.
MapRecord toMapRecord(List<FieldDefinition> header, ListRecord rawRecord) {
  final newRecord = <String, String>{};
  for (var i = 0; i < rawRecord.length; i++) {
    final def = header[i];
    if (rawRecord[i]?.isNotEmpty ?? false) {
      newRecord[def.name] = rawRecord[i]!;
    }
  }
  return newRecord;
}

/// A [ListRecord] lists every single record value in the same order as its name
/// from the file header.
typedef ListRecord = List<String?>;

/// Transforms a [MapRecord] into a [ListRecord] using the [header] as the
/// source for field names.
ListRecord toListRecord(List<FieldDefinition> header, MapRecord mapRecord) {
  return header.map((e) => mapRecord[e.name]).toList(growable: false);
}

Future<void> _checkForIndividualField(
  MapRecord mapRecord,
  List<FieldDefinition> fieldDefinitions,
  List<FieldDefinition> header,
  GtfsDataset dataset,
) async {
  for (final field in fieldDefinitions) {
    final required = await field.shouldBeRequired?.call(
      dataset,
      header,
      mapRecord,
    );

    if (header.contains(field) &&
        field.defaultValue != null &&
        (mapRecord[field.name]?.isEmpty ?? true)) {
      mapRecord[field.name] = field.defaultValue!;
    }

    if (required == true &&
        (!header.contains(field) || (mapRecord[field.name]?.isEmpty ?? true))) {
      throw UnsupportedError('Required field not found: ${field.name}');
    }
    if (required == false &&
        (header.contains(field) &&
            (mapRecord[field.name]?.isNotEmpty ?? false))) {
      throw UnsupportedError('Forbidden field found: ${field.name}');
    }
  }
}

// TODO: Refactor to be more efficient.
Future<void> _checkForOverallField(
  BaseCSVFile file,
  List<FieldDefinition> fieldDefinitions,
  List<FieldDefinition> header,
  GtfsDataset dataset,
) async {
  int fileLength = file.length;
  for (final field in fieldDefinitions) {
    final required = await field.shouldBeRequiredOverall(
      dataset,
      file.header,
      fileLength,
    );

    if (required == true && !header.contains(field)) {
      throw UnsupportedError('Required field not found: ${field.name}');
    }
    if (required == false && header.contains(field)) {
      throw UnsupportedError('Forbidden field found: ${field.name}');
    }
  }
}

final _logger = Logger('GtfsBindings.CSVParser');

/// Streams [ListRecord]s as they get read in the [resourceFile]
Stream<ListRecord> streamRecordsThroughFile(
  FileOpener resourceFile, {
  LoadCriterion? criteria,
  bool doValidationChecks = false,
  List<FieldDefinition<dynamic>> fieldDefinitions =
      const <FieldDefinition<dynamic>>[],
  GtfsDataset? dataset,
  Completer<void>? cancellationSignal,
}) async* {
  if (doValidationChecks && (dataset == null || fieldDefinitions.isEmpty)) {
    throw Exception(
      "Wants to do validation checks but no dataset provided and/or field definitions aren't made available.",
    );
  }

  final (stream: fileStream, name: fileName) = resourceFile;

  List<FieldDefinition<dynamic>>? header;
  List<int>? criterionRequestedFieldsIndices;
  await for (final rawLine in fileStream()
      .transform(utf8.decoder)
      .transform(
        CsvToListConverter(
          shouldParseNumbers: false,
          csvSettingsDetector: FirstOccurrenceSettingsDetector(
            eols: ['\r\n', '\n'],
          ),
        ),
      )) {
    ListRecord record = ListRecord.from(rawLine);
    if (header == null) {
      header = record
          .map((e) {
            final field = fieldDefinitions.firstWhere(
              (element) => element.name == e,
              orElse: () {
                if (doValidationChecks) {
                  _logger.warning(
                    'Unknown field in $fileName, header = ${record.join(',')}',
                  );
                }
                return FieldDefinition<Object>(
                  e ?? 'unnamed_field',
                  (dataset, header, fileLength) => null,
                  type: TextFieldType(),
                );
              },
            );

            return field;
          })
          .toList(growable: false);
      yield record;

      if (criteria != null) {
        criterionRequestedFieldsIndices = criteria.requestedFields
            .map((e) => rawLine.indexOf(e))
            .toList(growable: false);
      }

      continue;
    }

    final matchesCriteria =
        criteria?.criterion(
          criterionRequestedFieldsIndices!
              .map((e) => e == -1 ? null : record.elementAtOrNull(e))
              .toList(growable: false),
        ) ??
        true;

    if (matchesCriteria) {
      record = record
          .map((e) => (e?.isEmpty ?? true) ? null : e)
          .toList(growable: false);

      if (doValidationChecks) {
        final mapRecord = toMapRecord(header, record);
        await _checkForIndividualField(
          mapRecord,
          fieldDefinitions,
          header,
          dataset!,
        );
      }

      yield record;
    }

    if (cancellationSignal?.isCompleted ?? false) break;
  }

  // TODO: Check the field-checking stuff to (a) not require the full file and
  // TODO: (b) not give the record as a map record.
  //_checkForOverallField(file, fieldDefinitions, header!, dataset!);
}

/// The equivalent of a [List] of records ([MapRecord]s and [ListRecord]) made
/// to do translations on the fly and be queriable.
sealed class BaseCSVFile extends Iterable<MapRecord> {
  /// The actual header for the binding.
  List<FieldDefinition> get header;

  /// The iterator of [ListRecord]s.
  Iterator<ListRecord> get rawIterator;

  /// Creates a new [BaseCSVFile] filtered via the [criteria].
  BaseCSVFile filterThroughCriteria(LoadCriterion criteria);

  /// Transforms the CSVFile into a file that stores [ListRecord] in memory.
  ListCSVFile toListCSVFile();

  /// Transforms the CSVFile into a file that stores [MapRecord] in memory.
  MapCSVFile toMapCSVFile();

  const BaseCSVFile();
}

/// An iterator that transforms [ListRecord]s to [MapRecord]s.
class MapRecordIterator implements Iterator<MapRecord> {
  /// Creates the [MapRecordIterator].
  const MapRecordIterator({required this.header, required this.baseIterator});

  /// The header required to map [ListRecord] fields to their name.
  final List<FieldDefinition> header;

  /// The initial iterator of [ListRecord]s.
  final Iterator<ListRecord> baseIterator;

  @override
  get current => toMapRecord(header, baseIterator.current);

  @override
  bool moveNext() => baseIterator.moveNext();
}

/// An iterator that transforms [MapRecord]s to [ListRecord]s
class ListRecordIterator implements Iterator<ListRecord> {
  /// Creates the [ListRecordIterator].
  const ListRecordIterator({required this.header, required this.baseIterator});

  /// The header required to list [MapRecord]s in the same way as the [header].
  final List<FieldDefinition> header;

  /// The initial iterator of [MapRecord]s.
  final Iterator<MapRecord> baseIterator;

  @override
  get current => toListRecord(header, baseIterator.current);

  @override
  bool moveNext() => baseIterator.moveNext();
}

/// A [BaseCSVFile] that stores [ListRecord]s in memory.
class ListCSVFile extends BaseCSVFile {
  /// Creates the [ListCSVFile].
  const ListCSVFile({required this.header, required this.records});

  /// Get the record at [index].
  ListRecord operator [](int index) => records[index];

  @override
  final List<FieldDefinition> header;

  /// The actual list of [ListRecord] stored in memory.
  final List<ListRecord> records;

  @override
  int get length => records.length;

  @override
  Iterator<MapRecord> get iterator =>
      MapRecordIterator(header: header, baseIterator: rawIterator);

  @override
  Iterator<ListRecord> get rawIterator => records.iterator;

  @override
  ListCSVFile toListCSVFile() => this;

  @override
  MapCSVFile toMapCSVFile() =>
      MapCSVFile(actualHeader: header, records: toList(growable: false));

  @override
  BaseCSVFile filterThroughCriteria(LoadCriterion criteria) {
    List<({FieldDefinition? definition, int index})> list = criteria
        .requestedFields
        .map((requestedField) {
          isSame(element) => element.name == requestedField;
          return header.any(isSame)
              ? (
                definition: header.firstWhere(isSame),
                index: header.indexWhere(isSame),
              )
              : (definition: null, index: -1);
        })
        .toList(growable: false);

    return ListCSVFile(
      header: header,
      records: records
          .where((candidate) {
            return criteria.criterion(
              list
                  .map(
                    (e) =>
                        e.index == -1
                            ? ''
                            : candidate.elementAtOrNull(e.index) ??
                                e.definition!.defaultValue ??
                                '',
                  )
                  .toList(growable: false),
            );
          })
          .toList(growable: false),
    );
  }

  /// Parses the [input] into a [ListCSVFile].
  ///
  /// Quite close to [streamRecordsThroughFile].
  static Future<ListCSVFile> parse(
    FileOpener input,
    List<FieldDefinition> fieldDefinitions,
    GtfsDataset dataset, {
    bool Function(MapRecord record)? where,
    bool evaluateIndividualFields = false,
  }) async {
    final (stream: fileStream, name: fileName) = input;

    List<FieldDefinition>? header;
    List<ListRecord> records = [];
    await for (final rawLine in fileStream()
        .transform(utf8.decoder)
        .transform(
          CsvToListConverter(
            shouldParseNumbers: false,
            csvSettingsDetector: FirstOccurrenceSettingsDetector(
              eols: ['\r\n', '\n'],
            ),
          ),
        )) {
      ListRecord record = ListRecord.from(rawLine);
      if (header == null) {
        header = record
            .map((e) {
              final field = fieldDefinitions.firstWhere(
                (element) => element.name == e,
                orElse: () {
                  _logger.warning(
                    'Unknown field in $fileName, header = ${record.join(',')}',
                  );
                  return FieldDefinition(
                    e ?? 'unnamed_field',
                    (dataset, header, fileLength) => null,
                    type: TextFieldType(),
                  );
                },
              );

              return field;
            })
            .toList(growable: false);
        continue;
      }

      MapRecord? mapRecord;
      if (evaluateIndividualFields) {
        mapRecord ??= toMapRecord(header, record);
        await _checkForIndividualField(
          mapRecord,
          fieldDefinitions,
          header,
          dataset,
        );
      }

      if (where != null) {
        mapRecord ??= toMapRecord(header, record);
        if (where(mapRecord)) {
          records.add(record);
        }
      } else {
        records.add(record);
      }
    }

    assert(header != null, 'CSV file is empty');

    final file = ListCSVFile(header: header ?? [], records: records);

    _checkForOverallField(file, fieldDefinitions, header!, dataset);

    return file;
  }
}

/// A [BaseCSVFile] that stores [MapRecord]s in memory.
class MapCSVFile extends BaseCSVFile {
  /// Creates the [MapCSVFile].
  const MapCSVFile({
    required List<FieldDefinition> actualHeader,
    required this.records,
  }) : header = actualHeader;

  @override
  final List<FieldDefinition> header;

  /// The list of [MapRecord] stored in memory.
  final List<MapRecord> records;

  @override
  int get length => records.length;

  @override
  Iterator<MapRecord> get iterator => records.iterator;

  @override
  Iterator<ListRecord> get rawIterator =>
      ListRecordIterator(header: header, baseIterator: iterator);

  @override
  MapCSVFile toMapCSVFile() => this;
  @override
  ListCSVFile toListCSVFile() => ListCSVFile(
    header: header,
    records: records
        .map((e) => toListRecord(header, e))
        .toList(growable: false),
  );

  @override
  BaseCSVFile filterThroughCriteria(LoadCriterion criteria) {
    return MapCSVFile(
      actualHeader: header,
      records: records
          .where(
            (candidate) => criteria.criterion(
              criteria.requestedFields
                  .map((e) => candidate[e] ?? '')
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }
}
