import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Latitude
/// {@end-tool}
class LatitudeFieldType extends FieldType<double> {
  @override
  double transform(String raw) => double.parse(raw);

  /// Creates the field type.
  const LatitudeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.latitude;
}
