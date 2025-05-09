import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';

enum CriterionType {
  /// Only shows the ones that HAVE passed the criterion.
  select,

  /// Only shows the ones that HAVEN'T passed the criterion.
  filter,
}

class LoadCriterion {
  final List<String> requestedFields;
  final bool Function(List<String?> requestedFields) criterion;
  final CriterionType type;

  const LoadCriterion(
    this.requestedFields,
    this.criterion, {
    this.type = CriterionType.filter,
  });

  static List<String?> _recreateRequestedField(
    List<String> requestedFields,
    List<String> actuallyRequestedFields,
    List<String?> providedFields,
  ) {
    return requestedFields
        .map((e) => providedFields[actuallyRequestedFields.indexOf(e)])
        .toList(growable: false);
  }

  factory LoadCriterion._operator(
    LoadCriterion a,
    LoadCriterion b,
    bool Function(bool aResult, bool bResult) criterion,
  ) {
    final mergedRequestedFields = {
      ...a.requestedFields,
      ...b.requestedFields,
    }.toList(growable: false);

    return LoadCriterion(mergedRequestedFields.toList(), (requestedFields) {
      final aRequestedFields = _recreateRequestedField(
        a.requestedFields,
        mergedRequestedFields,
        requestedFields,
      );
      final bRequestedFields = _recreateRequestedField(
        b.requestedFields,
        mergedRequestedFields,
        requestedFields,
      );

      return criterion(
        a.criterion(aRequestedFields),
        b.criterion(bRequestedFields),
      );
    });
  }

  factory LoadCriterion.and(LoadCriterion a, LoadCriterion b) =>
      LoadCriterion._operator(a, b, (aResult, bResult) => aResult && bResult);
  factory LoadCriterion.or(LoadCriterion a, LoadCriterion b) =>
      LoadCriterion._operator(a, b, (aResult, bResult) => aResult || bResult);

  factory LoadCriterion._staticValue(bool value) =>
      LoadCriterion([], (_) => value);

  factory LoadCriterion.passAll() => LoadCriterion._staticValue(true);
  factory LoadCriterion.passNone() => LoadCriterion._staticValue(false);
}

class ListRecordToMapRecordSink implements EventSink<ListRecord> {
  final EventSink<MapRecord> _outputSink;
  final List<FieldDefinition> header;

  ListRecordToMapRecordSink(
    EventSink<MapRecord> outputSink, {
    required this.header,
  }) : _outputSink = outputSink;

  @override
  void add(ListRecord rawRecord) {
    _outputSink.add(toMapRecord(header, rawRecord));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _outputSink.close();
  }
}

class ListRecordToMapRecordTransformer
    extends StreamTransformerBase<ListRecord, MapRecord> {
  final List<FieldDefinition> header;

  const ListRecordToMapRecordTransformer(this.header);

  @override
  Stream<MapRecord> bind(Stream<ListRecord> stream) =>
      Stream<MapRecord>.eventTransformed(
        stream,
        (sink) => ListRecordToMapRecordSink(sink, header: header),
      );
}

abstract class LazyBinding<T> {
  String get fileName;

  const LazyBinding();

  FutureOr<void> prepare() {}

  Stream<T> streamResource([LoadCriterion? criteria]) =>
      streamResourceUntil(Completer(), criteria);
  Stream<T> streamResourceUntil(
    Completer<void> cancellationSignal, [
    LoadCriterion? criteria,
  ]);

  Future<List<T>> listResource([LoadCriterion? criteria]) async {
    final resourceList = <T>[];

    await for (final resource in streamResource(criteria)) {
      resourceList.add(resource);
    }

    return resourceList;
  }

  Future<int> count([LoadCriterion? criteria]) =>
      streamResource(criteria).length;

  Future<void> populateIfEmpty({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  });

  Future<void> fetchAllData({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  });
}

class ModelBuilder {
  final List<FieldDefinition> fieldDefinitions;
  final MapRecord record;

  const ModelBuilder({required this.fieldDefinitions, required this.record});

  dynamic Function(String key) get c => convert;

  dynamic convert(String key) {
    final fieldDefinition = fieldDefinitions
        .cast<FieldDefinition?>()
        .firstWhere((element) => element?.name == key, orElse: () => null);

    final value = record[key];

    if (fieldDefinition?.type == null) return value;
    if (value == null) {
      return fieldDefinition!.type!.defaultValue ??
          (fieldDefinition.defaultValue == null
              ? null
              : fieldDefinition.type!.transform(fieldDefinition.defaultValue!));
    }

    return fieldDefinition!.type!.transform(value);
  }

