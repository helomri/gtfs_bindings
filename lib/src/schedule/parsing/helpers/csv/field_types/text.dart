import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class TextFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  const TextFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.text;
}
