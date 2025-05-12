import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/date.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';

/// Indicates whether the service operates on a specific day.
enum OperatesOnDay implements RichlyNamedEnum {
  /// Service is available for all days in the date range.
  available(
    'Available',
    'Service is available for all days in the date range.',
    1,
  ),

  /// Service is not available for all days in the date range.
  notAvailable(
    'Unavailable',
    'Service is not available for all days in the date range.',
    0,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const OperatesOnDay(this.displayName, this.description, this.id);

  /// Transforms the raw value to the enum value.
  static OperatesOnDay forId(int id) =>
      values.firstWhere((element) => element.id == id);

  /// Transforms the enum to a boolean.
  bool toBool() => id == 1;
}

/// {@tool placedef}
/// gtfs:Field Types:list:Date
/// {@end-tool}
class Date {
  /// The year of the date.
  final int year;

  /// The month of the date.
  final int month;

  /// The day of the date.
  final int day;

  /// Creates the date.
  const Date(this.year, this.month, this.day);

  /// Transforms into [DateTime].
  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  /// Parses the date as YYYYMMDD.
  static Date parse(String input) {
    return Date(
      int.parse(input.substring(0, 4)),
      int.parse(input.substring(4, 6)),
      int.parse(input.substring(6, 8)),
    );
  }

  /// Gets the [Date] component of a [DateTime].
  factory Date.fromDatetime(DateTime dateTime) =>
      Date(dateTime.year, dateTime.month, dateTime.day);

  /// Gets the current [Date].
  static Date now() => Date.fromDatetime(DateTime.now());

  @override
  String toString() =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  /// Gives the weekday of the date.
  String weekdayToString() => switch (toDateTime().weekday) {
    DateTime.monday => 'monday',
    DateTime.tuesday => 'tuesday',
    DateTime.wednesday => 'wednesday',
    DateTime.thursday => 'thursday',
    DateTime.friday => 'friday',
    DateTime.saturday => 'saturday',
    DateTime.sunday => 'sunday',
    _ => '',
  };

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  bool operator ==(Object other) {
    return other is Date && other.hashCode == hashCode;
  }
}

/// Represents a date range from [startDate] to [endDate] in which the [id]
/// service is operating.
class RegularService {
  /// {@tool placedef}
  /// gtfs:calendar.txt:table:service_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:monday:3
  /// {@end-tool}
  final OperatesOnDay monday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:tuesday:3
  /// {@end-tool}
  final OperatesOnDay tuesday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:wednesday:3
  /// {@end-tool}
  final OperatesOnDay wednesday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:thursday:3
  /// {@end-tool}
  final OperatesOnDay thursday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:friday:3
  /// {@end-tool}
  final OperatesOnDay friday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:saturday:3
  /// {@end-tool}
  final OperatesOnDay saturday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:monday:3
  /// {@end-tool}
  final OperatesOnDay sunday;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:start_date:3
  /// {@end-tool}
  final Date startDate;

  /// {@tool placedef}
  /// gtfs:calendar.txt:table:end_date:3
  /// {@end-tool}
  final Date endDate;

  /// Creates the object.
  const RegularService({
    required this.id,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
  });

  @override
  int get hashCode => Object.hash(
    id,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
    startDate,
    endDate,
  );

  @override
  bool operator ==(Object other) {
    return other is RegularService && other.hashCode == hashCode;
  }
}

/// The type of exception for the service availability.
enum ExceptionType implements RichlyNamedEnum {
  /// Service has been added for the specified date.
  added('Added', 'Service has been added for the specified date.', 1),

  /// Service has been removed for the specified date.
  removed('Removed', 'Service has been removed for the specified date.', 2);

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  /// Creates the object.
  const ExceptionType(this.displayName, this.description, this.id);

  /// Transforms the raw value to the enum value.
  static ExceptionType forId(int id) =>
      values.firstWhere((element) => element.id == id);

  /// Transforms the enum to a boolean.
  bool toBool() => id == 1;
}

/// Represents an exception when a single service is either added or removed.
class OccasionalService {
  /// {@tool placedef}
  /// gtfs:calendar_dates.txt:table:service_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:calendar_dates.txt:table:date:3
  /// {@end-tool}
  final Date date;

  /// {@tool placedef}
  /// gtfs:calendar_dates.txt:table:exception_type:3
  /// {@end-tool}
  final ExceptionType exceptionType;

  /// Creates the object.
  const OccasionalService({
    required this.id,
    required this.date,
    required this.exceptionType,
  });

  @override
  int get hashCode => Object.hash(id, date, exceptionType);

  @override
  bool operator ==(Object other) {
    return other is OccasionalService && other.hashCode == hashCode;
  }
}

/// The object responsible for both [regularCalendar] and [occasionalCalendar].
class Calendar {
  /// The regular calendar defines different date ranges and weekdays when
  /// services are added.
  final RegularCalendar? regularCalendar;

  /// The occasional calendar defines days when services are exceptionally add or removed.
  final OccasionalCalendar? occasionalCalendar;

  /// Creates the object.
  const Calendar({
    required this.regularCalendar,
    required this.occasionalCalendar,
  });

