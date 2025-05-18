import 'package:gtfs_bindings/schedule.dart';

/// An object used to specify query filters when dealing with CSV data.
///
/// An additional version header is present to know in which GTFS-Fares version
/// this file is present.
abstract class FareCsvBinding<T> extends SingleCsvLazyBinding<T> {
  /// Creates the binding.
  FareCsvBinding({required super.resourceFile});

  /// Gets the version of GTFS-Fare in which this file is involved.
  FareVersion get version;
}

/// A fare version (GTFS-Fares V1 or GTFS-Fares V2).
enum FareVersion {
  /// The first version of GTFS-Fares, contains the following files:
  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:listk1
  /// {@end-tool}
  one,

  /// The second (and latest) version of GTFS-Fares, contains the following
  /// files:
  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:listk2
  /// {@end-tool}
  two,
}

/// The object responsible for all information about fares.
class Fares {
  /// The bindings present.
  /// These include :
  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:listk1
  /// {@end-tool}
  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:listk2
  /// {@end-tool}
  final List<FareCsvBinding> bindings;

  // V1
  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_attributes.txt:2
  /// {@end-tool}
  FareAttributes? get fareAttributes =>
      bindings.whereType<FareAttributes>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_rules.txt:2
  /// {@end-tool}
  FareRules? get fareRules => bindings.whereType<FareRules>().singleOrNull;

  // V2
  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_media.txt:2
  /// {@end-tool}
  FareMedias? get fareMedia => bindings.whereType<FareMedias>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_products.txt:2
  /// {@end-tool}
  FareProducts? get fareProducts =>
      bindings.whereType<FareProducts>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:rider_categories.txt:2
  /// {@end-tool}
  RiderCategories? get riderCategories =>
      bindings.whereType<RiderCategories>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_leg_rules.txt:2
  /// {@end-tool}
  FareLegRules? get fareLegRules =>
      bindings.whereType<FareLegRules>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_leg_join_rules.txt:2
  /// {@end-tool}
  FareLegJoinRules? get fareLegJoinRules =>
      bindings.whereType<FareLegJoinRules>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:fare_transfer_rules.txt:2
  /// {@end-tool}
  FareTransferRules? get fareTransferRules =>
      bindings.whereType<FareTransferRules>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:timeframes.txt:2
  /// {@end-tool}
  Timeframes? get timeframes => bindings.whereType<Timeframes>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:networks.txt:2
  /// {@end-tool}
  Networks? get networks => bindings.whereType<Networks>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:route_networks.txt:2
  /// {@end-tool}
  RouteNetworks? get routeNetworks =>
      bindings.whereType<RouteNetworks>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:areas.txt:2
  /// {@end-tool}
  Areas? get areas => bindings.whereType<Areas>().singleOrNull;

  /// {@tool placedef}
  /// gtfs:2Dataset Files:table:stop_areas.txt:2
  /// {@end-tool}
  StopAreas? get stopAreas => bindings.whereType<StopAreas>().singleOrNull;

  /// Creates the fares list.
  const Fares(this.bindings);

  /// All the versions of GTFS-Fares present in the dataset.
  Set<FareVersion> get presentVersions =>
      bindings.map((e) => e.version).toSet();
}

/// The way the fare is paid.
enum PaymentMethod implements RichlyNamedEnum {
  /// Fare is paid on board.
  paidOnBoard('Paid on board', 'Fare is paid on board.'),

  /// Fare must be paid before boarding.
  paidBeforeOnboarding(
    'Paid before onboarding',
    'Fare must be paid before boarding.',
  );

  const PaymentMethod(this.displayName, this.description);

  @override
  final String description;

  @override
  final String displayName;
}

/// The transfer policy the operator uses.
enum TransferPolicy implements RichlyNamedEnum {
  /// No transfers permitted on this fare.
  noTransfers('No transfers', 'No transfers permitted on this fare.'),

  /// Riders may transfer once.
  oneTransfer('One transfer', 'Riders may transfer once.'),

