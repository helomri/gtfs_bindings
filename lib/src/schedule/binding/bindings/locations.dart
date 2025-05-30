import 'dart:async';
import 'dart:convert';

import 'package:geojson_vi/geojson_vi.dart';
import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';

/// Defines a zone where riders can request either pickup or drop off by
/// on-demand services.
class Location {
  /// {@tool placedef}
  /// gtfs:locations.geojson:table:    - id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:locations.geojson:table:        - stop_name:3
  /// {@end-tool}
  final String? name;

  /// {@tool placedef}
  /// gtfs:locations.geojson:table:        - stop_desc:3
  /// {@end-tool}
  final String? description;

  /// {@tool placedef}
  /// gtfs:locations.geojson:table:        - coordinates:3
  /// {@end-tool}
  final List<GeoJSONPolygon> polygons;

  /// Creates the object.
  const Location({
    required this.id,
    required this.name,
    required this.description,
    required this.polygons,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:locations.geojson:2
/// {@end-tool}
class Locations extends LazyBinding<Location> {
  /// Creates the list of locations.
  Locations({required this.resourceFile});

  /// The base file used to read parameters.
  final FileOpener resourceFile;

  /// The [data] that was populated by [forcePopulateAll].
  GeoJSONFeatureCollection? data;

  @override
  String get fileName => resourceFile.name;

  @override
  Future<void> forcePopulateAll({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    data = GeoJSONFeatureCollection.fromJSON(
      await utf8.decodeStream(resourceFile.stream()),
    );
  }

  @override
  Future<void> populateIfEmpty({
    bool doValidationChecks = false,
    GtfsDataset? dataset,
  }) async {
    if (data != null) return;

    return forcePopulateAll(
      doValidationChecks: doValidationChecks,
      dataset: dataset,
    );
  }

  @override
  Stream<Location> streamResourceUntil(
    Completer<void> cancellationSignal,
  ) async* {
    await populateIfEmpty();
    for (final location in data!.features.whereType<GeoJSONFeature>()) {
      final polygons = <GeoJSONPolygon>[];
      final geometry = location.geometry;
      if (geometry is GeoJSONPolygon) {
        polygons.add(geometry);
      } else if (geometry is GeoJSONMultiPolygon) {
        polygons.addAll(geometry.coordinates.map((e) => GeoJSONPolygon(e)));
      }

      yield Location(
        id: location.id,
        name: (location.properties ?? {})['stop_name'],
        description: (location.properties ?? {})['stop_desc'],
        polygons: polygons,
      );

      if (cancellationSignal.isCompleted) return;
    }
  }
}
