import 'package:gtfs_bindings/schedule.dart';

class LongitudeDataType extends LatitudeFieldType {
  const LongitudeDataType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.longitude;
}
