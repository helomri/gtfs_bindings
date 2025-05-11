import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/enum.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/latitude.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/longitude.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/text.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/timezone.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/url.dart';

/// The type of location the "stop" is.
enum LocationType implements RichlyNamedEnum {
  /// A location where passengers board or disembark from a transit vehicle. Is
  /// called a platform when defined within a `parent station`.
  stop(
    'Stop/Platform',
    'A location where passengers board or disembark from a transit vehicle. Is called a platform when defined within a parent station.',
    0,
  ),

  /// A physical structure or area that contains one or more platform.
  station(
    'Station',
    'A physical structure or area that contains one or more platform.',
    1,
  ),

  /// A location where passengers can enter or exit a station from the street.
  /// If an entrance/exit belongs to multiple stations, it may be linked by
  /// pathways to both, but the data provider must pick one of them as parent.
  entranceOrExit(
    'Entrance/Exit',
    'A location where passengers can enter or exit a station from the street. If an entrance/exit belongs to multiple stations, it may be linked by pathways to both, but the data provider must pick one of them as parent.',
    2,
  ),

  /// A location within a station, not matching any other location type, that
  /// may be used to link together pathways define in [pathways.txt](https://gtfs.org/documentation/schedule/reference/#pathwaystxt).
  generic(
    'Generic node',
    'A location within a station, not matching any other location type, that may be used to link together pathways define in pathways.txt.',
    3,
  ),

  /// A specific location on a platform, where passengers can board and/or
  /// alight vehicles.
  boardingArea(
    'Boarding area',
    'A specific location on a platform, where passengers can board and/or alight vehicles.',
    4,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const LocationType(this.displayName, this.description, this.id);
}

/// Whether a stop can accommodate wheelchair boarding.
enum WheelchairBoarding implements RichlyNamedEnum {
  /// No accessibility information for the stop.
  noInfo('No information', 'No accessibility information for the stop.', 0),

  /// Some vehicles at this stop can be boarded by a rider in a wheelchair.
  available(
    'Available',
    'Some vehicles at this stop can be boarded by a rider in a wheelchair.',
    1,
  ),

  /// Wheelchair boarding is not possible at this stop.
  notAvailable(
    'Not available',
    'Wheelchair boarding is not possible at this stop.',
    2,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const WheelchairBoarding(this.displayName, this.description, this.id);

  /// Transforms the raw value to the enum value.
  static WheelchairBoarding forId(int id) =>
      values.firstWhere((element) => element.id == id, orElse: () => noInfo);
}

/// A stop, whatever its type is.
class AStop {
  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_code:3
  /// {@end-tool}
  final String? code;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_name:3
  /// {@end-tool}
  final String? name;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:tts_stop_name:3
  /// {@end-tool}
  final String? ttsName;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_desc:3
  /// {@end-tool}
  final String? description;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_lat:3
  /// {@end-tool}
  final double? latitude;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_lon:3
  /// {@end-tool}
  final double? longitude;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:zone_id:3
  /// {@end-tool}
  final String? zoneId;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_url:3
  /// {@end-tool}
  final Uri? url;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:location_type:3
  /// {@end-tool}
  final LocationType locationType;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:parent_station:3
  /// {@end-tool}
  final String? parentStationId;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:stop_timezone:3
  /// {@end-tool}
  final String? timezone;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:wheelchair_boarding:3
  /// {@end-tool}
  final WheelchairBoarding wheelchairBoarding;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:level_id:3
  /// {@end-tool}
  final String? levelId;

  /// {@tool placedef}
  /// gtfs:stops.txt:table:platform_code:3
  /// {@end-tool}
  final String? platformCode;

  /// Creates the stop.
  const AStop({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.locationType,
    required this.parentStationId,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    locationType,
    parentStationId,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is AStop && other.hashCode == hashCode;
  }
}

/// A stop.
class Stop implements AStop {
  @override
  final String id;
  @override
  final String? code;
  @override
  final String name;
  @override
  final String? ttsName;
  @override
  final String? description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? zoneId;
  @override
  final Uri? url;
  @override
  final LocationType locationType = LocationType.stop;
  @override
  final String? parentStationId;
  @override
  final String? timezone;
  @override
  final WheelchairBoarding wheelchairBoarding;
  @override
  final String? levelId;
  @override
  final String? platformCode;

