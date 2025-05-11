import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Color
/// {@end-tool}
class ColorFieldType extends FieldType<int> {
  @override
  int transform(String raw) => int.parse(raw, radix: 16) + 0xFF000000;

  /// Creates the field type.
  const ColorFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.color;
}
