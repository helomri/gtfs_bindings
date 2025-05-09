import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';
import 'package:intl/intl.dart';

class CurrencyCodeFieldType extends FieldType<NumberFormat> {
  @override
  NumberFormat transform(String raw) => NumberFormat.currency(name: raw);
  @override
  RegisteredFieldType get type => RegisteredFieldType.currencyCode;
}
