import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/integer.dart';

class FloatFieldType extends FieldType<double> {
  @override
  double transform(String raw) => double.parse(raw);

  final NumberConstraint? constraint;

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