  static R build<R>(
    R Function(dynamic Function(String key) c) builder, {
    required List<FieldDefinition> fieldDefinitions,
    required MapRecord record,
  }) {
    final modelBuilder = ModelBuilder(
      fieldDefinitions: fieldDefinitions,
      record: record,
    );

    return builder(modelBuilder.c);
  }
}

abstract class SingleCsvLazyBinding<T> extends LazyBinding<T> {
  BaseCSVFile? data;
  final FileOpener resourceFile;
  List<FieldDefinition> get fieldDefinitions;

  @override
  String get fileName => resourceFile.name;

  SingleCsvLazyBinding({required this.resourceFile, this.data});

  Future<List<FieldDefinition>> getHeader() async {
    final cancellationSignal = Completer();
    final stream = streamRecordsThroughFile(
      resourceFile,
      fieldDefinitions,
      LoadCriterion.passAll(),
      cancellationSignal: cancellationSignal,
    );
    final rawHeader = await stream.first;
    cancellationSignal.complete();

    return rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse: () => FieldDefinition<Object>(
              e ?? 'unnamed_field',
              (dataset, header, records) => null,
              type: TextFieldType(),
            ),
          ),
        )
        .toList(growable: false);
  }

  T transform(MapRecord record);
  Stream<MapRecord> streamRawResource([LoadCriterion? criteria]) =>
      streamRawResourceUntil(Completer(), criteria);
  Stream<MapRecord> streamRawResourceUntil(
    Completer<void> cancellationSignal, [
    LoadCriterion? criteria,
  ]) async* {
    if (data != null) {
      BaseCSVFile finalData = data!;
      if (criteria != null) {
        finalData = finalData.filterThroughCriteria(criteria);
      }

      yield* Stream.fromIterable(finalData.toList(growable: false));
      return;
    }

    final stream = streamRecordsThroughFile(
      resourceFile,
      fieldDefinitions,
      criteria,
      cancellationSignal: cancellationSignal,
    ).asBroadcastStream();
    final rawHeader = await stream.first;

    final header = rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse: () => FieldDefinition<Object>(
              e ?? 'unnamed_field',
              (dataset, header, records) => null,
              type: TextFieldType(),
            ),
          ),
        )
        .toList(growable: false);

    await for (final e in stream.transform(
      ListRecordToMapRecordTransformer(header),
    )) {
      if (cancellationSignal.isCompleted) return;
      yield e;
    }
  }

  @override
  Stream<T> streamResourceUntil(
    Completer<void> cancellationSignal, [
    LoadCriterion? criteria,
  ]) => streamRawResource(criteria).map(transform);

  @override
  Future<List<T>> listResource([LoadCriterion? criteria]) {
    if (data != null) {
      return Future.value(
        data!
            .filterThroughCriteria(criteria ?? LoadCriterion.passAll())
            .map(transform)
            .toList(growable: false),
      );
    }

    return super.listResource(criteria);
  }

  @override
  Future<void> populateIfEmpty({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    if (data != null) return;

    await fetchAllData(
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    );
  }

  Future<BaseCSVFile> listRawResource({
    LoadCriterion? criteria,
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    if (data != null) {
      if (criteria == null) {
        return data!;
      }

      return data!.filterThroughCriteria(criteria);
    }

    final stream = streamRecordsThroughFile(
      resourceFile,
      fieldDefinitions,
      criteria,
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    ).asBroadcastStream();

    final rawHeader = await stream.first;

    final header = rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse: () => FieldDefinition<Object>(
              e ?? 'unnamed_field',
              (dataset, header, records) => null,
              type: TextFieldType(),
            ),
          ),
        )
        .toList(growable: false);

    return ListCSVFile(header: header, records: await stream.toList());
  }

  @override
  Future<void> fetchAllData({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    data = await listRawResource(
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    );
  }

  int? recordCount;

  @override
  Future<int> count([LoadCriterion? criteria]) async {
    if (criteria == null) {
      recordCount ??= (await listRawResource()).length;

      return recordCount!;
    }

    return listRawResource(criteria: criteria).then((value) {
      recordCount = value.length;
      return recordCount!;
    });
  }
}
