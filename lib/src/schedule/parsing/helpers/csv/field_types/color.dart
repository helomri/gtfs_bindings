import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class ColorFieldType extends FieldType<int> {
  @override
  int transform(String raw) => int.parse(raw, radix: 16) + 0xFF000000;

  const ColorFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.color;
}
