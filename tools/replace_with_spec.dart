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
    stdout.write(spec.readAsStringSync());
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
    stdout.write(sectionContent);
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
          stdout.writeln(cleanedLine[column]);
        } else {
          stdout.writeln(line);
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

        stdout.writeln(line.substring(keepList ? 0 : 2));

        if (start != null) break;
      }
    }
  }

  return 0;
}
