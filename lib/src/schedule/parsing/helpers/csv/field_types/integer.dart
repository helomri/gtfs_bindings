import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// A constraint applied to number
enum NumberConstraint {
  /// The number x must be equal or higher than 0.
  nonNegative,

  /// The number x must not equal 0.
  nonZero,

  /// The number x must be higher than 0.
  positive,
}

/// {@tool placedef}
/// gtfs:Field Types:list:Integer
/// {@end-tool}
class IntegerFieldType extends FieldType<int> {
  @override
  int transform(String raw) => int.parse(raw);

  /// The constraint applied to a number.
  final NumberConstraint? constraint;

  /// Creates the field type.
  const IntegerFieldType([this.constraint]);

  @override
  String get displayName => switch (constraint) {
    NumberConstraint.nonNegative => 'Non-negative integer',
    NumberConstraint.nonZero => 'Non-zero integer',
    NumberConstraint.positive => 'Positive integer',
    _ => super.displayName,
  };

  @override
  RegisteredFieldType get type => RegisteredFieldType.integer;
}
