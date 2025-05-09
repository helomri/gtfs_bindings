import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

enum NumberConstraint { nonNegative, nonZero, positive }

class IntegerFieldType extends FieldType<int> {
  @override
  int transform(String raw) => int.parse(raw);

  final NumberConstraint? constraint;

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
