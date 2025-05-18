import 'dart:async';

import 'package:gtfs_bindings/src/schedule/binding/bindings/fares.dart';
import 'package:gtfs_bindings/src/schedule/dataset.dart';
import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/csv_parser.dart';
import 'package:gtfs_bindings/src/schedule/parsing/parser.dart';

class FaresParser extends Parser {
  const FaresParser();

  @override
  FutureOr<GtfsDataset> initializeDataStream(
    GtfsDataset sourceDataset,
    Map<String, FileOpener> availableFiles,
  ) async {
    if ((await sourceDataset.routes.getHeader()).any(
      (element) => element.name == 'network_id',
    )) {
      if (availableFiles.containsKey('networks.txt')) {
        throw UnsupportedError(
          'Contains networks.txt but network_id is defined in routes.txt',
        );
      }
      if (availableFiles.containsKey('route_networks.txt')) {
        throw UnsupportedError(
          'Contains route_networks.txt but network_id is defined in routes.txt',
        );
      }
    }

    return sourceDataset
      ..fares = Fares(
        availableFiles.entries
            .map<FareCsvBinding>((e) {
              final MapEntry(key: name, value: resourceFile) = e;
              return switch (name) {
                'fare_attributes.txt' => FareAttributes(
                  resourceFile: resourceFile,
                ),
                'fare_rules.txt' => FareRules(resourceFile: resourceFile),
                'fare_media.txt' => FareMedias(resourceFile: resourceFile),
                'fare_products.txt' => FareProducts(resourceFile: resourceFile),
                'rider_categories.txt' => RiderCategories(
                  resourceFile: resourceFile,
                ),
                'fare_leg_rules.txt' => FareLegRules(
                  resourceFile: resourceFile,
                ),
                'fare_leg_join_rules.txt' => FareLegJoinRules(
                  resourceFile: resourceFile,
                ),
                'fare_transfer_rules.txt' => FareTransferRules(
                  resourceFile: resourceFile,
                ),
                'timeframes.txt' => Timeframes(resourceFile: resourceFile),
                'networks.txt' => Networks(resourceFile: resourceFile),
                'route_networks.txt' => RouteNetworks(
                  resourceFile: resourceFile,
                ),
                'areas.txt' => Areas(resourceFile: resourceFile),
                'stop_areas.txt' => StopAreas(resourceFile: resourceFile),
                _ => throw UnsupportedError('Unsupported file: $name'),
              };
            })
            .toList(growable: false),
      );
  }

  @override
  Map<String, bool> get listenedFiles => {
    'fare_attributes.txt': false,
    'fare_rules.txt': false,
    'fare_media.txt': false,
    'fare_products.txt': false,
    'rider_categories.txt': false,
    'fare_leg_rules.txt': false,
    'fare_leg_join_rules.txt': false,
    'fare_transfer_rules.txt': false,
    'timeframes.txt': false,
    'networks.txt': false,
    'route_networks.txt': false,
    'areas.txt': false,
    'stop_areas.txt': false,
  };
}
