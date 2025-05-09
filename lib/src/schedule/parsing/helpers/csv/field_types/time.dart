import 'package:gtfs_bindings/src/schedule/binding/bindings/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class TimeFieldType extends FieldType<Time> {
  @override
  Time transform(String raw) => Time.parse(raw);

  const TimeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.time;
}
