import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

class PhoneNumberFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  const PhoneNumberFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.phoneNumber;
}
