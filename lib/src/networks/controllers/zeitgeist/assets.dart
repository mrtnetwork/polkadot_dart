import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum ZeitgeistAssetType {
  combinatorialOutcomeLegacy('CombinatorialOutcomeLegacy'),
  categoricalOutcome('CategoricalOutcome'),
  scalarOutcome('ScalarOutcome'),
  foreignAsset('ForeignAsset'),
  poolShare('PoolShare'),
  ztg('Ztg'),
  parimutuelShare('ParimutuelShare'),
  combinatorialToken('CombinatorialToken'),
  unknown("Unknown");

  final String type;

  const ZeitgeistAssetType(this.type);
  static ZeitgeistAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? ZeitgeistAssetType.unknown;
  }
}

class ZeitgeistAsstConst {
  static const int ztgDecimals = 10;
  static final BaseZeitgeistAsset ztg =
      ZeitgeistAssetZtg(identifier: {ZeitgeistAssetType.ztg.type: null});
}

abstract class BaseZeitgeistAsset {
  final Map<String, dynamic> identifier;
  final ZeitgeistAssetType type;
  const BaseZeitgeistAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseZeitgeistAsset.fromJson(Map<String, dynamic> json) {
    final type = ZeitgeistAssetType.fromJson(json);
    return switch (type) {
      ZeitgeistAssetType.combinatorialOutcomeLegacy =>
        ZeitgeistAssetCombinatorialOutcomeLegacy.fromJson(json),
      ZeitgeistAssetType.ztg => ZeitgeistAssetZtg.fromJson(json),
      ZeitgeistAssetType.categoricalOutcome =>
        ZeitgeistAssetCategoricalOutcome.fromJson(json),
      ZeitgeistAssetType.parimutuelShare =>
        ZeitgeistAssetParimutuelShare.fromJson(json),
      ZeitgeistAssetType.foreignAsset =>
        ZeitgeistAssetForeignAsset.fromJson(json),
      ZeitgeistAssetType.scalarOutcome =>
        ZeitgeistAssetScalarOutcome.fromJson(json),
      ZeitgeistAssetType.poolShare => ZeitgeistAssetPoolShare.fromJson(json),
      ZeitgeistAssetType.combinatorialToken =>
        ZeitgeistAssetCombinatorialToken.fromJson(json),
      ZeitgeistAssetType.unknown => ZeitgeistAssetUnknown.fromJson(json),
    };
  }
}

class ZeitgeistAssetCombinatorialOutcomeLegacy extends BaseZeitgeistAsset {
  const ZeitgeistAssetCombinatorialOutcomeLegacy({required super.identifier})
      : super(type: ZeitgeistAssetType.combinatorialOutcomeLegacy);
  ZeitgeistAssetCombinatorialOutcomeLegacy.fromJson(Map<String, dynamic> json)
      : super(
            type: ZeitgeistAssetType.combinatorialOutcomeLegacy,
            identifier: json);
}

class ZeitgeistAssetZtg extends BaseZeitgeistAsset {
  const ZeitgeistAssetZtg({required super.identifier})
      : super(type: ZeitgeistAssetType.ztg);
  ZeitgeistAssetZtg.fromJson(Map<String, dynamic> json)
      : super(type: ZeitgeistAssetType.ztg, identifier: json);
}

class ZeitgeistAssetCategoricalOutcome extends BaseZeitgeistAsset {
  final BigInt a;
  final int b;
  ZeitgeistAssetCategoricalOutcome(
      {required BigInt a, required int b, required super.identifier})
      : a = a.asUint128,
        b = b.asUint16,
        super(type: ZeitgeistAssetType.categoricalOutcome);
  factory ZeitgeistAssetCategoricalOutcome.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList(ZeitgeistAssetType.categoricalOutcome.type);
    return ZeitgeistAssetCategoricalOutcome(
        b: IntUtils.parse(data[1]),
        a: BigintUtils.parse(data[0]),
        identifier: json);
  }
}