  /// Riders may transfer twice.
  twoTransfers('Two transfers', 'Riders may transfer twice.'),

  /// Unlimited transfers are permitted.
  unlimitedTransfers(
    'Unlimited transfers',
    'Unlimited transfers are permitted.',
  );

  const TransferPolicy(this.displayName, this.description);

  @override
  final String description;

  @override
  final String displayName;
}

/// Represents basic fare attributes assigned to a [fareId].
class FareAttribute {
  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:fare_id:3
  /// {@end-tool}
  final String fareId;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:price:3
  /// {@end-tool}
  final double price;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:currency_type:3
  /// {@end-tool}
  final String currencyCode;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:payment_method:3
  /// {@end-tool}
  final PaymentMethod paymentMethod;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:transfers:3
  /// {@end-tool}
  final TransferPolicy transfers;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:agency_id:3
  /// {@end-tool}
  final String? agencyId;

  /// {@tool placedef}
  /// gtfs:fare_attributes.txt:table:transfer_duration:3
  /// {@end-tool}
  final int? transferDuration;

  /// Creates the object.
  const FareAttribute({
    required this.fareId,
    required this.price,
    required this.currencyCode,
    required this.paymentMethod,
    required this.transfers,
    required this.agencyId,
    required this.transferDuration,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_attributes.txt:2
/// {@end-tool}
class FareAttributes extends FareCsvBinding<FareAttribute> {
  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'fare_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Fare ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'price',
      (dataset, header, fileLength) => true,
      type: FloatFieldType(NumberConstraint.nonNegative),
    ),
    FieldDefinition(
      'currency_type',
      (dataset, header, fileLength) => true,
      type: CurrencyCodeFieldType(),
    ),
    FieldDefinition(
      'payment_method',
      (dataset, header, fileLength) => true,
      type: EnumFieldType(
        enumMap: {
          '0': PaymentMethod.paidOnBoard,
          '1': PaymentMethod.paidBeforeOnboarding,
        },
        defaultValue: null,
        displayName: 'Payment method',
      ),
    ),
    FieldDefinition(
      'transfers',
      (dataset, header, fileLength) => true,
      type: EnumFieldType(
        enumMap: {
          '0': TransferPolicy.noTransfers,
          '1': TransferPolicy.oneTransfer,
          '2': TransferPolicy.twoTransfers,
        },
        defaultValue: TransferPolicy.unlimitedTransfers,
        displayName: 'Transfer policy',
      ),
    ),
    FieldDefinition(
      'agency_id',
      (dataset, header, fileLength) async =>
          (await dataset.agencies.count()) > 1 ? true : null,
      type: IdFieldType(displayName: 'Agency ID'),
    ),
    FieldDefinition(
      'transfer_duration',
      (dataset, header, fileLength) async => null,
      type: IntegerFieldType(NumberConstraint.nonNegative),
    ),
  ];

  /// Creates the list of fare attributes.
  FareAttributes({required super.resourceFile});

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareAttribute transform(MapRecord record) => ModelBuilder.build(
    (c) => FareAttribute(
      fareId: c('fare_id'),
      price: c('price'),
      currencyCode: c('currency_type'),
      paymentMethod: c('payment_method'),
      transfers: c('transfers'),
      agencyId: c('agency_id'),
      transferDuration: c('transfer_duration'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.one;
}

/// Rule to apply for itineraries.
class FareRule {
  /// {@tool placedef}
  /// gtfs:fare_rules.txt:table:fare_id:3
  /// {@end-tool}
  final String fareId;

  /// {@tool placedef}
  /// gtfs:fare_rules.txt:table:route_id:3
  /// {@end-tool}
  final String routeId;

  /// {@tool placedef}
  /// gtfs:fare_rules.txt:table:origin_id:3
  /// {@end-tool}
  final String originId;

  /// {@tool placedef}
  /// gtfs:fare_rules.txt:table:destination_id:3
  /// {@end-tool}
  final String destinationId;

  /// {@tool placedef}
  /// gtfs:fare_rules.txt:table:contains_id:3
  /// {@end-tool}
  final String containsId;

  /// Creates the object.
  const FareRule({
    required this.fareId,
    required this.routeId,
    required this.originId,
    required this.destinationId,
    required this.containsId,
  });
}

/// {@tool placedef}
/// gtfs:fare_rules.txt:text3
/// {@end-tool}
///
/// {@tool placedef}
/// gtfs:fare_rules.txt:listk
/// {@end-tool}
///
/// {@tool placedef}
/// gtfs:fare_rules.txt:text5
/// {@end-tool}
class FareRules extends FareCsvBinding<FareRule> {
  /// Creates the list of fare rules.
  FareRules({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'fare_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Fare ID'),
    ),
    FieldDefinition(
      'route_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Route ID'),
    ),
    FieldDefinition(
      'origin_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Zone ID'),
    ),
    FieldDefinition(
      'destination_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Zone ID'),
    ),
    FieldDefinition(
      'contains_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Zone ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareRule transform(MapRecord record) => ModelBuilder.build(
    (c) => FareRule(
      fareId: c('record_id'),
      routeId: c('route_id'),
      originId: c('origin_id'),
      destinationId: c('destination_id'),
      containsId: c('contains_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.one;
}

/// Describes fare media that ca nbe employed to use fare products. Fare media
/// are physical or virtual holders used for the representation and/or
/// validation of a fare product.
class FareMedia {
  /// {@tool placedef}
  /// gtfs:fare_media.txt:table:fare_media_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:fare_media.txt:table:fare_media_name:3
  /// {@end-tool}
  final String? name;

  /// {@tool placedef}
  /// gtfs:fare_media.txt:table:fare_media_type:3
  /// {@end-tool}
  final FareMediaType type;

  /// Creates the object.
  const FareMedia({required this.id, required this.name, required this.type});
}

/// The type of fare media.
enum FareMediaType implements RichlyNamedEnum {
  /// Used when there is no fare media involved in purchasing or validating a fare product, such as paying cash to a driver or conductor with no physical ticket provided.
  none(
    'None',
    'Used when there is no fare media involved in purchasing or validating a fare product, such as paying cash to a driver or conductor with no physical ticket provided.',
  ),

  /// Physical paper ticket that allows a passenger to take either a certain number of pre-purchased trips or unlimited trips within a fixed period of time.
  physicalPaperTicket(
    'Physical paper ticket',
    'Physical paper ticket that allows a passenger to take either a certain number of pre-purchased trips or unlimited trips within a fixed period of time.',
  ),

  /// Physical transit card that has stored tickets, passes or monetary value.
  physicalTransitCard(
    'Physical transit card',
    'Physical transit card that has stored tickets, passes or monetary value.',
  ),

  /// cEMV (contactless Europay, Mastercard and Visa) as an open-loop token container for account-based ticketing.
  cEMV(
    'cEMV',
    'cEMV (contactless Europay, Mastercard and Visa) as an open-loop token container for account-based ticketing.',
  ),

  /// Mobile app that have stored virtual transit cards, tickets, passes, or monetary value.
  mobileApp(
    'Mobile app',
    'Mobile app that have stored virtual transit cards, tickets, passes, or monetary value.',
  );

  const FareMediaType(this.displayName, this.description);

  @override
  final String displayName;
  @override
  final String description;
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_media.txt:2
/// {@end-tool}
class FareMedias extends FareCsvBinding<FareMedia> {
  /// Creates the list of fare media.
  FareMedias({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'fare_media_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Fare media ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'fare_media_name',
      (dataset, header, fileLength) => null,
      type: TextFieldType(),
    ),
    FieldDefinition(
      'fare_media_type',
      (dataset, header, fileLength) => true,
      type: EnumFieldType(
        enumMap: {
          '0': FareMediaType.none,
          '1': FareMediaType.physicalPaperTicket,
          '2': FareMediaType.physicalTransitCard,
          '3': FareMediaType.cEMV,
          '4': FareMediaType.mobileApp,
        },
        defaultValue: null,
        displayName: 'Fare media type',
      ),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareMedia transform(MapRecord record) => ModelBuilder.build(
    (c) => FareMedia(
      id: c('fare_media_id'),
      name: c('fare_media_name'),
      type: c('fare_media_type'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Describes a fare available for purchase by ruders or taken into account when
/// computing the total fare for journeys with multiple legs, such as transfers
/// costs.
class FareProduct {
  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:fare_product_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:fare_product_name:3
  /// {@end-tool}
  final String name;

  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:rider_category_id:3
  /// {@end-tool}
  final String riderCategoryId;

  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:fare_media_id:3
  /// {@end-tool}
  final String fareMediaId;

  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:amount:3
  /// {@end-tool}
  final String amount;

  /// {@tool placedef}
  /// gtfs:fare_products.txt:table:currency:3
  /// {@end-tool}
  final String currency;

  /// Creates the object.
  const FareProduct({
    required this.id,
    required this.name,
    required this.riderCategoryId,
    required this.fareMediaId,
    required this.amount,
    required this.currency,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_products.txt:2
/// {@end-tool}
class FareProducts extends FareCsvBinding<FareProduct> {
  /// Creates the list of fare products.
  FareProducts({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'fare_product_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Fare product ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'fare_product_name',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Fare product ID'),
    ),
    FieldDefinition(
      'rider_category_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Rider category ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'fare_media_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Fare media ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'amount',
      (dataset, header, fileLength) => true,
      type: CurrencyAmountFieldType(),
    ),
    FieldDefinition(
      'currency',
      (dataset, header, fileLength) => true,
      type: CurrencyCodeFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareProduct transform(MapRecord record) => ModelBuilder.build(
    (c) => FareProduct(
      id: c('fare_product_id'),
      name: c('fare_product_name'),
      riderCategoryId: c('rider_category_id'),
      fareMediaId: c('fare_media_id'),
      amount: c('amount'),
      currency: c('currency'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Defines a category of riders (e.g. elderly, student).
class RiderCategory {
  /// {@tool placedef}
  /// gtfs:rider_categories.txt:table:rider_category_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:rider_categories.txt:table:rider_category_name:3
  /// {@end-tool}
  final String name;

  /// {@tool placedef}
  /// gtfs:rider_categories.txt:table:is_default_fare_category:3
  /// {@end-tool}
  final IsDefaultFareCategory isDefaultFareCategory;

  /// {@tool placedef}
  /// gtfs:rider_categories.txt:table:eligibility_url:3
  /// {@end-tool}
  final Uri eligibilityUrl;

  /// Creates the object.
  const RiderCategory({
    required this.id,
    required this.name,
    required this.isDefaultFareCategory,
    required this.eligibilityUrl,
  });
}

/// Specifies if an entry in [RiderCategories] should be considered the default
/// category (i.e. the main category that should be displayed to riders). For
/// example: Adult fare, Regular fare, etc.
enum IsDefaultFareCategory implements RichlyNamedEnum {
  /// Category is not considered the default.
  notDefault('Not default', 'Category is not considered the default.'),

  /// Category is considered the default one.
  ddefault('Default', 'Category is considered the default one.');

  const IsDefaultFareCategory(this.displayName, this.description);

  @override
  final String displayName;
  @override
  final String description;
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:rider_categories.txt:2
/// {@end-tool}
class RiderCategories extends FareCsvBinding<RiderCategory> {
  /// Creates the list of rider categories.
  RiderCategories({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'rider_category_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Rider category ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'rider_category_name',
      (dataset, header, fileLength) => true,
      type: TextFieldType(),
    ),
    FieldDefinition(
      'is_default_fare_category',
      (dataset, header, fileLength) => true,
      type: EnumFieldType(
        enumMap: {
          '0': IsDefaultFareCategory.notDefault,
          '1': IsDefaultFareCategory.ddefault,
        },
        defaultValue: IsDefaultFareCategory.notDefault,
        displayName: 'Is default fare category',
      ),
    ),
    FieldDefinition(
      'eligibility_url',
      (dataset, header, fileLength) => null,
      type: UrlFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  RiderCategory transform(MapRecord record) => ModelBuilder.build(
    (c) => RiderCategory(
      id: c('rider_category_id'),
      name: c('rider_category_name'),
      isDefaultFareCategory: c('is_default_fare_category'),
      eligibilityUrl: c('eligibility_url'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Fare rule for individual an leg of travel.
class FareLegRule {
  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:leg_group_id:3
  /// {@end-tool}
  final String legGroupId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:network_id:3
  /// {@end-tool}
  final String networkId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:from_area_id:3
  /// {@end-tool}
  final String fromAreaId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:to_area_id:3
  /// {@end-tool}
  final String toAreaId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:from_timeframe_group_id:3
  /// {@end-tool}
  final String fromTimeframeGroupId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:to_timeframe_group_id:3
  /// {@end-tool}
  final String toTimeframeGroupId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:fare_product_id:3
  /// {@end-tool}
  final String fareProductId;

  /// {@tool placedef}
  /// gtfs:fare_leg_rules.txt:table:rule_priority:3
  /// {@end-tool}
  final int rulePriority;

  /// Creates the object.
  const FareLegRule({
    required this.legGroupId,
    required this.networkId,
    required this.fromAreaId,
    required this.toAreaId,
    required this.fromTimeframeGroupId,
    required this.toTimeframeGroupId,
    required this.fareProductId,
    required this.rulePriority,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_leg_rules.txt:2
/// {@end-tool}
class FareLegRules extends FareCsvBinding<FareLegRule> {
  /// Creates the list of fare leg rules.
  FareLegRules({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'leg_group_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Leg group ID'),
    ),
    FieldDefinition(
      'network_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Network ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'from_area_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Area ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'to_area_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Area ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'from_timeframe_group_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Timeframe group ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'to_timeframe_group_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Timeframe group ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'fare_product_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Fare product ID'),
      primaryKey: true,
    ),
    FieldDefinition(
      'rule_priority',
      (dataset, header, fileLength) => null,
      type: IntegerFieldType(NumberConstraint.nonNegative),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareLegRule transform(MapRecord record) => ModelBuilder.build(
    (c) => FareLegRule(
      legGroupId: c('leg_group_id'),
      networkId: c('network_id'),
      fromAreaId: c('from_area_id'),
      toAreaId: c('to_area_id'),
      fromTimeframeGroupId: c('from_timeframe_group_id'),
      toTimeframeGroupId: c('to_timeframe_group_id'),
      fareProductId: c('fare_product_id'),
      rulePriority: c('rule_priority'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Describe a rule which merges two consecutive legs with a transfer as a
/// single effective fare leg.
class FareLegJoinRule {
  /// {@tool placedef}
  /// gtfs:fare_leg_join_rules.txt:table:from_network_id:3
  /// {@end-tool}
  final String fromNetworkId;

  /// {@tool placedef}
  /// gtfs:fare_leg_join_rules.txt:table:to_network_id:3
  /// {@end-tool}
  final String toNetworkId;

  /// {@tool placedef}
  /// gtfs:fare_leg_join_rules.txt:table:from_stop_id:3
  /// {@end-tool}
  final String fromStopId;

  /// {@tool placedef}
  /// gtfs:fare_leg_join_rules.txt:table:to_stop_id:3
  /// {@end-tool}
  final String toStopId;

  /// Creates the object.
  const FareLegJoinRule({
    required this.fromNetworkId,
    required this.toNetworkId,
    required this.fromStopId,
    required this.toStopId,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_leg_join_rules.txt:2
/// {@end-tool}
class FareLegJoinRules extends FareCsvBinding<FareLegJoinRule> {
  /// Creates the list of fare leg join rules.
  FareLegJoinRules({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'from_network_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Network ID'),
    ),
    FieldDefinition(
      'to_network_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Network ID'),
    ),
    FieldDefinition(
      'from_stop_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Stop ID'),
      shouldBeRequired:
          (dataset, header, record) =>
              record.containsKey('to_stop_id') ? true : null,
    ),
    FieldDefinition(
      'to_stop_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Stop ID'),
      shouldBeRequired:
          (dataset, header, record) =>
              record.containsKey('from_stop_id') ? true : null,
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareLegJoinRule transform(MapRecord record) => ModelBuilder.build(
    (c) => FareLegJoinRule(
      fromNetworkId: c('from_network_id'),
      toNetworkId: c('to_network_id'),
      fromStopId: c('from_stop_id'),
      toStopId: c('to_stop_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Fare rule for transfer between legs of travel defined in [FareLegRules].
class FareTransferRule {
  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:from_leg_group_id:3
  /// {@end-tool}
  final String fromLegGroupId;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:to_leg_group_id:3
  /// {@end-tool}
  final String toLegGroupId;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:transfer_count:3
  /// {@end-tool}
  final int transferCount;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:duration_limit:3
  /// {@end-tool}
  final int durationLimit;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:duration_limit_type:3
  /// {@end-tool}
  final DurationLimitType durationLimitType;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:fare_transfer_type:3
  /// {@end-tool}
  final FareTransferType fareTransferType;

  /// {@tool placedef}
  /// gtfs:fare_transfer_rules.txt:table:fare_product_id:3
  /// {@end-tool}
  final String fareProductId;

  /// Creates the object.
  const FareTransferRule({
    required this.fromLegGroupId,
    required this.toLegGroupId,
    required this.transferCount,
    required this.durationLimit,
    required this.durationLimitType,
    required this.fareTransferType,
    required this.fareProductId,
  });
}

/// Defines the relative start and end of `fare_transfer_rules.duration_limit`.
enum DurationLimitType implements RichlyNamedEnum {
  /// Between the departure fare validation of the current leg and the arrival fare validation of the next leg.
  departureToArrival(
    'Departure to arrival',
    'Between the departure fare validation of the current leg and the arrival fare validation of the next leg.',
  ),

  /// Between the departure fare validation of the current leg and the departure fare validation of the next leg.
  departureToDeparture(
    'Departure to departure',
    'Between the departure fare validation of the current leg and the departure fare validation of the next leg.',
  ),

  /// Between the arrival fare validation of the current leg and the departure fare validation of the next leg.
  arrivalToDeparture(
    'Arrival to departure',
    'Between the arrival fare validation of the current leg and the departure fare validation of the next leg.',
  ),

  /// Between the arrival fare validation of the current leg and the arrival fare validation of the next leg.
  arrivalToArrival(
    'Arrival to arrival',
    'Between the arrival fare validation of the current leg and the arrival fare validation of the next leg.',
  );

  const DurationLimitType(this.displayName, this.description);

  @override
  final String displayName;
  @override
  final String description;
}

/// Indicates the cost processing method of transferring between legs in a journey
enum FareTransferType implements RichlyNamedEnum {
  /// From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id; A + AB.
  currentPlusTransfer(
    'A + AB',
    'From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id; A + AB.',
  ),

  /// From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id plus to-leg fare_leg_rules.fare_product_id; A + AB + B.
  currentPlusTransferPlusNext(
    'A + AB + B',
    'From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id plus to-leg fare_leg_rules.fare_product_id; A + AB + B.',
  ),

  /// fare_transfer_rules.fare_product_id; AB.
  transfer('AB', 'fare_transfer_rules.fare_product_id; AB.');

  const FareTransferType(this.displayName, this.description);

  @override
  final String displayName;
  @override
  final String description;
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:fare_transfer_rules.txt:2
/// {@end-tool}
class FareTransferRules extends FareCsvBinding<FareTransferRule> {
  /// Creates the list of fare transfer rules.
  FareTransferRules({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'from_leg_group_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Leg group ID'),
    ),
    FieldDefinition(
      'to_leg_group_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Leg group ID'),
    ),
    FieldDefinition(
      'transfer_count',
      (dataset, header, fileLength) => null,
      shouldBeRequired:
          (dataset, header, record) =>
              record['from_leg_group_id'] == record['to_leg_group_id'],
      type: IntegerFieldType(NumberConstraint.nonZero),
    ),
    FieldDefinition(
      'duration_limit',
      (dataset, header, fileLength) => null,
      type: IntegerFieldType(NumberConstraint.positive),
    ),
    FieldDefinition(
      'duration_limit_type',
      (dataset, header, fileLength) => null,
      type: EnumFieldType(
        enumMap: {
          '0': DurationLimitType.departureToArrival,
          '1': DurationLimitType.departureToDeparture,
          '2': DurationLimitType.arrivalToDeparture,
          '3': DurationLimitType.arrivalToArrival,
        },
        defaultValue: null,
        displayName: 'Duration limit type',
      ),
      shouldBeRequired:
          (dataset, header, record) => record['duration_limit'] != null,
    ),
    FieldDefinition(
      'fare_transfer_type',
      (dataset, header, fileLength) => true,
      type: EnumFieldType(
        enumMap: {
          '0': FareTransferType.currentPlusTransfer,
          '1': FareTransferType.currentPlusTransferPlusNext,
          '2': FareTransferType.transfer,
        },
        displayName: 'Fare transfer type',
        defaultValue: null,
      ),
    ),
    FieldDefinition(
      'fare_product_id',
      (dataset, header, fileLength) => null,
      type: IdFieldType(displayName: 'Fare product ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  FareTransferRule transform(MapRecord record) => ModelBuilder.build(
    (c) => FareTransferRule(
      fromLegGroupId: c('from_leg_group_id'),
      toLegGroupId: c('to_leg_group_id'),
      transferCount: c('transfer_count'),
      durationLimit: c('duration_limit'),
      durationLimitType: c('duration_limit_type'),
      fareTransferType: c('fare_transfer_type'),
      fareProductId: c('fare_product_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Used to describe fares that can vary based on the time of day, the day of the week, or a particular day in the year.
class Timeframe {
  /// {@tool placedef}
  /// gtfs:timeframes.txt:table:timeframe_group_id:3
  /// {@end-tool}
  final String timeframeGroupId;

  /// {@tool placedef}
  /// gtfs:timeframes.txt:table:start_time:3
  /// {@end-tool}
  final Time startTime;

  /// {@tool placedef}
  /// gtfs:timeframes.txt:table:end_time:3
  /// {@end-tool}
  final Time endTime;

  /// {@tool placedef}
  /// gtfs:timeframes.txt:table:service_id:3
  /// {@end-tool}
  final String serviceId;

  /// Creates the object.
  const Timeframe({
    required this.timeframeGroupId,
    required this.startTime,
    required this.endTime,
    required this.serviceId,
  });
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:timeframes.txt:2
/// {@end-tool}
class Timeframes extends FareCsvBinding<Timeframe> {
  /// Creates the list of timeframes.
  Timeframes({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'timeframe_group_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Timeframe group ID'),
    ),
    FieldDefinition(
      'start_time',
      (dataset, header, fileLength) => null,
      type: TimeFieldType(),
      shouldBeRequired:
          (dataset, header, record) => record.containsKey('end_time'),
    ),
    FieldDefinition(
      'end_time',
      (dataset, header, fileLength) => null,
      type: TimeFieldType(),
      shouldBeRequired:
          (dataset, header, record) => record.containsKey('start_time'),
    ),
    FieldDefinition(
      'service_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Service ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  Timeframe transform(MapRecord record) => ModelBuilder.build(
    (c) => Timeframe(
      timeframeGroupId: c('timeframe_group_id'),
      startTime: c('start_time'),
      endTime: c('end_time'),
      serviceId: c('service_id'),
    ),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Defines a network identifier that apply for fare leg rules.
class Network {
  /// {@tool placedef}
  /// gtfs:networks.txt:table:network_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:networks.txt:table:network_name:3
  /// {@end-tool}
  final String name;

  /// Creates the object.
  const Network({required this.id, required this.name});
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:networks.txt:2
/// {@end-tool}
class Networks extends FareCsvBinding<Network> {
  /// Creates the list of networks.
  Networks({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinition = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'network_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Network ID'),
    ),
    FieldDefinition(
      'network_name',
      (dataset, header, fileLength) => null,
      type: TextFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinition;

  @override
  Network transform(MapRecord record) => ModelBuilder.build(
    (c) => Network(id: c('network_id'), name: c('network_name')),
    fieldDefinitions: staticFieldDefinition,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Assigns a route from [Routes] to a network.
class RouteNetwork {
  /// {@tool placedef}
  /// gtfs:route_networks.txt:table:network_id:3
  /// {@end-tool}
  final String networkId;

  /// {@tool placedef}
  /// gtfs:route_networks.txt:table:route_id:3
  /// {@end-tool}
  final String routeId;

  /// Creates the object.
  const RouteNetwork({required this.networkId, required this.routeId});
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:route_networks.txt:2
/// {@end-tool}
class RouteNetworks extends FareCsvBinding<RouteNetwork> {
  /// Creates the list of route networks.
  RouteNetworks({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'network_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Network ID'),
    ),
    FieldDefinition(
      'route_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Route ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  RouteNetwork transform(MapRecord record) => ModelBuilder.build(
    (c) => RouteNetwork(networkId: c('network_id'), routeId: c('route_id')),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Defines an area identifier.
class Area {
  /// {@tool placedef}
  /// gtfs:areas.txt:table:area_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:areas.txt:table:area_name:3
  /// {@end-tool}
  final String name;

  /// Creates the object.
  const Area({required this.id, required this.name});
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:areas.txt:2
/// {@end-tool}
class Areas extends FareCsvBinding<Area> {
  /// Creates the list of areas.
  Areas({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'area_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Area ID'),
    ),
    FieldDefinition(
      'area_name',
      (dataset, header, fileLength) => null,
      type: TextFieldType(),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  Area transform(MapRecord record) => ModelBuilder.build(
    (c) => Area(id: c('area_id'), name: c('area_name')),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}

/// Assigns a stop from [Stops] to an area.
class StopArea {
  /// {@tool placedef}
  /// gtfs:stop_areas.txt:table:area_id:3
  /// {@end-tool}
  final String id;

  /// {@tool placedef}
  /// gtfs:stop_areas.txt:table:stop_id:3
  /// {@end-tool}
  final String stopId;

  /// Creates the object.
  const StopArea({required this.id, required this.stopId});
}

/// {@tool placedef}
/// gtfs:2Dataset Files:table:stop_areas.txt:2
/// {@end-tool}
class StopAreas extends FareCsvBinding<StopArea> {
  /// Creates the list of stop areas.
  StopAreas({required super.resourceFile});

  /// The list of known field definitions for the binding available for
  /// convenience.
  static final staticFieldDefinitions = <FieldDefinition<dynamic>>[
    FieldDefinition(
      'area_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Area ID'),
    ),
    FieldDefinition(
      'stop_id',
      (dataset, header, fileLength) => true,
      type: IdFieldType(displayName: 'Stop ID'),
    ),
  ];

  @override
  List<FieldDefinition> get fieldDefinitions => staticFieldDefinitions;

  @override
  StopArea transform(MapRecord record) => ModelBuilder.build(
    (c) => StopArea(id: c('area_id'), stopId: c('stop_id')),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}
