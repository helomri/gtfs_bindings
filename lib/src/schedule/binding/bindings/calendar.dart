import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/date.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';

enum OperatesOnDay implements RichlyNamedEnum {
  available('Available', 'Service is available for days in the date range.', 1),
  notAvailable(
    'Unavailable',
    'Service is not available for all days in the date range.',
    0,
  );

  final int id;
  @override
  final String displayName;
  @override
  final String description;

  const OperatesOnDay(this.displayName, this.description, this.id);

  static OperatesOnDay forId(int id) =>
      values.firstWhere((element) => element.id == id);

  bool toBool() => id == 1;
}

class Date {
  final int year;
  final int month;
  final int day;

  Date(this.year, this.month, this.day);

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  static Date parse(String input) {
    return Date(
      int.parse(input.substring(0, 4)),
      int.parse(input.substring(4, 6)),
      int.parse(input.substring(6, 8)),
    );
  }

  static Date fromDatetime(DateTime dateTime) =>
      Date(dateTime.year, dateTime.month, dateTime.day);

  static Date now() => fromDatetime(DateTime.now());

  @override
  String toString() =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

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

class RegularService {
  final String id;
  final OperatesOnDay monday;
  final OperatesOnDay tuesday;
  final OperatesOnDay wednesday;
  final OperatesOnDay thursday;
  final OperatesOnDay friday;
  final OperatesOnDay saturday;
  final OperatesOnDay sunday;
  final Date startDate;
  final Date endDate;

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

enum ExceptionType implements RichlyNamedEnum {
  added('Added', 'Service has been added for the specified date.', 1),
  removed('Removed', 'Service has been removed for the specified date.', 2);

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const ExceptionType(this.displayName, this.description, this.id);

  static ExceptionType forId(int id) =>
      values.firstWhere((element) => element.id == id);

  bool toBool() => id == 1;
}

class OccasionalService {
  final String id;
  final Date date;
  final ExceptionType exceptionType;

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

class Calendar {
  final RegularCalendar? regularCalendar;
  final OccasionalCalendar? occasionalCalendar;

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

class RegularCalendar extends SingleCsvLazyBinding<RegularService> {
  RegularCalendar({required super.resourceFile, super.data});

  static final staticFieldDefinitions = [
    FieldDefinition(
      'service_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Service ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'monday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'tuesday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'wednesday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'thursday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'friday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'saturday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'sunday',
      (dataset, header, records) => true,
      type: operatesOnDay,
    ),
    FieldDefinition(
      'start_date',
      (dataset, header, records) => true,
      type: const DateFieldType(),
    ),
    FieldDefinition(
      'end_date',
      (dataset, header, records) => true,
      type: const DateFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

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

class OccasionalCalendar extends SingleCsvLazyBinding<OccasionalService> {
  OccasionalCalendar({required super.resourceFile, super.data});

  static final staticFieldDefinitions = [
    FieldDefinition(
      'service_id',
      (dataset, header, records) => true,
      type: IdFieldType(displayName: 'Service ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'date',
      (dataset, header, records) => true,
      type: DateFieldType(),
    ),
    FieldDefinition(
      'exception_type',
      (dataset, header, records) => true,
      type: exceptionType,
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

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
