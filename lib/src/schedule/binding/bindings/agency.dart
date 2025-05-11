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

/// An agency is a single transit brand that offers rides. There can be multiple
/// agencies per operator.
class Agency {
  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_id:3
  /// {@end-tool}
  final String? id;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_name:3
  /// {@end-tool}
  final String name;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_url:3
  /// {@end-tool}
  final Uri url;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_timezone:3
  /// {@end-tool}
  final String timezone;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_lang:3
  /// {@end-tool}
  final LocaleLike? languageCode;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_phone:3
  /// {@end-tool}
  final String? phoneNumber;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_fare_url:3
  /// {@end-tool}
  final Uri? fareUrl;

  /// {@tool placedef}
  /// gtfs:agency.txt:table:agency_email:3
  /// {@end-tool}
  final String? email;

  /// Creates the object.
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

/// {@tool placedef}
/// gtfs:2Dataset Files:table:agency.txt:2
/// {@end-tool}
class Agencies extends SingleCsvLazyBinding<Agency> {
  /// Creates the list of agencies.
  Agencies({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'agency_id',
      (dataset, header, fileLength) => fileLength > 1 ? true : null,
      type: const IdFieldType(displayName: 'Agency ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'agency_name',
      (dataset, header, fileLength) => true,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'agency_url',
      (dataset, header, fileLength) => true,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'agency_timezone',
      (dataset, header, fileLength) => true,
      type: const TimezoneFieldType(),
    ),
    FieldDefinition(
      'agency_lang',
      (dataset, header, fileLength) => null,
      type: const LanguageCodeFieldType(),
    ),
    FieldDefinition(
      'agency_phone',
      (dataset, header, fileLength) => null,
      type: const PhoneNumberFieldType(),
    ),
    FieldDefinition(
      'agency_fare_url',
      (dataset, header, fileLength) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'agency_email',
      (dataset, header, fileLength) => null,
      type: const EmailFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
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
