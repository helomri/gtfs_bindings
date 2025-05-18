import 'dart:convert';
import 'dart:io';

import 'package:gtfs_bindings/src/schedule/binding/bindings/routes.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart';

const specFiles = {
  'gtfs': 'gtfs/spec/en/reference.md',
  'gtfs-rt': 'gtfs-realtime/spec/en/reference.md',
};

const minimumTableSignatures = {
  'gtfs': {
    ['File Name', 'Presence', 'Description']: 0,
    ['Field Name', 'Type', 'Presence', 'Description']: 0,
    [
      'route_id',
      'trip_id',
      'service_id',
      'block_id',
      '(first stop time)',
      '(last stop time)',
    ]: 1,
  },
  'gtfs-rt': {
    [
      '_**Field Name**_',
      '_**Type**_',
      '_**Required**_',
      '_**Cardinality**_',
      '_**Description**_',
    ]: 0,
    ['_**Value**_', '_**Comment**_']: 0,
    ['_**Value**_']: 0,
  },
};

const Map<Pattern, String> replacements = {
  r"[agency.txt](#agencytxt)": '[Agencies]',
  r"[stops.txt](#stopstxt)": '[Stops]',
  r"[routes.txt](#routestxt)": '[Routes]',
  r"[trips.txt](#tripstxt)": '[Trips]',
  r"[stop\_times.txt](#stop_timestxt)": '[StopTimes]',
  r"[stop_times.txt](#stop_timestxt)": '[StopTimes]',
  r"[calendar.txt](#calendartxt)": '[RegularCalendar]',
  r"[calenar\_dates.txt](#calendar_datestxt)": '[OccasionalCalendar]',
  r"[calenar_dates.txt](#calendar_datestxt)": '[OccasionalCalendar]',
  r"[fare\_attributes.txt](#fare_attributestxt)": '[FareAttributes]',
  r"[fare_attributes.txt](#fare_attributestxt)": '[FareAttributes]',
  r"[fare\_rules.txt](#fare_rulestxt)": '[FareRules]',
  r"[fare_rules.txt](#fare_rulestxt)": '[FareRules]',
  r"[timeframes.txt](#timeframestxt)": '[Timeframes]',
  r"[rider\_categories.txt](#rider_categoriestxt)": '[Timeframes]',
  r"[rider_categories.txt](#rider_categoriestxt)": '[Timeframes]',
  r"[fare\_media.txt](#fare_mediatxt)": '[FareMedias]',
  r"[fare_media.txt](#fare_mediatxt)": '[FareMedias]',
  r"[fare\_products.txt](#fare_productstxt)": '[FareProducts]',
  r"[fare_products.txt](#fare_productstxt)": '[FareProducts]',
  r"[fare\_leg\_rules.txt](#fare_leg_rulestxt)": '[FareLegRules]',
  r"[fare_leg_rules.txt](#fare_leg_rulestxt)": '[FareLegRules]',
  r"[fare_leg_join_rules.txt](#fare_leg_join_rulestxt)": '[FareLegJoinRules]',
  r"[fare\_transfer\_rules.txt](#fare_transfer_rulestxt)":
      '[FareTransferRules]',
  r"[fare_transfer_rules.txt](#fare_transfer_rulestxt)": '[FareTransferRules]',
  r"[areas.txt](#areastxt)": '[Areas]',
  r"[stop_areas.txt](#stop_areastxt)": '[StopAreas]',
  r"[networks.txt](#networkstxt)": '[Networks]',
  r"[route_networks.txt](#route_networkstxt)": '[RouteNetworks]',
  r"[shapes.txt](#shapestxt)": '[Shapes]',
  r"[frequencies.txt](#frequenciestxt)": '[Frequencies]',
  r"[transfers.txt](#transferstxt)": '[Transfers]',
  r"[pathways.txt](#pathwaystxt)": '[Pathways]',
  r"[levels.txt](#levelstxt)": '[Levels]',
  r"[location_groups.txt](#location_groupstxt)": '[LocationGroups]',
  r"[location_group_stops.txt](#location_group_stopstxt)":
      '[LocationGroupStops]',
  r"[locations.geojson](#locationsgeojson)": '[Locations]',
  r"[booking_rules.txt](#booking_rulestxt)": '[BookingRules]',
  r"[translations.txt](#translationstxt)": '[Translations]',
  r"[feed\_info.txt](#feed_infotxt)": '[FeedInfos]',
  r"[feed_info.txt](#feed_infotxt)": '[FeedInfos]',
  r"[attributions.txt](#attributionstxt)": '[Attributions]',
};

String replace(String initial) {
  replacements.forEach(
    (key, value) => initial = initial.replaceAll(key, value),
  );
  return initial;
}

