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

enum LocationType implements RichlyNamedEnum {
  unknown('Unknown', '', -1),
  stop(
    'Stop/Platform',
    'A location where passengers board or disembark from a transit vehicle. Is called a platform when defined within a parent station.',
    0,
  ),
  station(
    'Station',
    'A physical structure or area that contains one or more platform.',
    1,
  ),
  entranceOrExit(
    'Entrance/Exit',
    'A location where passengers can enter or exit a station from the street. If an entrance/exit belongs to multiple stations, it may be linked by pathways to both, but the data provider must pick one of them as parent.',
    2,
  ),
  generic(
    'Generic node',
    'A location within a station, not matching any other location type, that may be used to link together pathways define in pathways.txt.',
    3,
  ),
  boardingArea(
    'Boarding area',
    'A specific location on a platform, where passengers can board and/or alight vehicles.',
    4,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const LocationType(this.displayName, this.description, this.id);
}

enum WheelchairBoarding implements RichlyNamedEnum {
  noInfo('No information', 'No accessibility information for the stop.', 0),
  available(
    'Available',
    'Some vehicles at this stop can be boarded by a rider in a wheelchair.',
    1,
  ),
  notAvailable(
    'Not available',
    'Wheelchair boarding is not possible at this stop.',
    2,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const WheelchairBoarding(this.displayName, this.description, this.id);

  static WheelchairBoarding forId(int id) =>
      values.firstWhere((element) => element.id == id, orElse: () => noInfo);
}

class AStop {
  final String id;
  final String? code;
  final String? name;
  final String? ttsName;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? zoneId;
  final Uri? url;
  final LocationType locationType;
  final String? parentStationId;
  final String? timezone;
  final WheelchairBoarding wheelchairBoarding;
  final String? levelId;
  final String? platformCode;

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

class Stops extends SingleCsvLazyBinding<AStop> {
  Stops({required super.resourceFile, super.data});

  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'stop_id',
      (existingDataset, rawHeader, records) => true,
      type: const IdFieldType(displayName: 'Stop ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'stop_code',
      (existingDataset, rawHeader, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_name',
      (existingDataset, rawHeader, records) => null,
      type: const TextFieldType(),
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
    ),
    FieldDefinition(
      'tts_stop_name',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_desc',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'stop_lat',
      (dataset, header, records) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
      type: const LatitudeFieldType(),
    ),
    FieldDefinition(
      'stop_lon',
      (dataset, header, records) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              ['', '0', '1', '2'].contains(record['location_type'])
                  ? true
                  : null,
      type: const LongitudeDataType(),
    ),
    FieldDefinition(
      'zone_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Zone ID'),
    ),
    FieldDefinition(
      'stop_url',
      (dataset, header, records) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'location_type',
      (dataset, header, records) => null,
      type: locationIdField,
      defaultValue: '0',
    ),
    FieldDefinition(
      'parent_station',
      (dataset, header, records) => null,
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
      (dataset, header, records) => null,
      type: const TimezoneFieldType(),
    ),
    FieldDefinition(
      'wheelchair_boarding',
      (dataset, header, records) => null,
      type: wheelchairBoarding,
      defaultValue: '0',
    ),
    FieldDefinition(
      'level_id',
      (dataset, header, records) => null,
      type: const IdFieldType(displayName: 'Level ID'),
    ),
    FieldDefinition(
      'platform_code',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

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
        default:
          {
            return AStop(
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
              locationType: c('location_type'),
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
