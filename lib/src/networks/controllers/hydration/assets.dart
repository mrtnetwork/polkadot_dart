import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum HydrationAssetType {
  token('Token'),
  xyk('XYK'),
  stableSwap('StableSwap'),
  poolShare("PoolShare"),
  bond('Bond'),
  external('External'),
  erc20('Erc20'),
  unknown('Unknown');

  final String type;

  const HydrationAssetType(this.type);
  static HydrationAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? HydrationAssetType.unknown;
  }

  bool get isSpendable =>
      this == token || this == xyk || this == external || this == erc20;
}

class HydrationAssetMetadata {
  final int decimals;
  final String symbol;

  HydrationAssetMetadata.fromJson(Map<String, dynamic> json)
      : decimals = json.valueAs("decimals"),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        super();
}

abstract class BaseHydrationAssetType {
  final HydrationAssetType type;
  final Map<String, dynamic> identifier;

  Map<String, dynamic> toJson() => identifier;

  const BaseHydrationAssetType({required this.type, required this.identifier});
  factory BaseHydrationAssetType.fromJson(Map<String, dynamic> json) {
    final type = HydrationAssetType.fromJson(json);
    return switch (type) {
      HydrationAssetType.token => HydrationAssetTypeToken.fromJson(json),
      HydrationAssetType.xyk => HydrationAssetTypeXYK.fromJson(json),
      HydrationAssetType.stableSwap =>
        HydrationAssetTypeStableSwap.fromJson(json),
      HydrationAssetType.poolShare =>
        HydrationAssetTypePoolShare.fromJson(json),
      HydrationAssetType.bond => HydrationAssetTypeBond.fromJson(json),
      HydrationAssetType.external => HydrationAssetTypeExternal.fromJson(json),
      HydrationAssetType.erc20 => HydrationAssetTypeErc20.fromJson(json),
      HydrationAssetType.unknown => HydrationAssetTypeUnknown.fromJson(json),
    };
  }
}

class HydrationAssetTypeToken extends BaseHydrationAssetType {
  const HydrationAssetTypeToken({required super.identifier})
      : super(type: HydrationAssetType.token);
  HydrationAssetTypeToken.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.token, identifier: json);
}

class HydrationAssetTypeStableSwap extends BaseHydrationAssetType {
  const HydrationAssetTypeStableSwap({required super.identifier})
      : super(type: HydrationAssetType.stableSwap);
  HydrationAssetTypeStableSwap.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.stableSwap, identifier: json);
}

class HydrationAssetTypeXYK extends BaseHydrationAssetType {
  const HydrationAssetTypeXYK({required super.identifier})
      : super(type: HydrationAssetType.xyk);
  HydrationAssetTypeXYK.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.xyk, identifier: json);
}

class HydrationAssetTypeErc20 extends BaseHydrationAssetType {
  const HydrationAssetTypeErc20({required super.identifier})
      : super(type: HydrationAssetType.erc20);
  HydrationAssetTypeErc20.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.erc20, identifier: json);
}

class HydrationAssetTypeBond extends BaseHydrationAssetType {
  const HydrationAssetTypeBond({required super.identifier})
      : super(type: HydrationAssetType.bond);
  HydrationAssetTypeBond.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.bond, identifier: json);
}

class HydrationAssetTypeExternal extends BaseHydrationAssetType {
  const HydrationAssetTypeExternal({required super.identifier})
      : super(type: HydrationAssetType.external);
  HydrationAssetTypeExternal.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.external, identifier: json);
}

class HydrationAssetTypeUnknown extends BaseHydrationAssetType {
  const HydrationAssetTypeUnknown({required super.identifier})
      : super(type: HydrationAssetType.unknown);
  HydrationAssetTypeUnknown.fromJson(Map<String, dynamic> json)
      : super(type: HydrationAssetType.unknown, identifier: json);
}

class HydrationAssetTypePoolShare extends BaseHydrationAssetType {
  final int assetA;
  final int assetB;
  const HydrationAssetTypePoolShare(
      {required this.assetA, required this.assetB, required super.identifier})
      : super(type: HydrationAssetType.poolShare);
  factory HydrationAssetTypePoolShare.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList<int>(HydrationAssetType.poolShare.type);
    return HydrationAssetTypePoolShare(
        assetA: data[0], assetB: data[1], identifier: json);
  }
}