  /// All dates are inclusive.
  Future<Map<Date, Set<String>>> listServicesForDateRange(
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    final servicesForDays = <Date, Set<String>>{};

    var currentDateTime = startDateTime;
    while (currentDateTime.isBefore(endDateTime) ||
        currentDateTime.isAtSameMomentAs(endDateTime)) {
      servicesForDays[Date.fromDatetime(currentDateTime)] = {};
      currentDateTime = currentDateTime.add(Duration(days: 1));
    }

    await for (Map<String, String> service
        in regularCalendar?.streamRawResource(
              LoadCriterion(['start_date', 'end_date'], (requestedFields) {
                final startDate = Date.parse(requestedFields[0]!).toDateTime();
                final endDate = Date.parse(requestedFields[1]!).toDateTime();

                return (startDateTime.isAfter(startDate) ||
                        startDateTime.isAtSameMomentAs(startDate)) &&
                    (endDateTime.isBefore(endDate) ||
                        endDateTime.isAtSameMomentAs(endDate));
              }),
            ) ??
            Stream.empty()) {
      for (final dayToTest in servicesForDays.keys) {
        if (service[dayToTest.weekdayToString()] == '1') {
          servicesForDays[dayToTest]!.add(service['service_id']!);
        }
      }
    }

    await for (final OccasionalService occasionalService
        in occasionalCalendar?.streamResource(
              LoadCriterion(['date'], (requestedFields) {
                final date = Date.parse(requestedFields[0]!).toDateTime();

                return (date.isAfter(startDateTime) ||
                        date.isAtSameMomentAs(startDateTime)) &&
                    (date.isBefore(endDateTime) ||
                        date.isAtSameMomentAs(endDateTime));
              }),
            ) ??
            Stream.empty()) {
      if (occasionalService.exceptionType == ExceptionType.added) {
        servicesForDays[occasionalService.date]?.add(occasionalService.id);
      } else {
        servicesForDays[occasionalService.date]?.remove(occasionalService.id);
      }
    }

    return servicesForDays;
  }

  /// Lists all the services available for a day.
  Future<Set<String>> listServicesForDay(Date day) async {
    final dateTime = day.toDateTime();
    final availableRegularServies =
        (await regularCalendar?.listResource(
          LoadCriterion([day.weekdayToString(), 'start_date', 'end_date'], (
            requestedFields,
          ) {
            final startDateTime = Date.parse(requestedFields[1]!).toDateTime();
            final endDateTime = Date.parse(requestedFields[2]!).toDateTime();

            return requestedFields[0] == '1' &&
                (dateTime.isAfter(startDateTime) ||
                    dateTime.isAtSameMomentAs(startDateTime)) &&
                (dateTime.isBefore(endDateTime) ||
                    dateTime.isAtSameMomentAs(endDateTime));
          }),
        ))?.map((e) => e.id).toSet() ??
        {};
    final rawDay = day.toString().replaceAll('/', '');
    await for (final OccasionalService occasionalService
        in occasionalCalendar?.streamResource(
              LoadCriterion([
                'date',
              ], (requestedFields) => requestedFields[0] == rawDay),
            ) ??
            Stream.empty()) {
      if (occasionalService.exceptionType == ExceptionType.added) {
        availableRegularServies.add(occasionalService.id);
      } else {
        availableRegularServies.remove(occasionalService.id);
      }
    }

    return availableRegularServies;
  }
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:calendar.txt:2
/// {@end-tool}
class RegularCalendar extends SingleCsvLazyBinding<RegularService> {
  /// Creates the regular calendar.
  RegularCalendar({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = [
    FieldDefinition(
      'service_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Service ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'monday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'tuesday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'wednesday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'thursday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'friday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'saturday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'sunday',
      (dataset, header, fileLength) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'start_date',
      (dataset, header, fileLength) => true,
      type: const DateFieldType(),
    ),
    FieldDefinition(
      'end_date',
      (dataset, header, fileLength) => true,
      type: const DateFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
  static RegularService staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => RegularService(
      id: c('service_id'),
      monday: c('monday'),
      tuesday: c('tuesday'),
      wednesday: c('wednesday'),
      thursday: c('thursday'),
      friday: c('friday'),
      saturday: c('saturday'),
      sunday: c('sunday'),
      startDate: c('start_date'),
      endDate: c('end_date'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  RegularService transform(MapRecord record) => staticTransform(record);
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:calendar_dates.txt:2
/// {@end-tool}
class OccasionalCalendar extends SingleCsvLazyBinding<OccasionalService> {
  /// Creates the occasional calendar.
  OccasionalCalendar({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = [
    FieldDefinition(
      'service_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Service ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'date',
      (dataset, header, fileLength) => true,
      type: DateFieldType(),
    ),
    FieldDefinition(
      'exception_type',
      (dataset, header, fileLength) => true,
      type: exceptionType,
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
  OccasionalService staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => OccasionalService(
      id: c('service_id'),
      date: c('date'),
      exceptionType: c('exception_type'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  OccasionalService transform(MapRecord record) => staticTransform(record);
}
