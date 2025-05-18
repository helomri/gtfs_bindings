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
  FareAttributes? get fareAttributes =>
      bindings.whereType<FareAttributes>().singleOrNull;
  FareRules? get fareRules => bindings.whereType<FareRules>().singleOrNull;

  // V2
  FareMedias? get fareMedia => bindings.whereType<FareMedias>().singleOrNull;
  FareProducts? get fareProducts =>
      bindings.whereType<FareProducts>().singleOrNull;
  RiderCategories? get riderCategories =>
      bindings.whereType<RiderCategories>().singleOrNull;
  FareLegRules? get fareLegRules =>
      bindings.whereType<FareLegRules>().singleOrNull;
  FareLegJoinRules? get fareLegJoinRules =>
      bindings.whereType<FareLegJoinRules>().singleOrNull;
  FareTransferRules? get fareTransferRules =>
      bindings.whereType<FareTransferRules>().singleOrNull;
  Timeframes? get timeframes => bindings.whereType<Timeframes>().singleOrNull;
  Networks? get networks => bindings.whereType<Networks>().singleOrNull;
  RouteNetworks? get routeNetworks =>
      bindings.whereType<RouteNetworks>().singleOrNull;
  Areas? get areas => bindings.whereType<Areas>().singleOrNull;
  StopAreas? get stopAreas => bindings.whereType<StopAreas>().singleOrNull;

  /// Creates the fares list.
  const Fares(this.bindings);

  /// All the versions of GTFS-Fares present in the dataset.
  Set<FareVersion> get presentVersions =>
      bindings.map((e) => e.version).toSet();
}

enum PaymentMethod implements RichlyNamedEnum {
  paidOnBoard('Paid on board', 'Fare is paid on board.'),
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

enum TransferPolicy implements RichlyNamedEnum {
  noTransfers('No transfers', 'No transfers permitted on this fare.'),
  oneTransfer('One transfer', 'Riders may transfer once.'),
  twoTransfers('Two transfers', 'Riders may transfer twice.'),
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

class FareAttribute {
  final String fareId;
  final double price;
  final String currencyCode;
  final PaymentMethod paymentMethod;
  final TransferPolicy transfers;
  final String? agencyId;
  final int? transferDuration;

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

class FareAttributes extends FareCsvBinding<FareAttribute> {
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

class FareRule {
  final String fareId;
  final String routeId;
  final String originId;
  final String destinationId;
  final String containsId;

  const FareRule({
    required this.fareId,
    required this.routeId,
    required this.originId,
    required this.destinationId,
    required this.containsId,
  });
}

class FareRules extends FareCsvBinding<FareRule> {
  FareRules({required super.resourceFile});

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

class FareMedia {
  final String id;
  final String? name;
  final FareMediaType type;

  const FareMedia({required this.id, required this.name, required this.type});
}

enum FareMediaType implements RichlyNamedEnum {
  none(
    'None',
    ' Used when there is no fare media involved in purchasing or validating a fare product, such as paying cash to a driver or conductor with no physical ticket provided.',
  ),
  physicalPaperTicket(
    'Physical paper ticket',
    'Physical paper ticket that allows a passenger to take either a certain number of pre-purchased trips or unlimited trips within a fixed period of time.',
  ),
  physicalTransitCard(
    'Physical transit card',
    'Physical transit card that has stored tickets, passes or monetary value.',
  ),
  cEMV(
    'cEMV',
    'cEMV (contactless Europay, Mastercard and Visa) as an open-loop token container for account-based ticketing.',
  ),
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

class FareMedias extends FareCsvBinding<FareMedia> {
  FareMedias({required super.resourceFile});

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

class FareProduct {
  final String id;
  final String name;
  final String riderCategoryId;
  final String fareMediaId;
  final String amount;
  final String currency;

  const FareProduct({
    required this.id,
    required this.name,
    required this.riderCategoryId,
    required this.fareMediaId,
    required this.amount,
    required this.currency,
  });
}

class FareProducts extends FareCsvBinding<FareProduct> {
  FareProducts({required super.resourceFile});

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

class RiderCategory {
  final String id;
  final String name;
  final IsDefaultFareCategory isDefaultFareCategory;
  final Uri eligibilityUrl;

