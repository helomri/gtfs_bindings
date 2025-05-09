import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class LatitudeFieldType extends FieldType<double> {
  @override
  double transform(String raw) => double.parse(raw);

  const LatitudeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.latitude;
}
