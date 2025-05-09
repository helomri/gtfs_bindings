import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';

enum DirectionId implements RichlyNamedEnum {
  firstDirection(
    'Back direction',
    'Travel in one direction (e.g. outbound travel).',
    0,
  ),
  oppositeDirection(
    'Forth direction',
    'Travel in the opposite direction (e.g. inbound travel).',
    1,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const DirectionId(this.displayName, this.description, this.id);

  static DirectionId forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

enum WheelchairAccessible implements RichlyNamedEnum {
  noInfo('No information', 'No accessibility information for the trip.', 0),
  accessible(
    'At least one rider in wheelchair',
    'Vehicle being used on this particular trip can accommodate at least one rider in a wheelchair.',
    1,
  ),
  notAccessible(
    'No riders in wheelchairs',
    'No riders in wheelchairs can be accommodated on this trip.',
    2,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const WheelchairAccessible(this.displayName, this.description, this.id);
}

enum BikesAllowed implements RichlyNamedEnum {
  noInfo('No information', 'No accessibility information for the trip.', 0),
  allowed(
    'At least one bicycle',
    'Vehicle being used on this particular trip can accommodate at least one bicycle.',
    1,
  ),
  notAllowed('No bicycles', 'No bicycles are allowed on this trip.', 2);

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const BikesAllowed(this.displayName, this.description, this.id);
}

class Trip {
  final String routeId;
  final String serviceId;
  final String id;
  final String? tripHeadsign;
  final String? tripShortName;
  final DirectionId? directionId;
  final String? blockId;
  final String? shapeId;
  final WheelchairAccessible wheelchairAccessible;
  final BikesAllowed bikesAllowed;

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

class Trips extends SingleCsvLazyBinding<Trip> {
  Trips({required super.resourceFile, super.data});

  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'route_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Route ID'),
    ),
    FieldDefinition(
      'service_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Service ID'),
    ),
    FieldDefinition(
      'trip_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Trip ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'trip_headsign',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'trip_short_name',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'direction_id',
      (dataset, header, records) => null,
      type: directionId,
    ),
    FieldDefinition(
      'block_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Block ID'),
    ),
    FieldDefinition(
      'shape_id',
      (dataset, header, records) => null,
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
      (dataset, header, records) => null,
      type: wheelchairAccessible,
    ),
    FieldDefinition(
      'bikes_allowed',
      (dataset, header, records) => null,
      type: bikesAllowed,
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

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