  /// Creates the stop.
  const Stop({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.parentStationId,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    parentStationId,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is Stop && other.hashCode == hashCode;
  }
}

/// A station.
class Station implements AStop {
  @override
  final String id;
  @override
  final String? code;
  @override
  final String name;
  @override
  final String? ttsName;
  @override
  final String? description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? zoneId;
  @override
  final Uri? url;
  @override
  final LocationType locationType = LocationType.station;
  @override
  final String? parentStationId = null;
  @override
  final String? timezone;
  @override
  final WheelchairBoarding wheelchairBoarding;
  @override
  final String? levelId;
  @override
  final String? platformCode;

  /// Creates the station.
  const Station({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is Station && other.hashCode == hashCode;
  }
}

/// An entrance/exit.
class EntranceOrExit implements AStop {
  @override
  final String id;
  @override
  final String? code;
  @override
  final String name;
  @override
  final String? ttsName;
  @override
  final String? description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? zoneId;
  @override
  final Uri? url;
  @override
  final LocationType locationType = LocationType.entranceOrExit;
  @override
  final String parentStationId;
  @override
  final String? timezone;
  @override
  final WheelchairBoarding wheelchairBoarding;
  @override
  final String? levelId;
  @override
  final String? platformCode;

  /// Creates the entrance/exit.
  const EntranceOrExit({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.parentStationId,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    parentStationId,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is EntranceOrExit && other.hashCode == hashCode;
  }
}

/// A generic node.
class GenericNode implements AStop {
  @override
  final String id;
  @override
  final String? code;
  @override
  final String? name;
  @override
  final String? ttsName;
  @override
  final String? description;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? zoneId;
  @override
  final Uri? url;
  @override
  final LocationType locationType = LocationType.generic;
  @override
  final String parentStationId;
  @override
  final String? timezone;
  @override
  final WheelchairBoarding wheelchairBoarding;
  @override
  final String? levelId;
  @override
  final String? platformCode;

  /// Creates the generic node.
  const GenericNode({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.parentStationId,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    parentStationId,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is GenericNode && other.hashCode == hashCode;
  }
}

/// A boarding area.
class BoardingArea implements AStop {
  @override
  final String id;
  @override
  final String? code;
  @override
  final String name;
  @override
  final String? ttsName;
  @override
  final String? description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? zoneId;
  @override
  final Uri? url;
  @override
  final LocationType locationType = LocationType.boardingArea;
  @override
  final String parentStationId;
  @override
  final String? timezone;
  @override
  final WheelchairBoarding wheelchairBoarding;
  @override
  final String? levelId;
  @override
  final String? platformCode;

  /// Creates the boarding area.
  const BoardingArea({
    required this.id,
    required this.code,
    required this.name,
    required this.ttsName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.url,
    required this.parentStationId,
    required this.timezone,
    required this.wheelchairBoarding,
    required this.levelId,
    required this.platformCode,
  });

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    ttsName,
    description,
    latitude,
    longitude,
    zoneId,
    url,
    parentStationId,
    timezone,
    wheelchairBoarding,
    levelId,
    platformCode,
  );

