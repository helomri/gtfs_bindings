A utility package to read the contents of a GTFS Schedule dataset.


## Features
[//]: # (We do not use checkboxes because some renderers for the Dart doc don't support it)
- GTFS Schedule
  - Files
    - Basic files
      - ✅ agency.txt
      - ✅ stops.txt
      - ✅ routes.txt
      - ✅ trips.txt
      - ✅ stop_times.txt
      - ✅ calendar.txt
      - ✅ calendar_dates.txt
    - GTFS-Fares (V1 and V2)
      - ✅ fare_attributes.txt
      - ✅ fare_rules.txt
      - ✅ fare_media.txt
      - ✅ fare_products.txt
      - ✅ rider_categories.txt
      - ✅ fare_leg_rules.txt
      - ✅ fare_leg_join_rules.txt
      - ✅ fare_transfer_rules.txt
      - ✅ timeframes.txt
      - ✅ networks.txt
      - ✅ route_networks.txt
      - ✅ areas.txt
      - ✅ stop_areas.txt
    <details>
      <summary>Unsupported files (WIP)</summary>
  
      - ❌ shapes.txt
      - ❌ frequencies.txt
      - ❌ transfers.txt
      - ❌ pathways.txt
      - ❌ levels.txt
      - ❌ location_groups.txt
      - ❌ location_group_stops.txt
      - ❌ locations.geojson
      - ❌ booking_rules.txt
      - ❌ translations.txt
      - ❌ feed_info.txt
      - ❌ attributions.txt
      </details>
  - Features
    - ✅ Load data from any supported file using query parameters
    - ✅ List services for one or more days
    - ✅ Works with streamed data
    - ✅ List directions for a route
    - ✅ See next departures from a stop
- ❌ GTFS Realtime
  

## Getting started

Add this package to your Dart/Flutter project :
```bash
dart pub add gtfs_bindings
```
```bash
flutter pub add gtfs_bindings
```

## Usage

### Schedule

Construct a ``GTFSDataset``, populate (load in memory) its primary bindings, enjoy.

```dart
import 'package:gtfs_bindings/schedule.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  final dataset = DownloadableDataset(uri); // Place the URL to the dataset here.
  await dataset.pipe(tempDir: await getTemporaryDirectory()); // Will download and cache the dataset (do not fill tempDir while on Web).
  await dataset.populateList(dataset.primaryBindings); // Will load the main small files into memory for faster access.
}
```

## Additional information

**WIP**: THIS IS NOT STABLE. The API may change at any instant. Please wait for 1.0.0 to start deeply integrating any
function. The actual APIs to query data are stable 
