import 'package:gtfs_bindings/schedule.dart';

Future<void> main() async {
  // https://eu.ftp.opendatasoft.com/stif/GTFS/IDFM-gtfs.zip - Île de France
  // https://exs.tcar.cityway.fr/gtfs.aspx?key=OPENDATA&operatorCode=ASTUCE - Astuce
  final dataset = DownloadableDataset(
    Uri.parse(
      'https://exs.tcar.cityway.fr/gtfs.aspx?key=OPENDATA&operatorCode=ASTUCE',
    ),
  );
  await dataset.pipe(
    tempDir: '/tmp',
  ); // Preferably use path_provider's getTemporaryDirectory
  await dataset.populateList(dataset.bindings);
  print('${await dataset.routes.count()} routes were counted');
}
