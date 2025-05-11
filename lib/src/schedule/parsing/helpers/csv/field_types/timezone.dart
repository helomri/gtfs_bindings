import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Timezone
/// {@end-tool}
class TimezoneFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  /// Creates the field type.
  const TimezoneFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.timezone;
}
