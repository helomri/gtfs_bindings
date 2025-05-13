import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

final parser =
    ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Shows this message', negatable: false)
      ..addOption(
        'to-clone',
        help: 'The URL for which repository to clone.',
        mandatory: true,
      )
      ..addOption(
        'out-directory',
        help:
            'The directory path (local to the root of the package or absolute) in which the files of the repo are directly going to be placed.',
      );

Future<int> main(List<String> arguments) async {
  final results = parser.parse(arguments);
  if (results.flag('help')) {
    print(parser.usage);
    return 0;
  }

  final cloneUrl = Uri.parse(results.option('to-clone')!);
  final outDirectory = Directory(
    results.option('out-directory') ??
        '.${Platform.pathSeparator}${basenameWithoutExtension(cloneUrl.path)}',
  );

  late final ProcessResult result;

  if (outDirectory.existsSync()) {
    // In case the repo got edited.
    await Process.run('git', [
      'stash',
    ], workingDirectory: outDirectory.absolute.path);
    result = await Process.run('git', [
      'pull',
      '--rebase',
    ], workingDirectory: outDirectory.absolute.path);
  } else {
    result = await Process.run('git', [
      'clone',
      cloneUrl.toString(),
      outDirectory.absolute.path,
    ]);
  }

  if (result.exitCode != 0) {
    stderr.writeln(
      "Couldn't perform repository clone/pull and returned exit code ${result.exitCode}. Please check the following error:",
    );
    stderr.write(result.stderr);
    return 1;
  }

  stdout.writeln('Downloaded/updated repo!');

  return 0;
}
