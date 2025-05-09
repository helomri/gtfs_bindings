import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class FieldDefinition<O> {
  final String name;

  /// Should the field be required. [true] means it's mandatory. [null] means
  /// it's optional. [false] means it's forbidden.
  ///
  /// [existingFields] is the list of parsed fields in the first line of the file.
  final FutureOr<bool?> Function(
    GtfsDataset dataset,
    List<FieldDefinition> header,
    MapRecord record,
  )?
  shouldBeRequired;

  final FutureOr<bool?> Function(
    GtfsDataset dataset,
    List<FieldDefinition> header,
    List<MapRecord> records,
  )
  shouldBeRequiredOverall;

  final bool primaryKey;
  final String? defaultValue;

  final FieldType<O>? type;

  FieldDefinition(
    this.name,
    this.shouldBeRequiredOverall, {
    this.shouldBeRequired,
    required this.type,
    this.primaryKey = false,
    this.defaultValue,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is String) {
      return other == name;
    }

    return other is FieldDefinition && hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hash(name, primaryKey);

  @override
  String toString() => '$name(${type?.displayName ?? 'No type'})';
}
