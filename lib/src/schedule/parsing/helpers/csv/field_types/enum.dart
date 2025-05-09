import 'package:gtfs_bindings/src/schedule/binding/bindings/calendar.dart';
import 'package:gtfs_bindings/src/schedule/binding/bindings/routes.dart';
import 'package:gtfs_bindings/src/schedule/binding/bindings/stop_times.dart';
import 'package:gtfs_bindings/src/schedule/binding/bindings/stops.dart';
import 'package:gtfs_bindings/src/schedule/binding/bindings/trips.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

abstract class RichlyNamedEnum {
  String get displayName;
  String get description;
}

class EnumFieldType<E extends RichlyNamedEnum> extends FieldType<E> {
  final Map<String, E> enumMap;
  @override
  final E? defaultValue;

  @override
  final String displayName;

  const EnumFieldType({
    required this.enumMap,
    required this.defaultValue,
    required this.displayName,
  });

  @override
  E transform(String raw) {
    if (enumMap.containsKey(raw)) {
      return enumMap[raw]!;
    }

    if (defaultValue != null) return defaultValue!;

    throw UnsupportedError("Couldn't map value $raw to an $E.");
  }

  @override
  RegisteredFieldType get type => RegisteredFieldType.eenum;
}

const locationIdField = EnumFieldType(
  enumMap: {
    '0': LocationType.stop,
    '1': LocationType.station,
    '2': LocationType.entranceOrExit,
    '3': LocationType.generic,
    '4': LocationType.boardingArea,
  },
  defaultValue: LocationType.stop,
  displayName: 'Location type',
);

const wheelchairBoarding = EnumFieldType(
  enumMap: {
    '0': WheelchairBoarding.noInfo,
    '1': WheelchairBoarding.available,
    '2': WheelchairBoarding.notAvailable,
  },
  defaultValue: WheelchairBoarding.noInfo,
  displayName: 'Wheelchair boarding',
);

const routeType = EnumFieldType(
  enumMap: {
    '0': RouteType.tramOrStreetcarOrLightRail,
    '1': RouteType.subwayOrMetro,
    '2': RouteType.rail,
    '3': RouteType.bus,
    '4': RouteType.ferry,
    '5': RouteType.cableTram,
    '6': RouteType.aerialLift,
    '7': RouteType.funicular,
    '11': RouteType.trolleybus,
    '12': RouteType.monorail,
  },
  defaultValue: RouteType.tramOrStreetcarOrLightRail,
  displayName: 'Route type',
);

const continuousPickup = EnumFieldType(
  enumMap: {
    '0': ContinuousPickup.continuous,
    '1': ContinuousPickup.notAvailable,
    '2': ContinuousPickup.withPhone,
    '3': ContinuousPickup.withDriver,
  },
  defaultValue: ContinuousPickup.notAvailable,
  displayName: 'Continuous pickup',
);

const continuousDropOff = EnumFieldType(
  enumMap: {
    '0': ContinuousDropOff.continuous,
    '1': ContinuousDropOff.notAvailable,
    '2': ContinuousDropOff.withPhone,
    '3': ContinuousDropOff.withDriver,
  },
  defaultValue: ContinuousDropOff.notAvailable,
  displayName: 'Continuous drop off',
);

const directionId = EnumFieldType(
  enumMap: {
    '0': DirectionId.firstDirection,
    '1': DirectionId.oppositeDirection,
  },
  defaultValue: null,
  displayName: 'Direction ID',
);

const wheelchairAccessible = EnumFieldType(
  enumMap: {
    '0': WheelchairAccessible.noInfo,
    '1': WheelchairAccessible.accessible,
    '2': WheelchairAccessible.notAccessible,
  },
  defaultValue: WheelchairAccessible.noInfo,
  displayName: 'Wheelchair accessible',
);

const bikesAllowed = EnumFieldType(
  enumMap: {
    '0': BikesAllowed.noInfo,
    '1': BikesAllowed.allowed,
    '2': BikesAllowed.notAllowed,
  },
  defaultValue: BikesAllowed.noInfo,
  displayName: 'Bikes allowed',
);

const pickupType = EnumFieldType(
  enumMap: {
    '0': PickupType.scheduled,
    '1': PickupType.notAvailable,
    '2': PickupType.withPhone,
    '3': PickupType.withDriver,
  },
  defaultValue: PickupType.scheduled,
  displayName: 'Pickup type',
);

const dropOffType = EnumFieldType(
  enumMap: {
    '0': DropOffType.scheduled,
    '1': DropOffType.notAvailable,
    '2': DropOffType.withPhone,
    '3': DropOffType.withDriver,
  },
  defaultValue: DropOffType.scheduled,
  displayName: 'Drop off type',
);

const timepoint = EnumFieldType(
  enumMap: {'0': Timepoint.approximate, '1': Timepoint.exact},
  defaultValue: Timepoint.exact,
  displayName: 'Timepoint',
);

const operatesOnDay = EnumFieldType(
  enumMap: {'1': OperatesOnDay.available, '0': OperatesOnDay.notAvailable},
  defaultValue: null,
  displayName: 'Operates on...',
);

const exceptionType = EnumFieldType(
  enumMap: {'1': ExceptionType.added, '2': ExceptionType.removed},
  defaultValue: null,
  displayName: 'Exception type',
);
