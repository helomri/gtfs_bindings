import 'dart:async';

import 'package:gtfs_bindings/schedule.dart';

/// See https://github.com/flutter/flutter/blob/main/LICENSE for licensing.
/// Copyright 2014 The Flutter Authors. All rights reserved.
/// Use of this source code is governed by a BSD-style license that can be
/// found in the LICENSE file.
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

/// The type of transportation used on a route.
enum RouteType implements RichlyNamedEnum {
  /// Tram, Streetcar, Light rail. Any light rail or street level system within
  /// a metropolitan area.
  tramOrStreetcarOrLightRail(
    'Tram/Streetcar/Light rail',
    'Tram, Streetcar, Light rail. Any light rail or street level system within a metropolitan area.',
    0,
  ),

  /// Subway, Metro. Any underground rail system within a metropolitan area.
  subwayOrMetro(
    'Subway/Metro',
    'Subway, Metro. Any underground rail system within a metropolitan area.',
    1,
  ),

  /// Rail. Used for intercity or long-distance travel.
  rail('Rail', 'Rail. Used for intercity or long-distance travel.', 2),

  /// Bus. Used for short- and long-distance bus routes.
  bus('Bus', 'Bus. Used for short- and long-distance bus routes.', 3),

  /// Ferry. Used for short- and long-distance boat service.
  ferry('Ferry', 'Ferry. Used for short- and long-distance boat service.', 4),

  /// Cable tram. Used for street-level rail cars where the cable runs beneath
  /// the vehicle (e.g., cable car in San Francisco).
  cableTram(
    'Cable tram',
    'Cable tram. Used for street-level rail cars where the cable runs beneath the vehicle (e.g., cable car in San Francisco).',
    5,
  ),

  /// Aerial lift, suspended cable car (e.g., gondola lift, aerial tramway).
  /// Cable transport where cabins, cars, gondolas or open chairs are suspended
  /// by means of one or more cables.
  aerialLift(
    'Aerial lift',
    'Aerial lift, suspended cable car (e.g., gondola lift, aerial tramway). Cable transport where cabins, cars, gondolas or open chairs are suspended by means of one or more cables.',
    6,
  ),

  /// Funicular. Any rail system designed for steep inclines.
  funicular(
    'Funicular',
    'Funicular. Any rail system designed for steep inclines.',
    7,
  ),

  /// Trolleybus. Electric buses that draw power from overhead wires using poles.
  trolleybus(
    'Trolleybus',
    'Trolleybus. Electric buses that draw power from overhead wires using poles.',
    11,
  ),

  /// Monorail. Railway in which the track consists of a single rail or a beam.
  monorail(
    'Monorail',
    'Monorail. Railway in which the track consists of a single rail or a beam.',
    12,
  );

  @override
  final String displayName;
  @override
  final String description;

  /// The raw ID used in the dataset.
  final int id;

  const RouteType(this.displayName, this.description, this.id);

  /// Transforms the raw value to the enum value.
  static RouteType forId(int id) =>
      values.firstWhere((element) => element.id == id);
}

/// A route a group of trips that are displayed to riders as a single service.
class Route {
  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:agency_id:3
  /// {@end-tool}
  final String? agencyId;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_short_name:3
  /// {@end-tool}
  final String? shortName;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_long_name:3
  /// {@end-tool}
  final String? longName;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_desc:3
  /// {@end-tool}
  final String? description;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_type:3
  /// {@end-tool}
  final RouteType routeType;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_url:3
  /// {@end-tool}
  final Uri? url;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_color:3
  /// {@end-tool}
  final int? color;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_text_color:3
  /// {@end-tool}
  final int routeTextColor;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:route_sort_order:3
  /// {@end-tool}
  final int? routeSortOrder;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:continuous_pickup:3
  /// {@end-tool}
  final ContinuousPickup continuousPickup;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:continuous_drop_off:3
  /// {@end-tool}
  final ContinuousDropOff continuousDropOff;

  /// {@tool placedef}
  /// gtfs:routes.txt:table:network_id:3
  /// {@end-tool}
  final String? networkId;

  /// Creates the route.
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

/// {@tool placedef}
/// gtfs:2Dataset Files:table:routes.txt:2
/// {@end-tool}
class Routes extends SingleCsvLazyBinding<Route> {
  /// Creates the list of routes.
  Routes({required super.resourceFile, super.data});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final List<FieldDefinition> staticFieldDefinitions = [
    FieldDefinition(
      'route_id',
      (dataset, header, fileLength) => true,
      type: const IdFieldType(displayName: 'Route ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'agency_id',
      (dataset, header, fileLength) async =>
          await dataset.agencies.count() > 1 ? true : null,
      type: const IdFieldType(displayName: 'Agency ID'),
    ),
    FieldDefinition(
      'route_short_name',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              (record['route_long_name']?.isEmpty ?? true) ? true : null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_long_name',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              (record['route_short_name']?.isEmpty ?? true) ? true : null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_desc',
      (dataset, header, fileLength) => null,
      type: const TextFieldType(),
    ),
    FieldDefinition(
      'route_type',
      (dataset, header, fileLength) => true,
      type: routeType,
    ),
    FieldDefinition(
      'route_url',
      (dataset, header, fileLength) => null,
      type: const UrlFieldType(),
    ),
    FieldDefinition(
      'route_color',
      (dataset, header, fileLength) => null,
      type: const ColorFieldType(),
      defaultValue: 'FFFFFF',
    ),
    FieldDefinition(
      'route_text_color',
      (dataset, header, fileLength) => null,
      type: const ColorFieldType(),
      defaultValue: '000000',
    ),
    FieldDefinition(
      'route_sort_order',
      (dataset, header, fileLength) => null,
      type: const IntegerFieldType(NumberConstraint.nonNegative),
    ),
    // TODO: Check for stop_times.start/end_pickup_drop_off_window and see reference
    FieldDefinition(
      'continuous_pickup',
      (dataset, header, fileLength) => null,
      type: continuousPickup,
      defaultValue: '1',
    ),
    FieldDefinition(
      'continuous_drop_off',
      (dataset, header, fileLength) => null,
      type: continuousDropOff,
      defaultValue: '1',
    ),
    FieldDefinition(
      'network_id',
      (dataset, header, fileLength) =>
          dataset.fileNameList.contains('route_networks.txt') ? false : null,
      type: const IdFieldType(displayName: 'Network ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  /// Utility method to statically transform a [MapRecord] into the type of the
  /// binding.
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

  /// Lists all the different trip paths used by the route.
  Future<Set<RouteDirection>> listDirectionsForRoute(
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

/// A simple record that represents a single direction ID.
typedef RawDirectionId =
    ({List<String> stopIds, Set<String> headsigns, String tripId});

/// The direction of a route.
class RouteDirection {
  /// All the stops in order that are passed by the vehicle.
  final List<Stop> stops;

  /// The name of the route (its headsign).
  final String name;

  /// The trip IDs that go through those [stops] in this order.
  final List<String> tripIds;

  /// Creates the route direction.
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
