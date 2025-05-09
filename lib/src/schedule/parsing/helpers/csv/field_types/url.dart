import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class UrlFieldType extends FieldType<Uri> {
  @override
  Uri transform(String raw) => Uri.parse(raw);

  const UrlFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.url;
}
