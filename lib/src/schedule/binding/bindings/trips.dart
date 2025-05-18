import 'package:gtfs_bindings/src/schedule/binding/bindings/stops.dart';
import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';

/// Whether the trip is going in a direction or "the" other.
enum DirectionId implements RichlyNamedEnum {
  /// Travel in one direction (e.g. outbound travel).
  firstDirection(
    'One direction',
    'Travel in one direction (e.g. outbound travel).',
    0,
  ),

  /// Travel in the opposite direction (e.g. inbound travel).
  oppositeDirection(
    'Opposite direction',
    'Travel in the opposite direction (e.g. inbound travel).',
    1,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const DirectionId(this.displayName, this.description, this.id);

  /// Transforms the raw value to the enum value.
  static DirectionId forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

/// The same as [WheelchairBoarding] but for a trip.
enum WheelchairAccessible implements RichlyNamedEnum {
  /// No accessibility information for the trip.
  noInfo('No information', 'No accessibility information for the trip.', 0),

  /// Vehicle being used on this particular trip can accommodate at least one rider in a wheelchair.
  accessible(
    'At least one rider in wheelchair',
    'Vehicle being used on this particular trip can accommodate at least one rider in a wheelchair.',
    1,
  ),

  /// No riders in wheelchairs can be accommodated on this trip.
  notAccessible(
    'No riders in wheelchairs',
    'No riders in wheelchairs can be accommodated on this trip.',
    2,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const WheelchairAccessible(this.displayName, this.description, this.id);
}

/// Whether bikes are allowed on the trip.
enum BikesAllowed implements RichlyNamedEnum {
  /// No accessibility information for the trip.
  noInfo('No information', 'No accessibility information for the trip.', 0),

  /// Vehicle being used on this particular trip can accommodate at least one bicycle.
  allowed(
    'At least one bicycle',
    'Vehicle being used on this particular trip can accommodate at least one bicycle.',
    1,
  ),

  /// No bicycles are allowed on this trip.
  notAllowed('No bicycles', 'No bicycles are allowed on this trip.', 2);

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const BikesAllowed(this.displayName, this.description, this.id);
}

/// A sequence of two or more stops that occur during a specific time period.
class Trip {
  /// {@tool placedef}
  /// gtfs:trips.txt:table:route_id:3
  /// {@end-tool}
  final String routeId;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:service_id:3
  /// {@end-tool}
  final String serviceId;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:trip_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:trip_headsign:3
  /// {@end-tool}
  final String? tripHeadsign;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:trip_short_name:3
  /// {@end-tool}
  final String? tripShortName;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:direction_id:3
  /// {@end-tool}
  final DirectionId? directionId;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:block_id:3
  /// {@end-tool}
  final String? blockId;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:shape_id:3
  /// {@end-tool}
  final String? shapeId;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:wheelchair_accessible:3
  /// {@end-tool}
  final WheelchairAccessible wheelchairAccessible;

  /// {@tool placedef}
  /// gtfs:trips.txt:table:bikes_allowed:3
  /// {@end-tool}
  final BikesAllowed bikesAllowed;

  /// Creates the trip.
  const Trip({
    required this.routeId,
    required this.serviceId,
    required this.id,
    required this.tripHeadsign,
    required this.tripShortName,
    required this.directionId,
    required this.blockId,
    required this.shapeId,
    required this.wheelchairAccessible,
    required this.bikesAllowed,
  });

  @override
  int get hashCode => Object.hash(
    routeId,
    serviceId,
    id,
    tripHeadsign,
    tripHeadsign,
    tripShortName,
    directionId,
    blockId,
    shapeId,
    wheelchairAccessible,
    bikesAllowed,
  );

  @override
  bool operator ==(Object other) {
    return other is Trip && other.hashCode == hashCode;
  }
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:trips.txt:2
/// {@end-tool}
class Trips extends SingleCsvLazyBinding<Trip> {
  /// Creates the list of trips.
  Trips({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'route_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Route ID'),
    ),
    FieldDefinition(
      'service_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Service ID'),
    ),
    FieldDefinition(
      'trip_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Trip ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'trip_headsign',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'trip_short_name',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'direction_id',
      (dataset, header, fileLength) => null,
      type: directionId,
    ),
    FieldDefinition(
      'block_id',
      (dataset, header, fileLength) => null,
      type: const IdFieldType(displayName: 'Block ID'),
    ),
    FieldDefinition(
      'shape_id',
      (dataset, header, fileLength) => null,
      shouldBeRequired: (dataset, header, record) async {
        final route =
            await dataset.routes
                .streamResource(
                  LoadCriterion(
                    ['route_id'],
                    (requestedFields) =>
                        requestedFields.single == record['route_id']!,
                  ),
                )
                .first;
        final stopTime =
            await dataset.stopTimes
                .streamResource(
                  LoadCriterion(
                    ['trip_id'],
                    (requestedFields) =>
                        requestedFields.single == record['trip_id']!,
                  ),
                )
                .first;
        return [
              route.continuousPickup.id,
              route.continuousDropOff.id,
              stopTime.continuousPickup?.id,
              stopTime.continuousDropOff?.id,
            ].contains(0)
            ? true
            : null;
      },
      type: const IdFieldType(displayName: 'Shape ID'),
    ),
    FieldDefinition(
      'wheelchair_accessible',
      (dataset, header, fileLength) => null,
      type: wheelchairAccessible,
    ),
    FieldDefinition(
      'bikes_allowed',
      (dataset, header, fileLength) => null,
      type: bikesAllowed,
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
  static Trip staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => Trip(
      routeId: c('route_id'),
      serviceId: c('service_id'),
      id: c('trip_id'),
      tripHeadsign: c('trip_headsign'),
      tripShortName: c('trip_short_name'),
      directionId: c('direction_id'),
      blockId: c('block_id'),
      shapeId: c('shape_id'),
      wheelchairAccessible: c('wheelchair_accessible'),
      bikesAllowed: c('bikes_allowed'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  Trip transform(MapRecord record) => staticTransform(record);
}
