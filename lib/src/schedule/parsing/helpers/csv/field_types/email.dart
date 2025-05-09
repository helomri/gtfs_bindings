import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class EmailFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  const EmailFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.email;
}
