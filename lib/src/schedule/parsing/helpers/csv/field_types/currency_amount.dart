import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:Currency amount
/// {@end-tool}
class CurrencyAmountFieldType extends FieldType<String> {
  @override
  String transform(String raw) => raw;

  @override
  RegisteredFieldType get type => RegisteredFieldType.currencyAmount;
}
