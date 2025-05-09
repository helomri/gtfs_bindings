import 'package:gtfs_bindings/schedule.dart';
import 'package:intl/intl.dart';

class Time {
  final int hour;
  final int minute;
  final int second;

  Time(this.hour, this.minute, this.second);

  DateTime relativeToDateTime(DateTime date) {
    return date.copyWith(
      hour: hour,
      minute: minute,
      second: second,
      millisecond: 0,
      microsecond: 0,
    );
  }

  DateTime relativeToDate(Date date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
      second,
      0,
      0,
    );
  }

  static Time parse(String input) {
    final parsed = DateFormat('HH:mm:ss').parse(input);
    return Time(parsed.hour, parsed.minute, parsed.second);
  }
}

enum PickupType implements RichlyNamedEnum {
  scheduled('Regularly scheduled', 'Regularly scheduled pickup.', 0),
  notAvailable('No pickup', 'No pickup available.', 1),
  withPhone('Must phone agency', 'Must phone agency to arrange pickup.', 2),
  withDriver(
    'Must coordinate with driver',
    'Must coordinate with driver to arrange pickup.',
    3,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const PickupType(this.displayName, this.description, this.id);

  static PickupType forId(int id) =>
      values.firstWhere((element) => element.id == id, orElse: () => scheduled);
}

enum DropOffType implements RichlyNamedEnum {
  scheduled('Regularly scheduled', 'Regularly scheduled drop off.', 0),
  notAvailable('No pickup', 'No drop off available.', 1),
  withPhone('Must phone agency', 'Must phone agency to arrange drop off.', 2),
  withDriver(
    'Must coordinate with driver',
    'Must coordinate with driver to arrange drop off.',
    3,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const DropOffType(this.displayName, this.description, this.id);

  static DropOffType forId(int id) =>
      values.firstWhere((element) => element.id == id, orElse: () => scheduled);
}

enum ContinuousPickup implements RichlyNamedEnum {
  continuous('Continuous', 'Continuous stopping pickup.', 0),
  notAvailable('Not continuous', 'No continuous stopping pickup.', 1),
  withPhone(
    'Continuous, must phone agency',
    'Must phone agency to arrange continuous stopping pickup.',
    2,
  ),
  withDriver(
    'Continuous, must coordinate with driver',
    'Must coordinate with driver to arrange continuous stopping pickup.',
    3,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const ContinuousPickup(this.displayName, this.description, this.id);

  static ContinuousPickup forId(int id) => values.firstWhere(
    (element) => element.id == id,
    orElse: () => notAvailable,
  );
}

enum ContinuousDropOff implements RichlyNamedEnum {
  continuous('Continuous', 'Continuous stopping drop off.', 0),
  notAvailable('Not continuous', 'No continuous stopping drop off.', 1),
  withPhone(
    'Continuous, must phone agency',
    'Must phone agency to arrange continuous stopping drop off.',
    2,
  ),
  withDriver(
    'Continuous, must coordinate with driver',
    'Must coordinate with driver to arrange continuous stopping drop off.',
    3,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const ContinuousDropOff(this.displayName, this.description, this.id);

  static ContinuousDropOff forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

enum Timepoint implements RichlyNamedEnum {
  approximate('Approximate', 'Times are considered approximate.', 0),
  exact('Exact', 'Times are considered exact.', 1);

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const Timepoint(this.displayName, this.description, this.id);

  static Timepoint forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

class StopTime {
  final String tripId;
  final Time? arrivalTime;
  final Time? departureTime;
  final String? stopId;
  final String? locationGroupId;
  final String? locationId;
  final int stopSequence;
  final String? stopHeadsign;
  final Time? startPickupDropOffWindow;
  final Time? endPickupDropOffWindow;
  final PickupType? pickupType;
  final DropOffType? dropOffType;
  final ContinuousPickup? continuousPickup;
  final ContinuousDropOff? continuousDropOff;
  final double? shapeDistTraveled;
  final Timepoint? timepoint;
  final String? pickupBookingRuleId;
  final String? dropOffBookingRuleId;

  const StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.locationGroupId,
    required this.locationId,
    required this.stopSequence,
    required this.stopHeadsign,
    required this.startPickupDropOffWindow,
    required this.endPickupDropOffWindow,
    required this.pickupType,
    required this.dropOffType,
    required this.continuousPickup,
    required this.continuousDropOff,
    required this.shapeDistTraveled,
    required this.timepoint,
    required this.pickupBookingRuleId,
    required this.dropOffBookingRuleId,
  });

  @override
  int get hashCode => Object.hash(
    tripId,
    arrivalTime,
    departureTime,
    stopId,
    locationGroupId,
    locationId,
    stopSequence,
    stopHeadsign,
    startPickupDropOffWindow,
    endPickupDropOffWindow,
    pickupType,
    dropOffType,
    continuousPickup,
    continuousDropOff,
    shapeDistTraveled,
    timepoint,
    pickupBookingRuleId,
    dropOffBookingRuleId,
  );

  @override
  bool operator ==(Object other) {
    return other is Stop && other.hashCode == hashCode;
  }
}

class StopTimes extends SingleCsvLazyBinding<StopTime> {
  StopTimes({required super.resourceFile, super.data});

  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'trip_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Trip ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'arrival_time',
      (dataset, header, records) => null,
      type: const TimeFieldType(),
      shouldBeRequired: (dataset, header, record) {
        final timepoint =
            record.containsKey('timepoint')
                ? int.parse(record['timepoint']!)
                : null;
        if (timepoint == 1) {
          return true;
        }
        // TODO: Add first/last stop_sequence validation.
        if (record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window')) {
          return false;
        }

        return null;
      },
    ),
    FieldDefinition(
      'departure_time',
      (dataset, header, records) => null,
      type: const TimeFieldType(),
      shouldBeRequired: (dataset, header, record) {
        final timepoint =
            record.containsKey('timepoint')
                ? int.parse(record['timepoint']!)
                : null;
        if (timepoint == 1) {
          return true;
        }
        if (record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window')) {
          return false;
        }

        return null;
      },
    ),
    FieldDefinition(
      'stop_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Stop ID'),
      shouldBeRequired:
          (dataset, header, record) =>
              !record.containsKey('location_group_id') &&
              !record.containsKey('location_id'),
    ),
    FieldDefinition(
      'location_group_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Location group ID'),
      shouldBeRequired:
          (dataset, header, record) =>
              record.containsKey('stop_id') || record.containsKey('location_id')
                  ? false
                  : null,
    ),
    FieldDefinition(
      'location_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Location ID'),
      shouldBeRequired:
          (dataset, header, record) =>
              record.containsKey('stop_id') ||
                      record.containsKey('location_group_id')
                  ? false
                  : null,
    ),
    FieldDefinition(
      'stop_sequence',
      (dataset, header, records) => true,
      type: IntegerFieldType(NumberConstraint.nonNegative),
    ),
    FieldDefinition(
      'stop_headsign',
      (dataset, header, records) => null,
      type: TextFieldType(),
    ),
    FieldDefinition(
      'start_pickup_drop_off_window',
      (dataset, header, records) => null,
      type: const TimeFieldType(),
      shouldBeRequired: (dataset, header, record) {
        if (record.containsKey('location_group_id') ||
            record.containsKey('location_id')) {
          return true;
        }
        if (record.containsKey('end_pickup_drop_off_window')) {
          return true;
        }
        if (record.containsKey('arrival_time') ||
            record.containsKey('departure_time')) {
          return false;
        }
        return null;
      },
    ),
    FieldDefinition(
      'end_pickup_drop_off_window',
      (dataset, header, records) => null,
      type: const TimeFieldType(),
      shouldBeRequired: (dataset, header, record) {
        if (record.containsKey('location_group_id') ||
            record.containsKey('location_id')) {
          return true;
        }
        if (record.containsKey('start_pickup_drop_off_window')) {
          return true;
        }
        if (record.containsKey('arrival_time') ||
            record.containsKey('departure_time')) {
          return false;
        }
        return null;
      },
    ),
    FieldDefinition(
      'pickup_type',
      (dataset, header, records) => null,
      type: pickupType,
      shouldBeRequired: (dataset, header, record) {
        final dropOffWindowDefined =
            record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window');
        return dropOffWindowDefined &&
                ['', '0', '3'].contains(record['pickup_type'])
            ? false
            : null;
      },
      defaultValue: '0',
    ),
    FieldDefinition(
      'drop_off_type',
      (dataset, header, records) => null,
      type: dropOffType,
      shouldBeRequired: (dataset, header, record) {
        final dropOffWindowDefined =
            record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window');
        return dropOffWindowDefined &&
                ['', '0'].contains(record['drop_off_type'])
            ? false
            : null;
      },
      defaultValue: '0',
    ),
    FieldDefinition(
      'continuous_pickup',
      (dataset, header, records) => null,
      type: continuousPickup,
      shouldBeRequired: (dataset, header, record) {
        final dropOffWindowDefined =
            record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window');
        return dropOffWindowDefined ? false : null;
      },
      defaultValue: '1',
    ),
    FieldDefinition(
      'continuous_drop_off',
      (dataset, header, records) => null,
      type: continuousDropOff,
      shouldBeRequired: (dataset, header, record) {
        final dropOffWindowDefined =
            record.containsKey('start_pickup_drop_off_window') ||
            record.containsKey('end_pickup_drop_off_window');
        return dropOffWindowDefined ? false : null;
      },
      defaultValue: '1',
    ),
    FieldDefinition(
      'shape_dist_traveled',
      (dataset, header, records) => null,
      type: const FloatFieldType(NumberConstraint.nonNegative),
    ),
    FieldDefinition(
      'timepoint',
      (dataset, header, records) => null,
      type: timepoint,
    ),
    FieldDefinition(
      'pickup_booking_rule_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Pickup booking rule ID'),
    ),
    FieldDefinition(
      'drop_off_booking_rule_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Drop off booking rule ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  static StopTime staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => StopTime(
      tripId: c('trip_id'),
      arrivalTime: c('arrival_time'),
      departureTime: c('departure_time'),
      stopId: c('stop_id'),
      locationGroupId: c('location_group_id'),
      locationId: c('location_id'),
      stopSequence: c('stop_sequence'),
      stopHeadsign: c('stop_headsign'),
      startPickupDropOffWindow: c('start_pickup_drop_off_window'),
      endPickupDropOffWindow: c('end_pickup_drop_off_window'),
      pickupType: c('pickup_type'),
      dropOffType: c('drop_off_type'),
      continuousPickup: c('continuous_pickup'),
      continuousDropOff: c('continuous_drop_off'),
      shapeDistTraveled: c('shape_dist_traveled'),
      timepoint: c('timepoint'),
      pickupBookingRuleId: c('pickup_booking_rule_id'),
      dropOffBookingRuleId: c('drop_off_booking_rule_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  StopTime transform(MapRecord record) => staticTransform(record);

  Future<List<({StopTime time, Date date})>> listNextStopTimeForRoute(
    GtfsDataset dataset,
    Route route,
    Stop stop, {
    LoadCriterion? tripCriterion,
    LoadCriterion? stopTimesCriterion,
  }) async {
    late BaseCSVFile trips;
    final now = DateTime.now();
    final today = Date.fromDatetime(now);
    final next24Hours = now.add(Duration(days: 1));
    final tomorrow = Date.fromDatetime(next24Hours);
    Date currentTestingDay = today;

    final List<({StopTime time, Date date})> foundStopTimes = [];

    final defaultTripCriterion = LoadCriterion([
      'route_id',
    ], (requestedFields) => requestedFields[0] == route.id);
    if (tripCriterion == null) {
      tripCriterion = defaultTripCriterion;
    } else {
      tripCriterion = LoadCriterion.and(defaultTripCriterion, tripCriterion);
    }

    late List<Map<String, String>> currentTrips;

    final defaultStopTimesCriterion = LoadCriterion(
      ['trip_id', 'departure_time', 'stop_id'],
      (requestedFields) {
        if (!currentTrips.any(
              (element) => element['trip_id'] == requestedFields[0],
            ) ||
            requestedFields[2] != stop.id) {
          return false;
        }
        final time = Time.parse(
          requestedFields[1]!,
        ).relativeToDate(currentTestingDay);

        return time.isAfter(now) && time.isBefore(next24Hours);
      },
    );

    if (stopTimesCriterion == null) {
      stopTimesCriterion = defaultStopTimesCriterion;
    } else {
      stopTimesCriterion = LoadCriterion.and(
        defaultStopTimesCriterion,
        stopTimesCriterion,
      );
    }

    trips = await dataset.trips.listRawResource(criteria: tripCriterion);

    final totalActiveServices = await dataset.calendar.listServicesForDateRange(
      now,
      next24Hours,
    );

    for (final dayToTest in [today, tomorrow]) {
      currentTestingDay = dayToTest;
      currentTrips = trips
          .where(
            (element) =>
                totalActiveServices[dayToTest]!.contains(element['service_id']),
          )
          .toList(growable: false);

      await for (final stopTime in dataset.stopTimes.streamResource(
        stopTimesCriterion,
      )) {
        foundStopTimes.add((time: stopTime, date: currentTestingDay));
      }
    }

    return foundStopTimes;
  }

  Future<
    ({
      List<({StopTime time, Trip trip, Date date, String routeId})> stopTimes,
      Set<String> routeIds,
    })
  >
  listNextStopTimesForStop(
    GtfsDataset dataset,
    Stop stop, {
    LoadCriterion? tripCriterion,
    LoadCriterion? stopTimesCriterion,
  }) async {
    final now = DateTime.now();
    final today = Date.fromDatetime(now);
    final next24Hours = now.add(Duration(days: 1));
    final tomorrow = Date.fromDatetime(next24Hours);

    final Map<String, List<StopTime>> tripIdsToCheck = {};

    await for (final stopTime in dataset.stopTimes.streamResource(
      LoadCriterion.and(
        stopTimesCriterion ?? LoadCriterion.passAll(),
        LoadCriterion([
          'stop_id',
        ], (requestedFields) => requestedFields[0] == stop.id),
      ),
    )) {
      tripIdsToCheck[stopTime.tripId] =
          tripIdsToCheck[stopTime.tripId] ?? [stopTime];
    }

    final totalActiveServices = await dataset.calendar.listServicesForDateRange(
      now,
      next24Hours,
    );

    final List<({StopTime time, Trip trip, Date date, String routeId})>
    foundStopTimes = [];

    final Set<String> routeIds = {};

    await for (final trip in dataset.trips.streamResource(
      LoadCriterion.and(
        tripCriterion ?? LoadCriterion.passAll(),
        LoadCriterion([
          'trip_id',
        ], (requestedFields) => tripIdsToCheck.containsKey(requestedFields[0])),
      ),
    )) {
      for (final day in [today, tomorrow]) {
        if (totalActiveServices[day]!.contains(trip.serviceId)) {
          for (final stopTime in tripIdsToCheck[trip.id]!) {
            final departureTime = stopTime.departureTime!.relativeToDate(day);
            if ((departureTime.isAtSameMomentAs(now) ||
                    departureTime.isAfter(now)) &&
                (departureTime.isAtSameMomentAs(next24Hours) ||
                    departureTime.isBefore(next24Hours))) {
              routeIds.add(trip.routeId);
              foundStopTimes.add((
                time: stopTime,
                trip: trip,
                date: day,
                routeId: trip.routeId,
              ));
            }
          }
        }
      }
    }

    return (routeIds: routeIds, stopTimes: foundStopTimes);
  }
}
