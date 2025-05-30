import 'package:gtfs_bindings/src/schedule/binding/helpers/lazy_binding.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_definition.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/float.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/id.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/integer.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/latitude.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/longitude.dart';
import 'package:mgrs_dart/mgrs_dart.dart';

/// A single point which is part of a shape.
class ShapePoint {
  /// {@tool placedef}
  /// gtfs:shapes.txt:table:shape_id:3
  /// {@end-tool}
  final String shapeId;

  /// {@tool placedef}
  /// gtfs:shapes.txt:table:shape_pt_lat:3
  /// {@end-tool}
  /// {@tool placedef}
  /// gtfs:shapes.txt:table:shape_pt_lon:3
  /// {@end-tool}
  final LonLat pointPosition;

  /// {@tool placedef}
  /// gtfs:shapes.txt:table:shape_pt_sequence:3
  /// {@end-tool}
  final int sequence;

  /// {@tool placedef}
  /// gtfs:shapes.txt:table:shape_dist_traveled:3
  /// {@end-tool}
  final double shapeDistTraveled;

  /// Creates the shape point.
  const ShapePoint({
    required this.shapeId,
    required this.pointPosition,
    required this.sequence,
    required this.shapeDistTraveled,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:shapes.txt:2
/// {@end-tool}
class Shapes extends SingleCsvLazyBinding<ShapePoint> {
  /// Creates the list of shape points.
  Shapes({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'shape_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Shape ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'shape_pt_lat',
      (dataset, header, fileLength) => true,
      type: LatitudeFieldType(),
    ),
    FieldDefinition(
      'shape_pt_lon',
      (dataset, header, fileLength) => true,
      type: LongitudeDataType(),
    ),
    FieldDefinition(
      'shape_pt_sequence',
      (dataset, header, fileLength) => true,
      type: IntegerFieldType(NumberConstraint.nonNegative),
      primaryKey: true,
    ),
    FieldDefinition(
      'shape_dist_traveled',
      (dataset, header, fileLength) => null,
      type: FloatFieldType(NumberConstraint.nonNegative),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  ShapePoint transform(MapRecord record) => ModelBuilder.build(
    (c) => ShapePoint(
      shapeId: c('shape_id'),
      pointPosition: LonLat(lon: c('shape_pt_lon'), lat: c('shape_pt_lat')),
      sequence: c('shape_pt_sequence'),
      shapeDistTraveled: c('shape_dist_traveled'),
    ),
    fieldDefinitions: fieldDefinitions,
    record: record,
  );
}
