/// Toolkit to parse and query GTFS Schedule datasets.
///
/// All available documentation is ripped from
/// https://gtfs.org/documentation/schedule/reference/
library;

export 'src/errors.dart';
export 'src/schedule/binding/bindings/agency.dart';
export 'src/schedule/binding/bindings/calendar.dart';
export 'src/schedule/binding/bindings/fares.dart';
export 'src/schedule/binding/bindings/locations.dart';
export 'src/schedule/binding/bindings/routes.dart';
export 'src/schedule/binding/bindings/shapes.dart';
export 'src/schedule/binding/bindings/stop_times.dart';
export 'src/schedule/binding/bindings/stops.dart';
export 'src/schedule/binding/bindings/trips.dart';
export 'src/schedule/binding/helpers/lazy_binding.dart';
export 'src/schedule/dataset.dart';
export 'src/schedule/dataset_types/archive.dart';
export 'src/schedule/dataset_types/directory.dart'
    if (dart.library.io) 'src/schedule/dataset_types/directory.dart';
export 'src/schedule/dataset_types/downloadable.dart'
    if (dart.library.io) 'src/schedule/dataset_types/downloadable_io.dart'
    if (dart.library.js_interop) 'src/schedule/dataset_types/downloadable_html.dart';
export 'src/schedule/dataset_types/raw.dart';
export 'src/schedule/parsing/helpers/csv/csv_parser.dart';
export 'src/schedule/parsing/helpers/csv/field_definition.dart';
// Field types
export 'src/schedule/parsing/helpers/csv/field_types/color.dart';
export 'src/schedule/parsing/helpers/csv/field_types/currency_amount.dart';
export 'src/schedule/parsing/helpers/csv/field_types/currency_code.dart';
export 'src/schedule/parsing/helpers/csv/field_types/date.dart';
export 'src/schedule/parsing/helpers/csv/field_types/email.dart';
export 'src/schedule/parsing/helpers/csv/field_types/enum.dart';
export 'src/schedule/parsing/helpers/csv/field_types/field_types.dart';
export 'src/schedule/parsing/helpers/csv/field_types/float.dart';
export 'src/schedule/parsing/helpers/csv/field_types/id.dart';
export 'src/schedule/parsing/helpers/csv/field_types/integer.dart';
export 'src/schedule/parsing/helpers/csv/field_types/language_code.dart';
export 'src/schedule/parsing/helpers/csv/field_types/latitude.dart';
export 'src/schedule/parsing/helpers/csv/field_types/longitude.dart';
export 'src/schedule/parsing/helpers/csv/field_types/phone_number.dart';
export 'src/schedule/parsing/helpers/csv/field_types/text.dart';
export 'src/schedule/parsing/helpers/csv/field_types/time.dart';
export 'src/schedule/parsing/helpers/csv/field_types/timezone.dart';
export 'src/schedule/parsing/helpers/csv/field_types/url.dart';
