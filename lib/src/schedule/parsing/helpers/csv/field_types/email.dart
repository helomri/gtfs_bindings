import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Email
/// {@end-tool}
class EmailFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  /// Creates the field type.
  const EmailFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.email;
}