class HydrationAsset {
  final String? name;
  final String? symbol;
  final BaseHydrationAssetType type;
  final BigInt existentialDeposit;

  final int? decimals;
  final BigInt? xcmRateLimit;
  final bool? isSufficient;

  HydrationAsset copyWith({
    String? name,
    String? symbol,
    BaseHydrationAssetType? type,
    BigInt? existentialDeposit,
    int? decimals,
    BigInt? xcmRateLimit,
    bool? isSufficient,
  }) {
    return HydrationAsset(
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        decimals: decimals ?? this.decimals,
        type: type ?? this.type,
        existentialDeposit: existentialDeposit ?? this.existentialDeposit,
        xcmRateLimit: xcmRateLimit ?? this.xcmRateLimit,
        isSufficient: isSufficient ?? this.isSufficient);
  }

  HydrationAsset.fromJson(Map<String, dynamic> json)
      : decimals = MetadataUtils.parseOptional(json.valueAs("decimals")),
        xcmRateLimit =
            MetadataUtils.parseOptional(json.valueAs("xcm_rate_limit")),
        name = SubstrateNetworkControllerUtils.asUtf8(
            MetadataUtils.parseOptional(json.valueAs("name"))),
        symbol = SubstrateNetworkControllerUtils.asUtf8(
            MetadataUtils.parseOptional(json.valueAs("symbol"))),
        isSufficient = json.valueAs("is_sufficient"),
        type = BaseHydrationAssetType.fromJson(json.valueAs("asset_type")),
        existentialDeposit = json.valueAs("existential_deposit"),
        super();
  const HydrationAsset({
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.type,
    required this.existentialDeposit,
    required this.xcmRateLimit,
    required this.isSufficient,
  });
  Map<String, dynamic> toJson() {
    return {
      "asset_type": type.toJson(),
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
      "existential_deposit": existentialDeposit.toString(),
      "xcm_rate_limit": xcmRateLimit?.toString(),
      "is_sufficient": isSufficient
    };
  }
}

abstract class BaseHydrationNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseHydrationNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseHydrationNetworkAsset.fromJson(super.json) : super.fromJson();
}

class HydrationNetworkAsset extends BaseHydrationNetworkAsset {
  final HydrationAsset asset;
  @override
  final XCMVersionedLocation? location;
  HydrationNetworkAsset(
      {required this.asset,
      required this.identifier,
      this.location,
      bool? isFeeToken})
      : super(
            minBalance: asset.existentialDeposit,
            isFeeToken: isFeeToken ?? asset.xcmRateLimit != null,
            decimals: asset.decimals,
            isSpendable: asset.type.type.isSpendable,
            name: asset.name,
            symbol: asset.symbol,
            excutionPallet: SubtrateMetadataPallet.tokens);

  factory HydrationNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = HydrationAsset.fromJson(json.valueAs("asset"));
    final bool isFeeToken = json.valueAs("is_fee_token");
    return HydrationNetworkAsset(
        asset: asset,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken,
        identifier: json.valueAsBigInt("identifier"));
  }

  @override
  final BigInt identifier;
  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "location": location?.toJson(),
      "identifier": identifier.toString(),
      "is_fee_token": isFeeToken
    };
  }

  @override
  bool get hasMetadata => symbol != null && decimals != null;

  @override
  SubtrateMetadataPallet get excutionPallet => SubtrateMetadataPallet.tokens;

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }
}

class HydrationNetworkNativeAsset extends BaseHydrationNetworkAsset {
  @override
  final XCMVersionedLocation location;
  HydrationNetworkNativeAsset(
      {required super.decimals,
      required this.location,
      required super.name,
      required super.symbol,
      super.minBalance})
      : super(
            excutionPallet: SubtrateMetadataPallet.balances,
            isFeeToken: true,
            isSpendable: true);
  HydrationNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();
  @override
  Object? get identifier => null;

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "location": location.toJson()};
  }
}
