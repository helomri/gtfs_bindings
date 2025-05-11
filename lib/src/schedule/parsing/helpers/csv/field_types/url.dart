import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:URL
/// {@end-tool}
class UrlFieldType extends FieldType<Uri> {
  @override
  Uri transform(String raw) => Uri.parse(raw);

  /// Creates the field type.
  const UrlFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.url;
}
