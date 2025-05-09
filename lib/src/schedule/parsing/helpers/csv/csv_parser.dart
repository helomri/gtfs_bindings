import 'dart:async';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';
import 'package:logging/logging.dart';

typedef FileOpener = ({Stream<List<int>> Function() stream, String name});

typedef MapRecord = Map<String, String>;

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

typedef ListRecord = List<String?>;

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

Future<void> _checkForOverallField(
  BaseCSVFile file,
  List<FieldDefinition> fieldDefinitions,
  List<FieldDefinition> header,
  GtfsDataset dataset,
) async {
  for (final field in fieldDefinitions) {
    final required = await field.shouldBeRequiredOverall(
      dataset,
      file.header,
      file.toList(growable: false),
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

Stream<ListRecord> streamRecordsThroughFile(
  FileOpener resourceFile,
  List<FieldDefinition> fieldDefinitions,
  LoadCriterion? criteria, {
  bool doValidationChecks = false,
  GtfsDataset? dataset,
  Completer<void>? cancellationSignal,
}) async* {
  if (doValidationChecks && dataset == null) {
    throw Exception('Wants to do validation checks but no dataset provided');
  }

  final (stream: fileStream, name: fileName) = resourceFile;

  List<FieldDefinition>? header;
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
                _logger.warning(
                  'Unknown field in $fileName, header = ${record.join(',')}',
                );
                return FieldDefinition<Object>(
                  e ?? 'unnamed_field',
                  (dataset, header, records) => null,
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

sealed class BaseCSVFile extends Iterable<MapRecord> {
  List<FieldDefinition> get header;
  Iterator<ListRecord> get rawIterator;

  BaseCSVFile filterThroughCriteria(LoadCriterion criteria);

  ListCSVFile toListCSVFile();
  MapCSVFile toMapCSVFile();

  const BaseCSVFile();
}

class MapRecordIterator implements Iterator<MapRecord> {
  const MapRecordIterator({required this.header, required this.baseIterator});

  final List<FieldDefinition> header;
  final Iterator<ListRecord> baseIterator;

  @override
  get current => toMapRecord(header, baseIterator.current);

  @override
  bool moveNext() => baseIterator.moveNext();
}

class ListRecordIterator implements Iterator<ListRecord> {
  const ListRecordIterator({required this.header, required this.baseIterator});

  final List<FieldDefinition> header;
  final Iterator<MapRecord> baseIterator;

  @override
  get current => toListRecord(header, baseIterator.current);

  @override
  bool moveNext() => baseIterator.moveNext();
}

class ListCSVFile extends BaseCSVFile {
  const ListCSVFile({required this.header, required this.records});

  ListRecord operator [](int index) => records[index];

  @override
  final List<FieldDefinition> header;
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
                    (dataset, header, records) => null,
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

class MapCSVFile extends BaseCSVFile {
  const MapCSVFile({
    required List<FieldDefinition> actualHeader,
    required this.records,
  }) : header = actualHeader;

  @override
  final List<FieldDefinition> header;
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
