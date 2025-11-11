import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum AcalaAssetTokenType {
  aca('ACA'),
  ausd('AUSD'),
  dot('DOT'),
  ldot('LDOT'),
  tap('TAP'),
  kar('KAR'),
  kusd('KUSD'),
  ksm('KSM'),
  lksm('LKSM'),
  tai('TAI'),
  bnc('BNC'),
  vskSm('VSKSM'),
  pha('PHA'),
  kint('KINT'),
  kbtc('KBTC'),
  unknown("Unknown");

  final String type;

  const AcalaAssetTokenType(this.type);
  static AcalaAssetTokenType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? AcalaAssetTokenType.unknown;
  }
}

enum AcalaAssetType {
  token('Token'),
  dexShare('DexShare'),
  erc20('Erc20'),
  stableAssetPoolToken('StableAssetPoolToken'),
  liquidCrowdloan('LiquidCrowdloan'),
  foreignAsset('ForeignAsset'),
  unknown("Unknown");

  final String type;

  const AcalaAssetType(this.type);
  static AcalaAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? AcalaAssetType.unknown;
  }
}

class AcalaAsstConst {
  static final BaseAcalaAsset tap =
      AcalaAssetToken(token: AcalaAssetTokenType.tap, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.tap.type: null}
  });
  static final BaseAcalaAsset lksm =
      AcalaAssetToken(token: AcalaAssetTokenType.lksm, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.lksm.type: null}
  });
  static final BaseAcalaAsset kint =
      AcalaAssetToken(token: AcalaAssetTokenType.kint, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.kint.type: null}
  });
  static final BaseAcalaAsset kusd =
      AcalaAssetToken(token: AcalaAssetTokenType.kusd, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.kusd.type: null}
  });
  static final BaseAcalaAsset kbtc =
      AcalaAssetToken(token: AcalaAssetTokenType.kbtc, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.kbtc.type: null}
  });
  static final BaseAcalaAsset tai =
      AcalaAssetToken(token: AcalaAssetTokenType.tai, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.tai.type: null}
  });
  static final BaseAcalaAsset ausd =
      AcalaAssetToken(token: AcalaAssetTokenType.ausd, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.ausd.type: null}
  });
  static final BaseAcalaAsset lDot =
      AcalaAssetToken(token: AcalaAssetTokenType.ldot, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.ldot.type: null}
  });
  static final BaseAcalaAsset dot =
      AcalaAssetToken(token: AcalaAssetTokenType.dot, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.dot.type: null}
  });
  static final BaseAcalaAsset aca =
      AcalaAssetToken(token: AcalaAssetTokenType.aca, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.aca.type: null}
  });
  static final BaseAcalaAsset vskSm =
      AcalaAssetToken(token: AcalaAssetTokenType.vskSm, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.vskSm.type: null}
  });
  static final BaseAcalaAsset pha =
      AcalaAssetToken(token: AcalaAssetTokenType.pha, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.pha.type: null}
  });
  static final BaseAcalaAsset ksm =
      AcalaAssetToken(token: AcalaAssetTokenType.ksm, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.ksm.type: null}
  });
  static final BaseAcalaAsset bnc =
      AcalaAssetToken(token: AcalaAssetTokenType.bnc, identifier: {
    AcalaAssetType.token.type: {AcalaAssetTokenType.bnc.type: null}
  });
  // static final Map<String, dynamic> acaIdentifier = {
  //   AcalaAssetType.token.type: {AcalaAssetTokenType.aca.type: null}
  // };
}

abstract class BaseAcalaAsset {
  final Map<String, dynamic> identifier;
  final AcalaAssetType type;
  const BaseAcalaAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseAcalaAsset.fromJson(Map<String, dynamic> json) {
    final type = AcalaAssetType.fromJson(json);
    return switch (type) {
      AcalaAssetType.token => AcalaAssetToken.fromJson(json),
      AcalaAssetType.erc20 => AcalaAssetErc20.fromJson(json),
      AcalaAssetType.stableAssetPoolToken =>
        AcalaAssetStableAssetPoolToken.fromJson(json),
      AcalaAssetType.liquidCrowdloan =>
        AcalaAssetLiquidCrowdloanToken.fromJson(json),
      AcalaAssetType.foreignAsset => AcalaAssetForeignAsset.fromJson(json),
      AcalaAssetType.dexShare => AcalaAssetDexShare.fromJson(json),
      AcalaAssetType.unknown => AcalaAssetUnknown.fromJson(json),
    };
  }
}

class AcalaAssetToken extends BaseAcalaAsset {
  final AcalaAssetTokenType token;
  const AcalaAssetToken({required this.token, required super.identifier})
      : super(type: AcalaAssetType.token);
  AcalaAssetToken.fromJson(Map<String, dynamic> json)
      : token = AcalaAssetTokenType.fromJson(
            json.valueAs(AcalaAssetType.token.type)),
        super(type: AcalaAssetType.token, identifier: json);
}

class AcalaAssetErc20 extends BaseAcalaAsset {
  final SubstrateEthereumAddress address;
  const AcalaAssetErc20({required this.address, required super.identifier})
      : super(type: AcalaAssetType.erc20);
  AcalaAssetErc20.fromJson(Map<String, dynamic> json)
      : address = SubstrateEthereumAddress.fromBytes(
            json.valueAsBytes(AcalaAssetType.erc20.type)),
        super(type: AcalaAssetType.erc20, identifier: json);
}

