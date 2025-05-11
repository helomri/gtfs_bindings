import 'package:gtfs_bindings/src/schedule/parsing/helpers/csv/field_types/field_types.dart';

/// {@tool placedef}
/// gtfs:Field Types:list:ID
/// {@end-tool}
class IdFieldType extends FieldType<String> {
  @override
  final String displayName;

  /// Creates the field type.
  const IdFieldType({required this.displayName});

  @override
  String transform(String raw) => raw;

  @override
  RegisteredFieldType get type => RegisteredFieldType.id;
}

// TODO: Continuer ici: Ajouter des variables publiques aux classes pour ajouter du contexte pour l'app pour améliorer l'inspecteur.
