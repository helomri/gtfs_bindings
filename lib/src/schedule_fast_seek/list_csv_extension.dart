import 'dart:math';

import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

const int individualRecordIndexSize = 50_000;

class FastSeekListCSV extends ListCSVFile {
  const FastSeekListCSV({
    required super.header,
    required this.recordIndex,
    required this.length,
  }) : super(records: const []);

  @override
  ListRecord operator [](int index) =>
      recordIndex[index ~/ individualRecordIndexSize][index %
          individualRecordIndexSize];

  factory FastSeekListCSV.fromListCSV(ListCSVFile base) {
    if (base is FastSeekListCSV) return base;

    var current = 0;
    var cutOff = individualRecordIndexSize;

    final baseLength = base.length;

    final newIndex = <List<ListRecord>>[];

    while (current < baseLength) {
      newIndex.add(base.records.sublist(current, min(baseLength, cutOff)));
      current += individualRecordIndexSize;
      cutOff += individualRecordIndexSize;
    }

    return FastSeekListCSV(
      header: base.header,
      recordIndex: newIndex,
      length: baseLength,
    );
  }

  FastSeekListCSV whereCriterion(LoadCriterion criterion) {
    final List<int> matchedIndices = [];
    for (final requestedField in criterion.requestedFields) {
      matchedIndices.add(
        header.indexWhere((field) => field.name == requestedField),
      );
    }

    final List<ListRecord> newRecordIndex = [];
    for (final individualRecordIndex in recordIndex) {
      for (final record in individualRecordIndex) {
        if (criterion.criterion(
          matchedIndices
              .map((e) => e == -1 ? null : record[e])
              .toList(growable: false),
        )) {
          newRecordIndex.add(record);
        }
      }
    }

    return FastSeekListCSV.fromListCSV(
      ListCSVFile(header: header, records: newRecordIndex),
    );
  }

  final List<List<ListRecord>> recordIndex;
  @override
  final int length;

  @override
  List<ListRecord> get records =>
      recordIndex.reduce((value, element) => value + element);
}

extension ToFastList on ListCSVFile {
  FastSeekListCSV toFast() => FastSeekListCSV.fromListCSV(this);
}
