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

/// An enum of officially recognized field types.
enum RegisteredFieldType<T> {
  /// {@tool placedef}
  /// gtfs:Field Types:list:Color
  /// {@end-tool}
  color<ColorFieldType>("Color"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Currency code
  /// {@end-tool}
  currencyCode<CurrencyCodeFieldType>("Currency code"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Color amount
  /// {@end-tool}
  currencyAmount<CurrencyAmountFieldType>("Currency amount"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Date
  /// {@end-tool}
  date<DateFieldType>("Date"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Email
  /// {@end-tool}
  email<EmailFieldType>("Email"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Enum
  /// {@end-tool}
  eenum<EnumFieldType>("Enum"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:ID
  /// {@end-tool}
  id<IdFieldType>("ID"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Language code
  /// {@end-tool}
  languageCode<LanguageCodeFieldType>("Language code"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Latitude
  /// {@end-tool}
  latitude<LatitudeFieldType>("Latitude"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Longitude
  /// {@end-tool}
  longitude<LongitudeDataType>("Longitude"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Float
  /// {@end-tool}
  float<FloatFieldType>("Float"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Integer
  /// {@end-tool}
  integer<IntegerFieldType>("Integer"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Phone number
  /// {@end-tool}
  phoneNumber<PhoneNumberFieldType>("Phone number"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Time
  /// {@end-tool}
  time<TimeFieldType>("Time"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Text
  /// {@end-tool}
  text<TextFieldType>("Text"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:Timezone
  /// {@end-tool}
  timezone<TimezoneFieldType>("Timezone"),

  /// {@tool placedef}
  /// gtfs:Field Types:list:URL
  /// {@end-tool}
  url<UrlFieldType>("URL");

  /// The display name of the registered field type.
  final String displayName;

  const RegisteredFieldType(this.displayName);
}

/// A type of field, each type represents a different method of interpreting and
/// validating the raw data.
abstract class FieldType<O> {
  /// Transforms the [raw] date into an [O].
  O transform(String raw);

  /// The default value if when the field is not defined.
  O? get defaultValue => null;

  /// The actual type of a singular field.
  RegisteredFieldType get type;

  /// The display name of the field type.
  String get displayName => type.displayName;

  /// Creates the field type.
  const FieldType();
}
