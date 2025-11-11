import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum InterlayAssetTokenType {
  dot('DOT'),
  iBTC('IBTC'),
  intr('INTR'),
  ksm('KSM'),
  kBTC('KBTC'),
  kINT('KINT'),
  unknown("Unknown");

  final String type;

  const InterlayAssetTokenType(this.type);
  static InterlayAssetTokenType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? InterlayAssetTokenType.unknown;
  }
}

enum InterlayAssetType {
  token('Token'),
  lpToken('LpToken'),
  stableLpToken('StableLpToken'),
  lendToken('LendToken'),
  foreignAsset('ForeignAsset'),
  unknown("Unknown");

  final String type;

  const InterlayAssetType(this.type);
  static InterlayAssetType fromJson(Map<String, dynamic>? json) {
    return values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => InterlayAssetType.unknown);
  }
}

class InterlayAssetConst {
  static final BaseInterlayAsset intr =
      InterlayAssetToken(token: InterlayAssetTokenType.intr, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.intr.type: null}
  });

  static final BaseInterlayAsset dot =
      InterlayAssetToken(token: InterlayAssetTokenType.dot, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.dot.type: null}
  });
  static final BaseInterlayAsset iBTC =
      InterlayAssetToken(token: InterlayAssetTokenType.iBTC, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.iBTC.type: null}
  });
  static final BaseInterlayAsset ksm =
      InterlayAssetToken(token: InterlayAssetTokenType.ksm, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.ksm.type: null}
  });
  static final BaseInterlayAsset kbtc =
      InterlayAssetToken(token: InterlayAssetTokenType.kBTC, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.kBTC.type: null}
  });
  static final BaseInterlayAsset kint =
      InterlayAssetToken(token: InterlayAssetTokenType.kINT, identifier: {
    InterlayAssetType.token.type: {InterlayAssetTokenType.kINT.type: null}
  });
}

abstract class BaseInterlayAsset {
  final Map<String, dynamic> identifier;
  final InterlayAssetType type;
  const BaseInterlayAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseInterlayAsset.fromJson(Map<String, dynamic> json) {
    final type = InterlayAssetType.fromJson(json);
    return switch (type) {
      InterlayAssetType.token => InterlayAssetToken.fromJson(json),
      InterlayAssetType.lendToken => InterlayAssetLendToken.fromJson(json),
      InterlayAssetType.stableLpToken =>
        InterlayAssetStableLpToken.fromJson(json),
      InterlayAssetType.lpToken => InterlayAssetLpToken.fromJson(json),
      InterlayAssetType.foreignAsset =>
        InterlayAssetForeignAsset.fromJson(json),
      InterlayAssetType.unknown => InterlayAssetUnknown.fromJson(json),
    };
  }
}

class InterlayAssetToken extends BaseInterlayAsset {
  final InterlayAssetTokenType token;
  const InterlayAssetToken({required this.token, required super.identifier})
      : super(type: InterlayAssetType.token);
  InterlayAssetToken.fromJson(Map<String, dynamic> json)
      : token = InterlayAssetTokenType.fromJson(
            json.valueAs(InterlayAssetType.token.type)),
        super(type: InterlayAssetType.token, identifier: json);
}

class InterlayAssetLendToken extends BaseInterlayAsset {
  final int id;
  const InterlayAssetLendToken({required this.id, required super.identifier})
      : super(type: InterlayAssetType.lendToken);
  InterlayAssetLendToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(InterlayAssetType.lendToken.type),
        super(type: InterlayAssetType.lendToken, identifier: json);
}

class InterlayAssetStableLpToken extends BaseInterlayAsset {
  final int id;
  const InterlayAssetStableLpToken(
      {required this.id, required super.identifier})
      : super(type: InterlayAssetType.stableLpToken);
  InterlayAssetStableLpToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(InterlayAssetType.stableLpToken.type),
        super(type: InterlayAssetType.stableLpToken, identifier: json);
}

class InterlayAssetForeignAsset extends BaseInterlayAsset {
  final int id;
  const InterlayAssetForeignAsset({required this.id, required super.identifier})
      : super(type: InterlayAssetType.foreignAsset);
  InterlayAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(InterlayAssetType.foreignAsset.type),
        super(type: InterlayAssetType.foreignAsset, identifier: json);
}

class InterlayAssetUnknown extends BaseInterlayAsset {
  const InterlayAssetUnknown({required super.identifier})
      : super(type: InterlayAssetType.foreignAsset);
  InterlayAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: InterlayAssetType.unknown, identifier: json);
}

