import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum CentrifugeAssetStakingType {
  blockRewards('BlockRewards'),
  unknown("Unknown");

  final String type;

  const CentrifugeAssetStakingType(this.type);
  static CentrifugeAssetStakingType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? CentrifugeAssetStakingType.unknown;
  }
}

enum CentrifugeAssetType {
  native('Native'),
  tranche('Tranche'),
  aUSD('AUSD'),
  foreignAsset('ForeignAsset'),
  staking('Staking'),
  localAsset('LocalAsset'),
  unknown("Unknown");

  final String type;

  const CentrifugeAssetType(this.type);
  static CentrifugeAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? CentrifugeAssetType.unknown;
  }
}

class CentrifugeAsstConst {
  static final BaseCentrifugeAsset cfg = CentrifugeAssetNative(
      identifier: {CentrifugeAssetType.native.type: null});
}

abstract class BaseCentrifugeAsset {
  final Map<String, dynamic> identifier;
  final CentrifugeAssetType type;
  const BaseCentrifugeAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseCentrifugeAsset.fromJson(Map<String, dynamic> json) {
    final type = CentrifugeAssetType.fromJson(json);
    return switch (type) {
      CentrifugeAssetType.native => CentrifugeAssetNative.fromJson(json),
      CentrifugeAssetType.tranche => CentrifugeAssetTranche.fromJson(json),
      CentrifugeAssetType.aUSD => CentrifugeAssetAUSD.fromJson(json),
      CentrifugeAssetType.staking => CentrifugeAssetStacking.fromJson(json),
      CentrifugeAssetType.foreignAsset =>
        CentrifugeAssetForeignAsset.fromJson(json),
      CentrifugeAssetType.localAsset =>
        CentrifugeAssetLocalAsset.fromJson(json),
      CentrifugeAssetType.unknown => CentrifugeAssetUnknown.fromJson(json),
    };
  }
}

class CentrifugeAssetNative extends BaseCentrifugeAsset {
  const CentrifugeAssetNative({required super.identifier})
      : super(type: CentrifugeAssetType.native);
  CentrifugeAssetNative.fromJson(Map<String, dynamic> json)
      : super(type: CentrifugeAssetType.native, identifier: json);
}

class CentrifugeAssetTranche extends BaseCentrifugeAsset {
  final BigInt index;
  final List<int> id;
  CentrifugeAssetTranche(
      {required List<int> id, required BigInt index, required super.identifier})
      : id = id.exc(16).asImmutableBytes,
        index = index.asUint64,
        super(type: CentrifugeAssetType.tranche);
  factory CentrifugeAssetTranche.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList(CentrifugeAssetType.tranche.type);
    List<int> id;
    if (data[1] is List) {
      id = data[1];
    } else {
      id = BytesUtils.fromHexString(data[1]);
    }
    return CentrifugeAssetTranche(
        id: id, index: BigintUtils.parse(data[0]), identifier: json);
  }
}

class CentrifugeAssetAUSD extends BaseCentrifugeAsset {
  const CentrifugeAssetAUSD({required super.identifier})
      : super(type: CentrifugeAssetType.aUSD);
  CentrifugeAssetAUSD.fromJson(Map<String, dynamic> json)
      : super(type: CentrifugeAssetType.aUSD, identifier: json);
}

class CentrifugeAssetStacking extends BaseCentrifugeAsset {
  final CentrifugeAssetStakingType token;
  const CentrifugeAssetStacking(
      {required this.token, required super.identifier})
      : super(type: CentrifugeAssetType.staking);
  CentrifugeAssetStacking.fromJson(Map<String, dynamic> json)
      : token = CentrifugeAssetStakingType.fromJson(
            json.valueAs(CentrifugeAssetType.staking.type)),
        super(type: CentrifugeAssetType.staking, identifier: json);
}

class CentrifugeAssetForeignAsset extends BaseCentrifugeAsset {
  final int id;
  const CentrifugeAssetForeignAsset(
      {required this.id, required super.identifier})
      : super(type: CentrifugeAssetType.foreignAsset);
  CentrifugeAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(CentrifugeAssetType.foreignAsset.type),
        super(type: CentrifugeAssetType.foreignAsset, identifier: json);
}

class CentrifugeAssetLocalAsset extends BaseCentrifugeAsset {
  final int id;
  const CentrifugeAssetLocalAsset({required this.id, required super.identifier})
      : super(type: CentrifugeAssetType.localAsset);
  CentrifugeAssetLocalAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(CentrifugeAssetType.localAsset.type),
        super(type: CentrifugeAssetType.localAsset, identifier: json);
}

class CentrifugeAssetUnknown extends BaseCentrifugeAsset {
  const CentrifugeAssetUnknown({required super.identifier})
      : super(type: CentrifugeAssetType.unknown);
  CentrifugeAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: CentrifugeAssetType.unknown, identifier: json);
}

enum CentrifugeAssetMetadatTransferabilityType {
  none('None'),
  xcm('Xcm'),
  liquidityPools('LiquidityPools'),
  unknown("Unknown");

  final String type;

  const CentrifugeAssetMetadatTransferabilityType(this.type);
  static CentrifugeAssetMetadatTransferabilityType fromJson(
      Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? CentrifugeAssetMetadatTransferabilityType.unknown;
  }
}