class ZeitgeistAssetParimutuelShare extends BaseZeitgeistAsset {
  final BigInt a;
  final int b;
  ZeitgeistAssetParimutuelShare(
      {required BigInt a, required int b, required super.identifier})
      : a = a.asUint128,
        b = b.asUint16,
        super(type: ZeitgeistAssetType.parimutuelShare);
  factory ZeitgeistAssetParimutuelShare.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList(ZeitgeistAssetType.parimutuelShare.type);
    return ZeitgeistAssetParimutuelShare(
        b: IntUtils.parse(data[1]),
        a: BigintUtils.parse(data[0]),
        identifier: json);
  }
}

enum ZeitgeistAssetScalarOutcomeType {
  long('Long'),
  short('Short'),
  unknown("Unknown");

  final String type;

  const ZeitgeistAssetScalarOutcomeType(this.type);
  static ZeitgeistAssetScalarOutcomeType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? ZeitgeistAssetScalarOutcomeType.unknown;
  }
}

class ZeitgeistAssetScalarOutcome extends BaseZeitgeistAsset {
  final int id;
  final ZeitgeistAssetScalarOutcomeType outcomeType;
  ZeitgeistAssetScalarOutcome(
      {required int id, required this.outcomeType, required super.identifier})
      : id = id.asUint16,
        super(type: ZeitgeistAssetType.scalarOutcome);
  factory ZeitgeistAssetScalarOutcome.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList(ZeitgeistAssetType.scalarOutcome.type);
    return ZeitgeistAssetScalarOutcome(
        id: IntUtils.parse(data[0]),
        outcomeType: ZeitgeistAssetScalarOutcomeType.fromJson(data[1]),
        identifier: json);
  }
}

class ZeitgeistAssetPoolShare extends BaseZeitgeistAsset {
  final BigInt id;
  const ZeitgeistAssetPoolShare({required this.id, required super.identifier})
      : super(type: ZeitgeistAssetType.poolShare);
  ZeitgeistAssetPoolShare.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(ZeitgeistAssetType.poolShare.type),
        super(type: ZeitgeistAssetType.poolShare, identifier: json);
}

class ZeitgeistAssetCombinatorialToken extends BaseZeitgeistAsset {
  final List<int> token;
  ZeitgeistAssetCombinatorialToken(
      {required List<int> token, required super.identifier})
      : token = token.exc(32).asImmutableBytes,
        super(type: ZeitgeistAssetType.combinatorialToken);
  ZeitgeistAssetCombinatorialToken.fromJson(Map<String, dynamic> json)
      : token = json
            .valueAsBytes<List<int>>(ZeitgeistAssetType.combinatorialToken.type)
            .exc(32)
            .asImmutableBytes,
        super(type: ZeitgeistAssetType.poolShare, identifier: json);
}

class ZeitgeistAssetForeignAsset extends BaseZeitgeistAsset {
  final int id;
  const ZeitgeistAssetForeignAsset(
      {required this.id, required super.identifier})
      : super(type: ZeitgeistAssetType.foreignAsset);
  ZeitgeistAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(ZeitgeistAssetType.foreignAsset.type),
        super(type: ZeitgeistAssetType.foreignAsset, identifier: json);
}

class ZeitgeistAssetUnknown extends BaseZeitgeistAsset {
  const ZeitgeistAssetUnknown({required super.identifier})
      : super(type: ZeitgeistAssetType.unknown);
  ZeitgeistAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: ZeitgeistAssetType.unknown, identifier: json);
}

class CentrifugeAssetMetadatAadditionalXCM {
  final BigInt? feeFactor;
  const CentrifugeAssetMetadatAadditionalXCM({this.feeFactor});
  CentrifugeAssetMetadatAadditionalXCM.fromJson(Map<String, dynamic> json)
      : feeFactor =
            MetadataUtils.parseOptional(json.valueEnsureAsMap("fee_factor"));
  Map<String, dynamic> toJson() {
    return {"fee_factor": MetadataUtils.toOptionalJson(feeFactor)};
  }
}