class InterlayAssetLpToken extends BaseInterlayAsset {
  final List<BaseInterlayAsset> assets;
  const InterlayAssetLpToken({required this.assets, required super.identifier})
      : super(type: InterlayAssetType.lpToken);
  InterlayAssetLpToken.fromJson(Map<String, dynamic> json)
      : assets = json
            .valueEnsureAsList(InterlayAssetType.lpToken.type)
            .map((e) => BaseInterlayAsset.fromJson(e))
            .toList(),
        super(type: InterlayAssetType.lpToken, identifier: json);
}

class InterlayAssetMetadataAdditional {
  final BigInt feePerSecond;
  final String coingeckoId;
  const InterlayAssetMetadataAdditional(
      {required this.feePerSecond, required this.coingeckoId});
  InterlayAssetMetadataAdditional.fromJson(Map<String, dynamic> json)
      : feePerSecond = json.valueAs("fee_per_second"),
        coingeckoId = SubstrateNetworkControllerUtils.tryToUtf8(
            json.valueAs("coingecko_id")),
        super();
  Map<String, dynamic> toJson() {
    return {
      "fee_per_second": feePerSecond.toString(),
      "coingecko_id": coingeckoId
    };
  }
}

class InterlayAssetMetadata {
  final int decimals;
  final String name;
  final String symbol;
  final BigInt existentialDeposit;
  final XCMVersionedLocation? location;
  final InterlayAssetMetadataAdditional additional;

  InterlayAssetMetadata.fromJson(Map<String, dynamic> json)
      : existentialDeposit = json.valueAs("existential_deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        location = MetadataUtils.parseOptional<XCMVersionedLocation,
                Map<String, dynamic>>(json.valueAs("location"),
            parse: (v) => XCMVersionedLocation.fromJson(v)),
        additional = InterlayAssetMetadataAdditional.fromJson(
            json.valueAs("additional")),
        super();
  const InterlayAssetMetadata({
    required this.existentialDeposit,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.additional,
    this.location,
  });
  Map<String, dynamic> toJson() {
    return {
      "existential_deposit": existentialDeposit.toString(),
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
      "additional": additional.toJson(),
      "location": location?.toJson()
    };
  }
}

abstract class BaseInterlayNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseInterlayNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});

  BaseInterlayNetworkAsset.fromJson(super.json) : super.fromJson();
}

class InterlayNetworkAsset extends BaseInterlayNetworkAsset {
  final BaseInterlayAsset asset;
  final InterlayAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  InterlayNetworkAsset(
      {required this.asset,
      required this.metadata,
      bool? isFeeToken,
      required this.location})
      : super(
            isFeeToken: isFeeToken ??
                (metadata?.additional.feePerSecond ?? BigInt.zero) >
                    BigInt.zero,
            decimals: metadata?.decimals,
            isSpendable: asset.type == InterlayAssetType.token ||
                asset.type == InterlayAssetType.foreignAsset,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            excutionPallet: SubtrateMetadataPallet.tokens);

  factory InterlayNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = BaseInterlayAsset.fromJson(json.valueAs("asset"));
    final bool isFeeToken = json.valueAs("is_fee_token");
    final metadata = json.valueTo<InterlayAssetMetadata?, Map<String, dynamic>>(
        key: "metadata", parse: (v) => InterlayAssetMetadata.fromJson(json));
    return InterlayNetworkAsset(
        asset: asset,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken,
        metadata: metadata);
  }

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "location": location?.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class InterlayNetworkNativeAsset extends BaseInterlayNetworkAsset {
  final BaseInterlayAsset asset;
  final InterlayAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  InterlayNetworkNativeAsset(
      {required this.asset,
      required this.metadata,
      bool? isFeeToken,
      required this.location})
      : super(
            isFeeToken: isFeeToken ??
                (metadata?.additional.feePerSecond ?? BigInt.zero) >
                    BigInt.zero,
            decimals: metadata?.decimals,
            isSpendable: asset.type == InterlayAssetType.token ||
                asset.type == InterlayAssetType.foreignAsset,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            excutionPallet: SubtrateMetadataPallet.tokens);

  factory InterlayNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    final asset = BaseInterlayAsset.fromJson(json.valueAs("asset"));
    final bool isFeeToken = json.valueAs("is_fee_token");
    final metadata = json.valueTo<InterlayAssetMetadata?, Map<String, dynamic>>(
        key: "metadata", parse: (v) => InterlayAssetMetadata.fromJson(json));
    return InterlayNetworkNativeAsset(
        asset: asset,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken,
        metadata: metadata);
  }

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "location": location?.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;
}
