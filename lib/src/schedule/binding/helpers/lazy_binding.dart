import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';

/// An object used to specify query filters when dealing with CSV data.
class LoadCriterion {
  /// The list of fields required for the [criterion] to determine whether to
  /// filter the candidate.
  final List<String> requestedFields;

  /// The actual criterion ran for each candidate. [requestedFields] contains a
  /// list the same length of [requestedFields]. You can find the specific value
  /// for a column at the same place as its name in [requestedFields]. If the
  /// record doesn't contain the field, `null` is placed.
  final bool Function(List<String?> requestedFields) criterion;

  /// Creates a new Criterion to give to one or more query method.
  const LoadCriterion(this.requestedFields, this.criterion);

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

  /// Returns `true` if both [LoadCriterion] return `true`.
  factory LoadCriterion.and(LoadCriterion a, LoadCriterion b) =>
      LoadCriterion._operator(a, b, (aResult, bResult) => aResult && bResult);

  /// Returns `true` if at least one [LoadCriterion] return `true`.
  factory LoadCriterion.or(LoadCriterion a, LoadCriterion b) =>
      LoadCriterion._operator(a, b, (aResult, bResult) => aResult || bResult);

  factory LoadCriterion._staticValue(bool value) =>
      LoadCriterion([], (_) => value);

  /// Create a LoadCriterion that doesn't filter anything.
  factory LoadCriterion.passAll() => LoadCriterion._staticValue(true);

  /// Create a LoadCriterion that filters everything.
  factory LoadCriterion.passNone() => LoadCriterion._staticValue(false);
}

class _ListRecordToMapRecordSink implements EventSink<ListRecord> {
  final EventSink<MapRecord> _outputSink;
  final List<FieldDefinition> header;

