import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Text
/// {@end-tool}
class TextFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  /// Creates the field type.
  const TextFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.text;
}