  const RiderCategory({
    required this.id,
    required this.name,
    required this.isDefaultFareCategory,
    required this.eligibilityUrl,
  });
}

enum IsDefaultFareCategory implements RichlyNamedEnum {
  notDefault('Not default', 'Category is not considered the default.'),
  ddefault('Default', 'Category is considered the default one.');

  const IsDefaultFareCategory(this.displayName, this.description);

  final String displayName;
  final String description;
}

class RiderCategories extends FareCsvBinding<RiderCategory> {
  RiderCategories({required super.resourceFile});

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

class FareLegRule {
  final String legGroupId;
  final String networkId;
  final String fromAreaId;
  final String toAreaId;
  final String fromTimeframeGroupId;
  final String toTimeframeGroupId;
  final String fareProductId;
  final int rulePriority;

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

class FareLegRules extends FareCsvBinding<FareLegRule> {
  FareLegRules({required super.resourceFile});

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

class FareLegJoinRule {
  final String fromNetworkId;
  final String toNetworkId;
  final String fromStopId;
  final String toStopId;

  const FareLegJoinRule({
    required this.fromNetworkId,
    required this.toNetworkId,
    required this.fromStopId,
    required this.toStopId,
  });
}

class FareLegJoinRules extends FareCsvBinding<FareLegJoinRule> {
  FareLegJoinRules({required super.resourceFile});

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

class FareTransferRule {
  final String fromLegGroupId;
  final String toLegGroupId;
  final int transferCount;
  final int durationLimit;
  final DurationLimitType durationLimitType;
  final FareTransferType fareTransferType;
  final String fareProductId;

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

enum DurationLimitType implements RichlyNamedEnum {
  departureToArrival(
    'Departure to arrival',
    'Between the departure fare validation of the current leg and the arrival fare validation of the next leg.',
  ),
  departureToDeparture(
    'Departure to departure',
    'Between the departure fare validation of the current leg and the departure fare validation of the next leg.',
  ),
  arrivalToDeparture(
    'Arrival to departure',
    'Between the arrival fare validation of the current leg and the departure fare validation of the next leg.',
  ),
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

enum FareTransferType implements RichlyNamedEnum {
  currentPlusTransfer(
    'A + AB',
    'From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id; A + AB.',
  ),
  currentPlusTransferPlusNext(
    'A + AB + B',
    'From-leg fare_leg_rules.fare_product_id plus fare_transfer_rules.fare_product_id plus to-leg fare_leg_rules.fare_product_id; A + AB + B.',
  ),
  transfer('AB', 'fare_transfer_rules.fare_product_id; AB.');

  const FareTransferType(this.displayName, this.description);

  @override
  final String displayName;
  @override
  final String description;
}

class FareTransferRules extends FareCsvBinding<FareTransferRule> {
  FareTransferRules({required super.resourceFile});

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

class Timeframe {
  final String timeframeGroupId;
  final Time startTime;
  final Time endTime;
  final String serviceId;

  const Timeframe({
    required this.timeframeGroupId,
    required this.startTime,
    required this.endTime,
    required this.serviceId,
  });
}

class Timeframes extends FareCsvBinding<Timeframe> {
  Timeframes({required super.resourceFile});

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

class Network {
  final String id;
  final String name;

  const Network({required this.id, required this.name});
}

class Networks extends FareCsvBinding<Network> {
  Networks({required super.resourceFile});

  static final staticFieldDefinition = [
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

class RouteNetwork {
  final String networkId;
  final String routeId;

  const RouteNetwork({required this.networkId, required this.routeId});
}

class RouteNetworks extends FareCsvBinding<RouteNetwork> {
  RouteNetworks({required super.resourceFile});

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

class Area {
  final String id;
  final String name;

  const Area({required this.id, required this.name});
}

class Areas extends FareCsvBinding<Area> {
  Areas({required super.resourceFile});

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

class StopArea {}

class StopAreas extends FareCsvBinding<StopArea> {
  StopAreas({required super.resourceFile});

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
    (c) => StopArea(),
    fieldDefinitions: staticFieldDefinitions,
    record: record,
  );

  @override
  FareVersion get version => FareVersion.two;
}