  _ListRecordToMapRecordSink(
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

/// Transform [ListRecord]s into [MapRecord]s on the fly.
/// A [header] must be given in advance to know which column each list element
/// is associated with.
class ListRecordToMapRecordTransformer
    extends StreamTransformerBase<ListRecord, MapRecord> {
  /// The header used to attribute each field in the [ListRecord] with its field
  /// name.
  final List<FieldDefinition> header;

  /// Creates the transformer.
  const ListRecordToMapRecordTransformer(this.header);

  @override
  Stream<MapRecord> bind(Stream<ListRecord> stream) =>
      Stream<MapRecord>.eventTransformed(
        stream,
        (sink) => _ListRecordToMapRecordSink(sink, header: header),
      );
}

/// A binding represents the manager for a single file in the GTFS Schedule
/// dataset. It is responsible for making available (preferably in a
/// deserialized form) the data that resides in the file.
///
/// [T] is the smallest fragment of information that can be outputted by the
/// binding while still being useful. In CSV files, this represents a single
/// record (more likely its associated object).
abstract class LazyBinding<T> {
  /// The full name for the file the [LazyBinding] is loading.
  String get fileName;

  /// Creates a new [LazyBinding].
  const LazyBinding();

  /// Is called when the [GtfsDataset] is piped.
  FutureOr<void> prepare() {}

  /// Outputs every single [T] in the file in a [Stream<T>].
  Stream<T> streamResource() => streamResourceUntil(Completer());

  /// Outputs every single [T] in the file in a [Stream<T>], if the
  /// [cancellationSignal] is completed, the stream will close and stop
  /// outputting anything.
  Stream<T> streamResourceUntil(Completer<void> cancellationSignal);

  /// Lists every single [T] in the file in a [List<T>].
  Future<List<T>> listResource() => streamResource().toList();

  /// Counts the amount of [T] in the file.
  Future<int> count() => streamResource().length;

  /// Populates the file (loads every single [T] in memory) if it wasn't already
  /// done before.
  Future<void> populateIfEmpty({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  });

  /// Populates the file (loads every single [T] in memory) whether it was
  /// already done or not.
  Future<void> forcePopulateAll({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  });
}

/// A helper class to automatically transform each field of a [record] into its
/// deserialized form depending on its type retrieved from its
/// [FieldDefinition] supplied with all the [fieldDefinitions].
class ModelBuilder {
  /// The list of known field definitions for the resulting type.
  final List<FieldDefinition> fieldDefinitions;

  /// The record from where the fields to deserialize are taken.
  final MapRecord record;

  /// Creates the [ModelBuilder]
  const ModelBuilder({required this.fieldDefinitions, required this.record});

  /// Shorthand for convert.
  dynamic Function(String key) get c => convert;

  /// Transform the [String] field value to its serialized form.
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

  /// Utility method to not have to do ``model.c`` and simply assign the
  /// function to a local variable managed by this to remove duplicate
  /// boilerplate code.
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

/// A special kind of [LazyBinding], it is extended by singular bindings that
/// read their data from a CSV file. It offers optimized implementations for
/// [LazyBinding], additional methods only applicable to CSV files.
abstract class SingleCsvLazyBinding<T> extends LazyBinding<T> {
  /// The [data] that was populated by [forcePopulateAll].
  BaseCSVFile? data;

  /// The base file that is used  to read parameters.
  final FileOpener resourceFile;

  /// All the known field definitions for the CSV file.
  List<FieldDefinition> get fieldDefinitions;

  @override
  String get fileName => resourceFile.name;

  /// Creates the binding.
  SingleCsvLazyBinding({required this.resourceFile, this.data});

  /// Gets the actual header of the file which is made of fields in
  /// [fieldDefinitions] and possibly fields that are not in the official GTFS
  /// Schedule spec, in which case a new [FieldDefinition] is created at
  /// runtime.
  Future<List<FieldDefinition>> getHeader() async {
    final cancellationSignal = Completer();
    final stream = streamRecordsThroughFile(
      resourceFile,
      fieldDefinitions: fieldDefinitions,
      cancellationSignal: cancellationSignal,
    );
    final rawHeader = await stream.first;
    cancellationSignal.complete();

    return rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse:
                () => FieldDefinition<Object>(
                  e ?? 'unnamed_field',
                  (dataset, header, fileLength) => null,
                  type: TextFieldType(),
                ),
          ),
        )
        .toList(growable: false);
  }

  /// Transforms a [MapRecord] into [T]. The usage of [ModelBuilder] is
  /// recommended, especially [ModelBuilder.build].
  T transform(MapRecord record);

  /// Streams all raw [MapRecord]s (instead of [T]s in [streamResource]) that
  /// matches [criteria], is present.
  Stream<MapRecord> streamRawResource([LoadCriterion? criteria]) =>
      streamRawResourceUntil(Completer(), criteria);

  /// Equivalent to [streamRawResource] but stops searching if a
  /// [cancellationSignal] is completed.
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

    final stream =
        streamRecordsThroughFile(
          resourceFile,
          fieldDefinitions: fieldDefinitions,
          criteria: criteria,
          cancellationSignal: cancellationSignal,
        ).asBroadcastStream();
    final rawHeader = await stream.first;

    final header = rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse:
                () => FieldDefinition<Object>(
                  e ?? 'unnamed_field',
                  (dataset, header, fileLength) => null,
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
  Stream<T> streamResource([LoadCriterion? criteria]) =>
      streamResourceUntil(Completer(), criteria);

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

    return streamResource(criteria).toList();
  }

  @override
  Future<void> populateIfEmpty({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    if (data != null) return;

    await forcePopulateAll(
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    );
  }

  /// Lists all records in an efficient [BaseCSVFile].
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

    final stream =
        streamRecordsThroughFile(
          resourceFile,
          fieldDefinitions: fieldDefinitions,
          criteria: criteria,
          doValidationChecks: doValidationChecks,
          dataset: dataset,
        ).asBroadcastStream();

    final rawHeader = await stream.first;

    final header = rawHeader
        .map(
          (e) => fieldDefinitions.firstWhere(
            (element) => element.name == e,
            orElse:
                () => FieldDefinition<Object>(
                  e ?? 'unnamed_field',
                  (dataset, header, fileLength) => null,
                  type: TextFieldType(),
                ),
          ),
        )
        .toList(growable: false);

    return ListCSVFile(header: header, records: await stream.toList());
  }

  @override
  Future<void> forcePopulateAll({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    data = await listRawResource(
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    );
  }

  /// The amount of [T] in the CSV file.
  int? recordCount;

  @override
  Future<int> count([LoadCriterion? criteria]) async {
    if (criteria == null) {
      recordCount ??= await streamRawResource().length;

      return recordCount!;
    }

    return streamRawResource(criteria).length;
  }
}
