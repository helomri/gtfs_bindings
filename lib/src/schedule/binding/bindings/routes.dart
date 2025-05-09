import 'dart:async';

import 'package:gtfs_bindings/schedule.dart';

// See https://github.com/flutter/flutter/blob/main/LICENSE for licensing.
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

enum RouteType implements RichlyNamedEnum {
  tramOrStreetcarOrLightRail(
    'Tram/Streetcar/Light rail',
    'Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area.',
    0,
  ),
  subwayOrMetro(
    'Subway/Metro',
    'Subway, Metro. Any underground rail system within a metropolitan area.',
    1,
  ),
  rail('Rail', 'Rail. Used for intercity or long-distance travel.', 2),
  bus('Bus', 'Bus. Used for short- and long-distance bus routes.', 3),
  ferry('Ferry', 'Ferry. Used for short- and long-distance boat service.', 4),
  cableTram(
    'Cable tram',
    'Cable tram. Used for street-level rail cars where the cable runs beneath the vehicle (e.g., cable car in San Francisco).',
    5,
  ),
  aerialLift(
    'Aerial lift',
    'Aerial lift, suspended cable car (e.g., gondola lift, aerial tramway). Cable transport where cabins, cars, gondolas or open chairs are suspended by means of one or more cables.',
    6,
  ),
  funicular(
    'Funicular',
    'Funicular. Any rail system designed for steep inclines.',
    7,
  ),
  trolleybus(
    'Trolleybus',
    'Trolleybus. Electric buses that draw power from overhead wires using poles.',
    11,
  ),
  monorail(
    'Monorail',
    'Monorail. Railway in which the track consists of a single rail or a beam.',
    12,
  );

  @override
  final String displayName;
  @override
  final String description;
  final int id;

  const RouteType(this.displayName, this.description, this.id);

  static RouteType forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

class Route {
  final String id;
  final String? agencyId;
  final String? shortName;
  final String? longName;
  final String? description;
  final RouteType routeType;
  final Uri? url;
  final int? color;
  final int routeTextColor;
  final int? routeSortOrder;
  final ContinuousPickup continuousPickup;
  final ContinuousDropOff continuousDropOff;
  final String? networkId;

  const Route({
    required this.id,
    required this.agencyId,
    required this.shortName,
    required this.longName,
    required this.description,
    required this.routeType,
    required this.url,
    required this.color,
    required this.routeTextColor,
    required this.routeSortOrder,
    required this.continuousPickup,
    required this.continuousDropOff,
    required this.networkId,
  });

  @override
  int get hashCode => Object.hash(
    id,
    agencyId,
    shortName,
    longName,
    description,
    routeType,
    url,
    color,
    routeTextColor,
    routeSortOrder,
    continuousPickup,
    continuousDropOff,
    networkId,
  );

