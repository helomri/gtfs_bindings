import 'package:gtfs_bindings/src/schedule/binding/bindings/calendar.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Date
/// {@end-tool}
class DateFieldType extends FieldType<Date> {
  @override
  Date transform(String raw) => Date.parse(raw);

  /// Creates the field type.
  const DateFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.date;
}
