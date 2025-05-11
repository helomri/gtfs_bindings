import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/integer.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Float
/// {@end-tool}
class FloatFieldType extends FieldType<double> {
  @override
  double transform(String raw) => double.parse(raw);

  /// The constraint applied to a number.
  final NumberConstraint? constraint;

  /// Creates the field type.
  const FloatFieldType([this.constraint]);

  @override
  String get displayName => switch (constraint) {
    NumberConstraint.nonNegative => 'Non-negative float',
    NumberConstraint.nonZero => 'Non-zero float',
    NumberConstraint.positive => 'Positive float',
    _ => super.displayName,
  };

  @override
  RegisteredFieldType get type => RegisteredFieldType.float;
}