  @override
  bool operator ==(Object other) {
    return other is Route && other.hashCode == hashCode;
  }
}

class Routes extends SingleCsvLazyBinding<Route> {
  Routes({required super.resourceFile, super.data});

  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'route_id',
      (dataset, header, records) => true,
      type: const IdFieldType(displayName: 'Route ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'agency_id',
      (dataset, header, records) async =>
          await dataset.agencies.count() > 1 ? true : null,
      type: const IdFieldType(displayName: 'Agency ID'),
    ),
    FieldDefinition(
      'route_short_name',
      (dataset, header, records) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              (record['route_long_name']?.isEmpty ?? true) ? true : null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_long_name',
      (dataset, header, records) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              (record['route_short_name']?.isEmpty ?? true) ? true : null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_desc',
      (dataset, header, records) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_type',
      (dataset, header, records) => true,
      type: routeType,
    ),
    FieldDefinition(
      'route_url',
      (dataset, header, records) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'route_color',
      (dataset, header, records) => null,
      type: const ColorFieldType(),
      defaultValue: 'FFFFFF',
    ),
    FieldDefinition(
      'route_text_color',
      (dataset, header, records) => null,
      type: const ColorFieldType(),
      defaultValue: '000000',
    ),
    FieldDefinition(
      'route_sort_order',
      (dataset, header, records) => null,
      type: const IntegerFieldType(NumberConstraint.nonNegative),
    ),
    // TODO: Check for stop_times.start/end_pickup_drop_off_window and see reference
    FieldDefinition(
      'continuous_pickup',
      (dataset, header, records) => null,
      type: continuousPickup,
      defaultValue: '1',
    ),
    FieldDefinition(
      'continuous_drop_off',
      (dataset, header, records) => null,
      type: continuousDropOff,
      defaultValue: '1',
    ),
    FieldDefinition(
      'network_id',
      (dataset, header, records) =>
          dataset.fileNameList.contains('route_networks.txt') ? false : null,
      type: const IdFieldType(displayName: 'Network ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  static Route staticTransform(MapRecord record) => ModelBuilder.build(
    (c) => Route(
      id: c('route_id'),
      agencyId: c('agency_id'),
      shortName: c('route_short_name'),
      longName: c('route_long_name'),
      description: c('route_desc'),
      routeType: c('route_type'),
      url: c('route_url'),
      color: c('route_color'),
      routeTextColor: c('route_text_color'),
      routeSortOrder: c('route_sort_order'),
      continuousPickup: c('continuous_pickup'),
      continuousDropOff: c('continuous_drop_off'),
      networkId: c('network_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  Route transform(MapRecord record) => staticTransform(record);

  Future<Set<RouteDirection>> listShapesForRoute(
    GtfsDataset dataset,
    Route route,
  ) async {
    final trips = (await dataset.trips.listResource(
      LoadCriterion([
        'route_id',
      ], (requestedFields) => requestedFields[0] == route.id),
    ));

    Map<RawDirectionId, Set<String>> rawRouteDirections = {};

    void addRawRouteDirection(RawDirectionId value) {
      final existingRawRouteDirection = rawRouteDirections.keys
          .cast<RawDirectionId?>()
          .firstWhere(
            (element) =>
                listEquals(element!.stopIds, value.stopIds) &&
                listEquals(
                  element.headsigns.toList(growable: false),
                  value.headsigns.toList(growable: false),
                ),
            orElse: () => null,
          );

      rawRouteDirections[existingRawRouteDirection ?? value] =
          (rawRouteDirections[existingRawRouteDirection] ?? <String>{})
            ..add(value.tripId);
    }

    String? currentTripId;
    Map<int, String> currentMarkedStopIds = {};
    Set<String> headsigns = {};

    final tripIds = trips.map((trip) => trip.id);
    await for (StopTime stopTime in dataset.stopTimes.streamResource(
      LoadCriterion([
        'trip_id',
      ], (requestedFields) => tripIds.contains(requestedFields[0])),
    )) {
      if (currentTripId == null) {
        currentTripId = stopTime.tripId;
        final firstHeadsign =
            trips
                .firstWhere((element) => element.id == currentTripId)
                .tripHeadsign;
        if (firstHeadsign != null) {
          headsigns.add(firstHeadsign);
        }
      } else if (currentTripId != stopTime.tripId) {
        final sortedStopIds = (currentMarkedStopIds.entries.toList(
          growable: false,
        )..sort(
          (a, b) => a.key.compareTo(b.key),
        )).map((e) => e.value).toList(growable: false);

        addRawRouteDirection((
          stopIds: sortedStopIds,
          headsigns: headsigns,
          tripId: currentTripId,
        ));

        currentTripId = stopTime.tripId;
        currentMarkedStopIds = {};
        headsigns = {};
        final headsign =
            trips
                .firstWhere((element) => element.id == currentTripId)
                .tripHeadsign;
        if (headsign != null) {
          headsigns.add(headsign);
        }
      }

      currentMarkedStopIds[stopTime.stopSequence] =
          stopTime.stopId!; // TODO: Make work with edge cases
      if (stopTime.stopHeadsign != null) {
        headsigns.add(stopTime.stopHeadsign!);
      }
    }

    final sortedStopIds = (currentMarkedStopIds.entries.toList(growable: false)
      ..sort(
        (a, b) => a.key.compareTo(b.key),
      )).map((e) => e.value).toList(growable: false);

    addRawRouteDirection((
      stopIds: sortedStopIds,
      headsigns: headsigns,
      tripId: currentTripId!,
    ));

    Set<String> presentStopIds = rawRouteDirections.keys.fold(
      <String>{},
      (previousValue, element) => previousValue..addAll(element.stopIds),
    );
    Map<String, Stop> stops = {};
    await for (AStop stop in dataset.stops.streamResource(
      LoadCriterion([
        'stop_id',
      ], (requestedFields) => presentStopIds.contains(requestedFields.single)),
    )) {
      stops[stop.id] =
          stop
              as Stop; // From the spec we know these are type 0 (stop/platform)
    }
    return rawRouteDirections.entries
        .map(
          (kp) => RouteDirection(
            stops: kp.key.stopIds.map((e) => stops[e]!).toList(growable: false),
            name: kp.key.headsigns.join(' / '),
            tripIds: kp.value.toList(growable: false),
          ),
        )
        .toSet();
  }
}

typedef RawDirectionId =
    ({List<String> stopIds, Set<String> headsigns, String tripId});

class RouteDirection {
  final List<Stop> stops;
  final String name;
  final List<String> tripIds;

  const RouteDirection({
    required this.stops,
    required this.name,
    required this.tripIds,
  });

  @override
  int get hashCode => Object.hash(stops, name, tripIds);

  @override
  bool operator ==(Object other) {
    return other is RouteDirection &&
        stops == other.stops &&
        name == other.name &&
        tripIds == other.tripIds;
  }
}