class CentrifugeAssetMetadatTransferability {
  final BigInt? feePerSecond;
  final CentrifugeAssetMetadatTransferabilityType type;
  const CentrifugeAssetMetadatTransferability(
      {required this.type, required this.feePerSecond});
  factory CentrifugeAssetMetadatTransferability.fromJson(
      Map<String, dynamic> json) {
    final type = CentrifugeAssetMetadatTransferabilityType.fromJson(json);
    BigInt? feePerSecond;
    if (type == CentrifugeAssetMetadatTransferabilityType.xcm) {
      final xcm = json
          .valueEnsureAsMap(CentrifugeAssetMetadatTransferabilityType.xcm.type);
      feePerSecond = MetadataUtils.parseOptional(
          xcm.valueEnsureAsMap("fee_per_second"),
          parse: (v) => BigintUtils.parse(v, allowHex: false));
    }
    return CentrifugeAssetMetadatTransferability(
        type: type, feePerSecond: feePerSecond);
  }
  Map<String, dynamic> toJson() {
    return {
      type.type: type != CentrifugeAssetMetadatTransferabilityType.xcm
          ? null
          : {"fee_per_second": MetadataUtils.toOptionalJson(feePerSecond)}
    };
  }
}

class CentrifugeAssetMetadatAdditional {
  final CentrifugeAssetMetadatTransferability transferability;
  final bool mintable;
  final bool permissioned;
  final bool poolCurrency;
  final int? localRepresentation;
  CentrifugeAssetMetadatAdditional.fromJson(Map<String, dynamic> json)
      : transferability = CentrifugeAssetMetadatTransferability.fromJson(
            json.valueAs("transferability")),
        mintable = json.valueAs("mintable"),
        permissioned = json.valueAs("permissioned"),
        poolCurrency = json.valueAs("pool_currency"),
        localRepresentation = MetadataUtils.parseOptional(
            json.valueEnsureAsMap("local_representation"));
  Map<String, dynamic> toJson() {
    return {
      "transferability": transferability.toJson(),
      "mintable": mintable,
      "permissioned": permissioned,
      "pool_currency": poolCurrency,
      "local_representation": MetadataUtils.toOptionalJson(localRepresentation)
    };
  }
}

class CentrifugeAssetMetadata {
  final int decimals;
  final BigInt existentialDeposit;
  final String name;
  final String symbol;
  final XCMVersionedLocation? location;
  final CentrifugeAssetMetadatAdditional? additional;
  CentrifugeAssetMetadata copyWith({
    int? decimals,
    BigInt? existentialDeposit,
    String? name,
    String? symbol,
    XCMVersionedLocation? location,
    CentrifugeAssetMetadatAdditional? additional,
  }) {
    return CentrifugeAssetMetadata(
      decimals: decimals ?? this.decimals,
      existentialDeposit: existentialDeposit ?? this.existentialDeposit,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      location: location ?? this.location,
      additional: additional ?? this.additional,
    );
  }

  // final bool isFrozen;
  CentrifugeAssetMetadata.fromJson(Map<String, dynamic> json)
      : existentialDeposit = json.valueAs("existential_deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        additional = json
            .valueTo<CentrifugeAssetMetadatAdditional?, Map<String, dynamic>>(
                key: "additional",
                parse: (v) => CentrifugeAssetMetadatAdditional.fromJson(v)),
        location = MetadataUtils.parseOptional<XCMVersionedLocation,
                Map<String, dynamic>>(json.valueAs("location"),
            parse: (v) => XCMVersionedLocation.fromJson(v)),
        super();
  const CentrifugeAssetMetadata(
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

abstract class BaseCentrifugeNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseCentrifugeNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseCentrifugeNetworkAsset.fromJson(super.json) : super.fromJson();
}

class CentrifugeNetworkAsset extends BaseCentrifugeNetworkAsset {
  final BaseCentrifugeAsset asset;
  final CentrifugeAssetMetadata? metadata;
  @override
  XCMVersionedLocation? get location => metadata?.location;
  CentrifugeNetworkAsset({
    required this.asset,
    required this.metadata,
    bool? isFeeToken,
  }) : super(
            isFeeToken: isFeeToken ??
                (metadata?.additional?.transferability.type ==
                    CentrifugeAssetMetadatTransferabilityType.xcm),
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.tokens);

  factory CentrifugeNetworkAsset.fromJson(Map<String, dynamic> json) {
    return CentrifugeNetworkAsset(
        asset: BaseCentrifugeAsset.fromJson(json.valueAs("asset")),
        metadata: json.valueTo<CentrifugeAssetMetadata?, Map<String, dynamic>>(
            key: "metadata", parse: (v) => CentrifugeAssetMetadata.fromJson(v)),
        isFeeToken: json.valueAs("is_fee_token"));
  }
  @override
  int? get decimals => metadata?.decimals;

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class CentrifugeNetworkNativeAsset extends BaseCentrifugeNetworkAsset {
  final BaseCentrifugeAsset asset;
  final CentrifugeAssetMetadata? metadata;
  @override
  XCMVersionedLocation? get location => metadata?.location;
  CentrifugeNetworkNativeAsset(
      {required this.metadata, BaseCentrifugeAsset? asset, bool? isFeeToken})
      : asset = asset ?? CentrifugeAsstConst.cfg,
        super(
            isFeeToken: isFeeToken ??
                (metadata?.additional?.transferability.type ==
                    CentrifugeAssetMetadatTransferabilityType.xcm),
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.balances);
  factory CentrifugeNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    return CentrifugeNetworkNativeAsset(
        asset: BaseCentrifugeAsset.fromJson(json.valueAs("asset")),
        metadata: json.valueTo<CentrifugeAssetMetadata?, Map<String, dynamic>>(
            key: "metadata", parse: (v) => CentrifugeAssetMetadata.fromJson(v)),
        isFeeToken: json.valueAs("is_fee_token"));
  }

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken
    };
  }

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}
