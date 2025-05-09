import 'package:gtfs_bindings/schedule.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/latitude.dart';

class LongitudeDataType extends LatitudeFieldType {
  const LongitudeDataType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.longitude;
}
