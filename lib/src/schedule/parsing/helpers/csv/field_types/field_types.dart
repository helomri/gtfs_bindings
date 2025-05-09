import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/color.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/currency_amount.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/currency_code.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/date.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/email.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/float.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/integer.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/language_code.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/latitude.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/longitude.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/phone_number.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/time.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/timezone.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/url.dart';

enum RegisteredFieldType {
  color("Color", ColorFieldType),
  currencyCode("Currency code", CurrencyCodeFieldType),
  currencyAmount("Currency amount", CurrencyAmountFieldType),
  date("Date", DateFieldType),
  email("Email", EmailFieldType),
  eenum("Enum", EnumFieldType),
  id("ID", IdFieldType),
  languageCode("Language code", LanguageCodeFieldType),
  latitude("Latitude", LatitudeFieldType),
  longitude("Longitude", LongitudeDataType),
  float("Float", FloatFieldType),
  integer("Integer", IntegerFieldType),
  phoneNumber("Phone number", PhoneNumberFieldType),
  time("Time", TimeFieldType),
  text("Text", TextFieldType),
  timezone("Timezone", TimezoneFieldType),
  url("URL", UrlFieldType);

  final String displayName;
  final Type mainAssociatedType;

  const RegisteredFieldType(this.displayName, this.mainAssociatedType);
}

abstract class FieldType<O> {
  O transform(String raw);

  O? get defaultValue => null;

  RegisteredFieldType get type;

  String get displayName => type.displayName;

  const FieldType();
}
