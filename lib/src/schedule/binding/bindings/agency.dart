import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/email.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/language_code.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/phone_number.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/timezone.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/url.dart';

class Agency {
  final String? id;
  final String name;
  final Uri url;
  final String timezone;
  final LocaleLike? languageCode;
  final String? phoneNumber;
  final Uri? fareUrl;
  final String? email;

  const Agency({
    required this.id,
    required this.name,
    required this.url,
    required this.timezone,
    required this.languageCode,
    required this.phoneNumber,
    required this.fareUrl,
    required this.email,
  });

  @override
  int get hashCode => Object.hash(
    id,
    name,
    url,
    timezone,
    languageCode,
    phoneNumber,
    fareUrl,
    email,
  );

  @override
  bool operator ==(Object other) {
    return other is Agency && other.hashCode == hashCode;
  }
}

class Agencies extends SingleCsvLazyBinding<Agency> {
  Agencies({required super.resourceFile, super.data});

  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'agency_id',
      (existingDataset, rawHeader, records) => records.length > 1 ? true : null,
      type: const IdFieldType(displayName: 'Agency ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'agency_name',
      (existingDataset, rawHeader, records) => true,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'agency_url',
      (existingDataset, rawHeader, records) => true,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'agency_timezone',
      (existingDataset, rawHeader, records) => true,
      type: const TimezoneFieldType(),
    ),
    FieldDefinition(
      'agency_lang',
      (existingDataset, rawHeader, records) => null,
      type: const LanguageCodeFieldType(),
    ),
    FieldDefinition(
      'agency_phone',
      (existingDataset, rawHeader, records) => null,
      type: const PhoneNumberFieldType(),
    ),
    FieldDefinition(
      'agency_fare_url',
      (existingDataset, rawHeader, records) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'agency_email',
      (existingDataset, rawHeader, records) => null,
      type: const EmailFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  static Agency staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => Agency(
      id: c('agency_id'),
      name: c('agency_name'),
      url: c('agency_url'),
      timezone: c('agency_timezone'),
      languageCode: c('agency_lang'),
      phoneNumber: c('agency_phone'),
      fareUrl: c('agency_fare_url'),
      email: c('agency_email'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  Agency transform(MapRecord record) => staticTransform(record);
}