class ZeitgeistAssetMetadatAdditional {
  final CentrifugeAssetMetadatAadditionalXCM xcm;
  final bool allowAsBaseAsset;
  ZeitgeistAssetMetadatAdditional.fromJson(Map<String, dynamic> json)
      : xcm =
            CentrifugeAssetMetadatAadditionalXCM.fromJson(json.valueAs("xcm")),
        allowAsBaseAsset = json.valueAs("allow_as_base_asset");
  Map<String, dynamic> toJson() {
    return {"xcm": xcm.toJson(), "allow_as_base_asset": allowAsBaseAsset};
  }
}

class ZeitgeistAssetMetadata {
  final int decimals;
  final BigInt existentialDeposit;
  final String name;
  final String symbol;
  final XCMVersionedLocation? location;
  final ZeitgeistAssetMetadatAdditional? additional;
  ZeitgeistAssetMetadata copyWith({
    int? decimals,
    BigInt? existentialDeposit,
    String? name,
    String? symbol,
    XCMVersionedLocation? location,
    ZeitgeistAssetMetadatAdditional? additional,
  }) {
    return ZeitgeistAssetMetadata(
      decimals: decimals ?? this.decimals,
      existentialDeposit: existentialDeposit ?? this.existentialDeposit,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      location: location ?? this.location,
      additional: additional ?? this.additional,
    );
  }

  // final bool isFrozen;
  ZeitgeistAssetMetadata.fromJson(Map<String, dynamic> json)
      : existentialDeposit = json.valueAs("existential_deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        additional = json
            .valueTo<ZeitgeistAssetMetadatAdditional?, Map<String, dynamic>>(
                key: "additional",
                parse: (v) => ZeitgeistAssetMetadatAdditional.fromJson(v)),
        location = MetadataUtils.parseOptional<XCMVersionedLocation,
                Map<String, dynamic>>(json.valueAs("location"),
            parse: (v) => XCMVersionedLocation.fromJson(v)),
        super();
  const ZeitgeistAssetMetadata(
      {required this.location,
      required this.name,
      required this.symbol,
      required this.decimals,
      required this.existentialDeposit,
      this.additional});
  Map<String, dynamic> toJson() {
    return {
      "existential_deposit": existentialDeposit.toString(),
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
      "additional": additional?.toJson(),
      "location": MetadataUtils.toOptionalJson(location?.toJson())
    };
  }
}

abstract class BaseZeitgeistNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseZeitgeistNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseZeitgeistNetworkAsset.fromJson(super.json) : super.fromJson();
}

class ZeitgeistNetworkAsset extends BaseZeitgeistNetworkAsset {
  final BaseZeitgeistAsset asset;
  final ZeitgeistAssetMetadata? metadata;
  @override
  XCMVersionedLocation? get location => metadata?.location;
  ZeitgeistNetworkAsset({
    required this.asset,
    required this.metadata,
    bool? isFeeToken,
  }) : super(
            isFeeToken:
                isFeeToken ?? (metadata?.additional?.xcm.feeFactor != null),
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.assetManager);
  ZeitgeistNetworkAsset.fromJson(super.json)
      : asset = BaseZeitgeistAsset.fromJson(json.valueAs("asset")),
        metadata = json.valueTo<ZeitgeistAssetMetadata?, Map<String, dynamic>>(
            key: "metadata", parse: (v) => ZeitgeistAssetMetadata.fromJson(v)),
        super.fromJson();

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      ...super.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class ZeitgeistNetworkNativeAsset extends BaseZeitgeistNetworkAsset {
  @override
  final XCMVersionedLocation location;
  ZeitgeistNetworkNativeAsset({
    required int super.decimals,
    required super.name,
    required super.symbol,
    required this.location,
    super.minBalance,
  }) : super(
            isFeeToken: true,
            isSpendable: true,
            excutionPallet: SubtrateMetadataPallet.balances);
  ZeitgeistNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();

  @override
  Object? get identifier => null;

  @override
  Map<String, dynamic> toJson() {
    return {"location": location.toJson(), ...super.toJson()};
  }

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;
}
