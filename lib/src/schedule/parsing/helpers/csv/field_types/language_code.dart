import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

typedef LocaleLike = ({String languageCode, String? countryCode});

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

  const LanguageCodeFieldType();

  @override
  RegisteredFieldType get type => RegisteredFieldType.languageCode;
}
