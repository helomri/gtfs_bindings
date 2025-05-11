import 'package:gtfs_bindings/src/schedule/binding/bindings/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Time
/// {@end-tool}
class TimeFieldType extends FieldType<Time> {
  @override
  Time transform(String raw) => Time.parse(raw);

  /// Creates the field type.
  const TimeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.time;
}
