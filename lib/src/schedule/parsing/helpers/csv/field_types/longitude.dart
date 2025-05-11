import 'package:gtfs_bindings/schedule.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Longitude
/// {@end-tool}
class LongitudeDataType extends LatitudeFieldType {
  /// Creates the field type.
  const LongitudeDataType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.longitude;
}