Future<int> main(List<String> arguments) async {
  final repo = Directory(arguments[0]);
  final args = File(
    Platform.environment['INPUT']!,
  ).readAsStringSync().split(':');

  final file = args.removeAt(0);
  final spec = File(join(repo.absolute.path, specFiles[file]));

  if (!spec.existsSync()) {
    stderr.writeln("Couldn't find spec file $file at ${spec.absolute.path}.");
    return 1;
  }

  if (args.isEmpty) {
    stdout.write(replace(spec.readAsStringSync()));
  }

  String section = args.removeAt(0);
  int sectionLevel = 3;

  String sectionContent = '';

  if (section.startsWith(RegExp(r'\d'))) {
    sectionLevel = int.parse(section[0]);
    section = section.substring(1);
  }

  await for (final String content in spec.openRead().transform(utf8.decoder)) {
    int includeFrom = 0;

    if (sectionContent.isEmpty) {
      final match = '\n${'#' * sectionLevel} $section\n'.allMatches(content);

      if (match.isNotEmpty) {
        includeFrom = match.first.end;
      } else {
        continue;
      }
    }

    bool foundMatch = false;
    for (int i = sectionLevel; i > 1; i--) {
      final endSectionMatch = '\n${'#' * i} '.allMatches(content, includeFrom);
      if (endSectionMatch.isNotEmpty) {
        sectionContent += content.substring(
          includeFrom,
          endSectionMatch.first.start,
        );

        foundMatch = true;
        break;
      }
    }

    if (foundMatch) {
      break;
    } else {
      sectionContent += content.substring(includeFrom);
    }
  }

  if (args.isEmpty) {
    stdout.write(replace(sectionContent));
    return 0;
  }

  final elementGroup = args.removeAt(0);

  if (elementGroup.startsWith('table')) {
    final String? row = args.isEmpty ? null : args.removeAt(0);
    final int? column = args.isEmpty ? null : int.parse(args.removeAt(0));

    int tableId = (int.tryParse(elementGroup.substring(5)) ?? 1) - 1;
    int currentTableId = 0;
    int elementCount = -1;
    List<String>? tableSignature;
    for (final line in sectionContent.split('\n')) {
      if (!line.trimLeft().startsWith('|')) {
        if (tableSignature != null) {
          if (currentTableId == tableId) break;

          tableSignature = null;
          elementCount = -1;
          currentTableId++;
        }

        continue;
      }

      final cleanedLine = (line.trim().substring(1).split('|')
        ..removeWhere((element) => element.isEmpty));

      final simplifiedLine = cleanedLine
          .map(
            (e) => markdownToHtml(e).replaceAll(RegExp(r'<[^>]*>'), '').trim(),
          )
          .toList(growable: false);

      if (tableSignature != null && cleanedLine.length != elementCount) {
        if (currentTableId == tableId) break;

        tableSignature = null;
        elementCount = -1;
        currentTableId++;

        continue;
      } else if (tableSignature == null) {
        final signature = minimumTableSignatures[file]?.keys.firstWhere(
          (element) => listEquals(element, simplifiedLine),
          orElse: () => [],
        );

        if (signature?.isEmpty ?? true) continue;

        tableSignature = signature;
        elementCount = cleanedLine.length;
      }

      if (tableSignature != null && currentTableId == tableId) {
        if (row != null &&
            simplifiedLine[minimumTableSignatures[file]![tableSignature]!] !=
                row) {
          continue;
        }

        if (column != null) {
          stdout.writeln(replace(cleanedLine[column]));
        } else {
          stdout.writeln(replace(line));
        }
      }
    }
  } else if (elementGroup.startsWith('list')) {
    final String? start = args.isEmpty ? null : args.removeAt(0);
    bool keepList = elementGroup.substring(4).startsWith('k');
    int listId =
        (int.tryParse(elementGroup.substring(keepList ? 5 : 4)) ?? 1) - 1;
    int currentListId = 0;
    bool listStarted = false;
    for (final line in sectionContent.split(RegExp(r'\n|<br>'))) {
      if (!line.trim().startsWith(RegExp(r'[*-] '))) {
        if (listStarted) {
          if (currentListId == listId) break;

          listStarted = false;
          currentListId++;
        }

        continue;
      }

      listStarted = true;

      final simplifiedLine =
          markdownToHtml(
            line.trimLeft().substring(2),
          ).replaceAll(RegExp(r'<[^>]*>'), '').trim();
      if (currentListId == listId) {
        if (start != null && !simplifiedLine.startsWith(start)) continue;

        stdout.writeln(replace(line.substring(keepList ? 0 : 2)));

        if (start != null) break;
      }
    }
  } else if (elementGroup.startsWith('text')) {
    int paragraphId = (int.tryParse(elementGroup.substring(4)) ?? 1) - 1;
    int currentParagraphId = 0;
    for (final paragraph in sectionContent.split(RegExp(r'(\n|<br>){2}'))) {
      if (currentParagraphId == paragraphId) {
        stdout.writeln(replace(paragraph));
        break;
      }
      currentParagraphId++;
    }
  }

  return 0;
}