  @override
  bool operator ==(Object other) {
    return other is BoardingArea && other.hashCode == hashCode;
  }
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:stops.txt:2
/// {@end-tool}
class Stops extends SingleCsvLazyBinding<AStop> {
  /// Creates the list of stops.
  Stops({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'stop_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Stop ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'stop_code',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_name',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
    ),
    FieldDefinition(
      'tts_stop_name',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_desc',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_lat',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
      type: const LatitudeFieldType(),
    ),
    FieldDefinition(
      'stop_lon',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
      type: const LongitudeDataType(),
    ),
    FieldDefinition(
      'zone_id',
      (dataset, header, fileLength) => null,
      type: const IdFieldType(displayName: 'Zone ID'),
    ),
    FieldDefinition(
      'stop_url',
      (dataset, header, fileLength) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'location_type',
      (dataset, header, fileLength) => null,
      type: locationIdField,
      defaultValue: '0',
    ),
    FieldDefinition(
      'parent_station',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              ['2', '3', '4'].contains(record['location_type'])
                  ? true
                  : (['', '0'].contains(record['location_type'])
                      ? null
                      : false),
      type: const IdFieldType(displayName: 'Stop ID'),
    ),
    FieldDefinition(
      'stop_timezone',
      (dataset, header, fileLength) => null,
      type: const TimezoneFieldType(),
    ),
    FieldDefinition(
      'wheelchair_boarding',
      (dataset, header, fileLength) => null,
      type: wheelchairBoarding,
      defaultValue: '0',
    ),
    FieldDefinition(
      'level_id',
      (dataset, header, fileLength) => null,
      type: const IdFieldType(displayName: 'Level ID'),
    ),
    FieldDefinition(
      'platform_code',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
  static AStop staticTransform(MapRecord record) => ModelBuilder.build(
    (c) {
      switch (c('location_type') as LocationType) {
        case LocationType.stop:
          {
            return Stop(
              id: c('stop_id'),
              code: c('stop_code'),
              name: c('stop_name'),
              ttsName: c('tts_stop_name'),
              description: c('stop_desc'),
              latitude: c('stop_lat'),
              longitude: c('stop_lon'),
              zoneId: c('zone_id'),
              url: c('stop_url'),
              parentStationId: c('parent_station'),
              timezone: c('stop_timezone'),
              wheelchairBoarding: c('wheelchair_boarding'),
              levelId: c('level_id'),
              platformCode: c('platform_code'),
            );
          }
        case LocationType.station:
          {
            return Station(
              id: c('stop_id'),
              code: c('stop_code'),
              name: c('stop_name'),
              ttsName: c('tts_stop_name'),
              description: c('stop_desc'),
              latitude: c('stop_lat'),
              longitude: c('stop_lon'),
              zoneId: c('zone_id'),
              url: c('stop_url'),
              timezone: c('stop_timezone'),
              wheelchairBoarding: c('wheelchair_boarding'),
              levelId: c('level_id'),
              platformCode: c('platform_code'),
            );
          }
        case LocationType.entranceOrExit:
          {
            return EntranceOrExit(
              id: c('stop_id'),
              code: c('stop_code'),
              name: c('stop_name'),
              ttsName: c('tts_stop_name'),
              description: c('stop_desc'),
              latitude: c('stop_lat'),
              longitude: c('stop_lon'),
              zoneId: c('zone_id'),
              url: c('stop_url'),
              parentStationId: c('parent_station'),
              timezone: c('stop_timezone'),
              wheelchairBoarding: c('wheelchair_boarding'),
              levelId: c('level_id'),
              platformCode: c('platform_code'),
            );
          }
        case LocationType.generic:
          {
            return GenericNode(
              id: c('stop_id'),
              code: c('stop_code'),
              name: c('stop_name'),
              ttsName: c('tts_stop_name'),
              description: c('stop_desc'),
              latitude: c('stop_lat'),
              longitude: c('stop_lon'),
              zoneId: c('zone_id'),
              url: c('stop_url'),
              parentStationId: c('parent_station'),
              timezone: c('stop_timezone'),
              wheelchairBoarding: c('wheelchair_boarding'),
              levelId: c('level_id'),
              platformCode: c('platform_code'),
            );
          }
        case LocationType.boardingArea:
          {
            return BoardingArea(
              id: c('stop_id'),
              code: c('stop_code'),
              name: c('stop_name'),
              ttsName: c('tts_stop_name'),
              description: c('stop_desc'),
              latitude: c('stop_lat'),
              longitude: c('stop_lon'),
              zoneId: c('zone_id'),
              url: c('stop_url'),
              parentStationId: c('parent_station'),
              timezone: c('stop_timezone'),
              wheelchairBoarding: c('wheelchair_boarding'),
              levelId: c('level_id'),
              platformCode: c('platform_code'),
            );
          }
      }
    },
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  AStop transform(MapRecord record) => staticTransform(record);
}
