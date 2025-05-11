import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// The equivalent to a locale that can be used in the intl package.
typedef LocaleLike = ({String languageCode, String? countryCode});

/// {@tool placedef}
/// gtfs:Field Types:list:Language code
/// {@end-tool}
class LanguageCodeFieldType extends FieldType<LocaleLike> {
  @override
  LocaleLike transform(String raw) {
    if (raw.contains('-')) {
      return (
        languageCode: raw.split('-').first,
        countryCode: raw.split('-').last,
      );
    }

    return (languageCode: raw, countryCode: null);
  }

  /// Creates the field type.
  const LanguageCodeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.languageCode;
}