class AcalaAssetStableAssetPoolToken extends BaseAcalaAsset {
  final int id;
  const AcalaAssetStableAssetPoolToken(
      {required this.id, required super.identifier})
      : super(type: AcalaAssetType.stableAssetPoolToken);
  AcalaAssetStableAssetPoolToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(AcalaAssetType.stableAssetPoolToken.type),
        super(type: AcalaAssetType.stableAssetPoolToken, identifier: json);
}

class AcalaAssetLiquidCrowdloanToken extends BaseAcalaAsset {
  final int id;
  const AcalaAssetLiquidCrowdloanToken(
      {required this.id, required super.identifier})
      : super(type: AcalaAssetType.liquidCrowdloan);
  AcalaAssetLiquidCrowdloanToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(AcalaAssetType.liquidCrowdloan.type),
        super(type: AcalaAssetType.liquidCrowdloan, identifier: json);
}

class AcalaAssetForeignAsset extends BaseAcalaAsset {
  final int id;
  const AcalaAssetForeignAsset({required this.id, required super.identifier})
      : super(type: AcalaAssetType.foreignAsset);
  AcalaAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(AcalaAssetType.foreignAsset.type),
        super(type: AcalaAssetType.foreignAsset, identifier: json);
}

class AcalaAssetUnknown extends BaseAcalaAsset {
  const AcalaAssetUnknown({required super.identifier})
      : super(type: AcalaAssetType.foreignAsset);
  AcalaAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: AcalaAssetType.unknown, identifier: json);
}

class AcalaAssetDexShare extends BaseAcalaAsset {
  final List<BaseAcalaAsset> assets;
  const AcalaAssetDexShare({required this.assets, required super.identifier})
      : super(type: AcalaAssetType.dexShare);
  AcalaAssetDexShare.fromJson(Map<String, dynamic> json)
      : assets = json
            .valueEnsureAsList(AcalaAssetType.dexShare.type)
            .map((e) => BaseAcalaAsset.fromJson(e))
            .toList(),
        super(type: AcalaAssetType.dexShare, identifier: json);
}

class AcalaAssetMetadata {
  final BigInt minimalBalance;
  final String name;
  final String symbol;
  final int decimals;
  // final bool isFrozen;
  AcalaAssetMetadata.fromJson(Map<String, dynamic> json)
      : minimalBalance = json.valueAs("minimal_balance"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        super();
  const AcalaAssetMetadata(
      {required this.minimalBalance,
      required this.name,
      required this.symbol,
      required this.decimals});
  Map<String, dynamic> toJson() {
    return {
      "minimal_balance": minimalBalance,
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
    };
  }
}

class AcalaNetworkAsset extends BaseSubstrateNetworkAsset {
  final BaseAcalaAsset asset;
  final AcalaAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  AcalaNetworkAsset(
      {required this.asset,
      required this.metadata,
      required super.isFeeToken,
      this.location})
      : super(
            isSpendable: asset.type == AcalaAssetType.token ||
                asset.type == AcalaAssetType.foreignAsset,
            minBalance: metadata?.minimalBalance,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.currencies);
  factory AcalaNetworkAsset.fromJson(Map<String, dynamic> json) {
    return AcalaNetworkAsset(
        asset: BaseAcalaAsset.fromJson(json.valueAs("asset")),
        metadata: json.valueTo<AcalaAssetMetadata?, Map<String, dynamic>>(
            key: "metadata", parse: AcalaAssetMetadata.fromJson),
        isFeeToken: json.valueAs("is_fee_token"),
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: XCMVersionedLocation.fromJson));
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
      "location": location?.toJson(),
      "is_fee_token": isFeeToken,
      "type": type.name
    };
  }

  @override
  SubtrateMetadataPallet get excutionPallet =>
      SubtrateMetadataPallet.currencies;

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class AcalaNetworkNativeAsset extends AcalaNetworkAsset {
  AcalaNetworkNativeAsset({
    required super.metadata,
    required super.location,
  }) : super(asset: AcalaAsstConst.aca, isFeeToken: true);

  factory AcalaNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    return AcalaNetworkNativeAsset(
        metadata: json.valueTo<AcalaAssetMetadata?, Map<String, dynamic>>(
            key: "metadata", parse: AcalaAssetMetadata.fromJson),
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: XCMVersionedLocation.fromJson));
  }

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;
  @override
  SubtrateMetadataPallet get excutionPallet => SubtrateMetadataPallet.balances;
}

class TokenPalletAccountBalance {
  final BigInt free;
  final BigInt reserved;
  final BigInt frozen;
  const TokenPalletAccountBalance(
      {required this.free, required this.reserved, required this.frozen});
  TokenPalletAccountBalance.fromJson(Map<String, dynamic> json)
      : free = json.valueAs("free"),
        reserved = json.valueAs("reserved"),
        frozen = json.valueAs("frozen");
  Map<String, dynamic> toJson() {
    return {
      "free": free.toString(),
      "reserved": reserved.toString(),
      "frozen": frozen.toString(),
    };
  }
}
