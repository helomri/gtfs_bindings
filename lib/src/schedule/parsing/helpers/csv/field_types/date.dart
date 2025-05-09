import 'package:gtfs_bindings/src/schedule/binding/bindings/calendar.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class DateFieldType extends FieldType<Date> {
  @override
  Date transform(String raw) => Date.parse(raw);

  const DateFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.date;
}
