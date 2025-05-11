import 'dart:async';

import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// The representation of a field present in the GTFS spec.
///
/// This gives information as to how to deserialize the data and additional
/// information about whether the field is required to do some validation work.
class FieldDefinition<O> {
  /// The name of the field.
  final String name;

  /// Should the field be required. `true` means it's mandatory. `null` means
  /// it's optional. `false` means it's forbidden.
  final FutureOr<bool?> Function(
    GtfsDataset dataset,
    List<FieldDefinition> header,
    MapRecord record,
  )?
  shouldBeRequired;

  /// Should the field be required in file as a whole. `true` means it's
  /// mandatory. `null` means it's optional. `false` means it's forbidden.
  final FutureOr<bool?> Function(
    GtfsDataset dataset,
    List<FieldDefinition> header,
    int fileLength,
  )
  shouldBeRequiredOverall;

  /// Whether the field is a primary key (a key in itself or with other we can
  /// count as identifiers for each record).
  final bool primaryKey;

  /// The default value for the current field.
  final String? defaultValue;

  /// The type of the field.
  final FieldType<O>? type;

  /// Creates the field definition.
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
