import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum BifrostAssetNativeType {
  asg('ASG'),
  bnc('BNC'),
  kusd('KUSD'),
  dot('DOT'),
  ksm('KSM'),
  kar('KAR'),
  eth('ETH'),
  zlk('ZLK'),
  pha('PHA'),
  rmrk('RMRK'),
  movr('MOVR'),
  unknown("Unknown");

  final String type;

  const BifrostAssetNativeType(this.type);
  static BifrostAssetNativeType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? BifrostAssetNativeType.unknown;
  }
}

enum BifrostAssetType {
  native('Native'),
  vToken('VToken'),
  token('Token'),
  stable('Stable'),
  vsToken('VSToken'),
  vsBond("VSBond"),
  lpToken("LPToken"),
  foreignAsset('ForeignAsset'),
  token2("Token2"),
  vToken2("VToken2"),
  vsToken2("VSToken2"),
  vsBond2("VSBond2"),
  stableLpToken("StableLpToken"),
  blp("BLP"),
  lend("Lend"),
  unknown("Unknown");

  final String type;

  const BifrostAssetType(this.type);
  static BifrostAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? BifrostAssetType.unknown;
  }

  /// Returns true if this asset type is spendable by users.
  bool get isSpendable {
    switch (this) {
      case BifrostAssetType.native:
      case BifrostAssetType.token:
      case BifrostAssetType.token2:
      case BifrostAssetType.stable:
      case BifrostAssetType.foreignAsset:
      case BifrostAssetType.vToken:
      case BifrostAssetType.vToken2:
      case BifrostAssetType.vsToken:
      case BifrostAssetType.vsToken2:
        return true;
      default:
        return false;
    }
  }
}

class BifrostAsstConst {
  static final BaseBifrostAsset bnc =
      BifrostAssetNative(token: BifrostAssetNativeType.bnc, identifier: {
    BifrostAssetType.native.type: {BifrostAssetNativeType.bnc.type: null}
  });
}

abstract class BaseBifrostAsset {
  final Map<String, dynamic> identifier;
  final BifrostAssetType type;
  const BaseBifrostAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseBifrostAsset.fromJson(Map<String, dynamic> json) {
    final type = BifrostAssetType.fromJson(json);
    return switch (type) {
      BifrostAssetType.native => BifrostAssetNative.fromJson(json),
      BifrostAssetType.vToken => BifrostAssetVToken.fromJson(json),
      BifrostAssetType.token => BifrostAssetToken.fromJson(json),
      BifrostAssetType.stable => BifrostAssetStable.fromJson(json),
      BifrostAssetType.vsToken => BifrostAssetVSToken.fromJson(json),
      BifrostAssetType.vsBond => BifrostAssetVSBond.fromJson(json),
      BifrostAssetType.lpToken => BifrostAssetLPToken.fromJson(json),
      BifrostAssetType.foreignAsset => BifrostAssetForeignAsset.fromJson(json),
      BifrostAssetType.token2 => BifrostAssetToken2.fromJson(json),
      BifrostAssetType.vToken2 => BifrostAssetVToken2.fromJson(json),
      BifrostAssetType.vsToken2 => BifrostAssetVSToken2.fromJson(json),
      BifrostAssetType.vsBond2 => BifrostAssetVSBond2.fromJson(json),
      BifrostAssetType.stableLpToken =>
        BifrostAssetStableLpToken.fromJson(json),
      BifrostAssetType.blp => BifrostAssetBLP.fromJson(json),
      BifrostAssetType.lend => BifrostAssetLend.fromJson(json),
      BifrostAssetType.unknown => BifrostAssetUnknown.fromJson(json),
    };
  }
}

class BifrostAssetNative extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  const BifrostAssetNative({required this.token, required super.identifier})
      : super(type: BifrostAssetType.native);
  BifrostAssetNative.fromJson(Map<String, dynamic> json)
      : token = BifrostAssetNativeType.fromJson(
            json.valueAs(BifrostAssetType.native.type)),
        super(type: BifrostAssetType.native, identifier: json);
}

class BifrostAssetVToken extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  const BifrostAssetVToken({required this.token, required super.identifier})
      : super(type: BifrostAssetType.vToken);
  BifrostAssetVToken.fromJson(Map<String, dynamic> json)
      : token = BifrostAssetNativeType.fromJson(
            json.valueAs(BifrostAssetType.vToken.type)),
        super(type: BifrostAssetType.vToken, identifier: json);
}

class BifrostAssetToken extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  const BifrostAssetToken({required this.token, required super.identifier})
      : super(type: BifrostAssetType.token);
  BifrostAssetToken.fromJson(Map<String, dynamic> json)
      : token = BifrostAssetNativeType.fromJson(
            json.valueAs(BifrostAssetType.token.type)),
        super(type: BifrostAssetType.token, identifier: json);
}

class BifrostAssetStable extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  const BifrostAssetStable({required this.token, required super.identifier})
      : super(type: BifrostAssetType.stable);
  BifrostAssetStable.fromJson(Map<String, dynamic> json)
      : token = BifrostAssetNativeType.fromJson(
            json.valueAs(BifrostAssetType.stable.type)),
        super(type: BifrostAssetType.stable, identifier: json);
}

class BifrostAssetVSToken extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  const BifrostAssetVSToken({required this.token, required super.identifier})
      : super(type: BifrostAssetType.vsToken);
  BifrostAssetVSToken.fromJson(Map<String, dynamic> json)
      : token = BifrostAssetNativeType.fromJson(
            json.valueAs(BifrostAssetType.vsToken.type)),
        super(type: BifrostAssetType.vsToken, identifier: json);
}

class BifrostAssetVSBond extends BaseBifrostAsset {
  final BifrostAssetNativeType token;
  final int para;
  final int leaseStart;
  final int leaseEnd;

  const BifrostAssetVSBond(
      {required this.token,
      required this.para,
      required this.leaseStart,
      required this.leaseEnd,
      required super.identifier})
      : super(type: BifrostAssetType.vsBond);
  factory BifrostAssetVSBond.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList(BifrostAssetType.vsBond.type);
    return BifrostAssetVSBond(
        token: BifrostAssetNativeType.fromJson(data[0]),
        para: IntUtils.parse(data[1], allowHex: false),
        leaseStart: IntUtils.parse(data[2], allowHex: false),
        leaseEnd: IntUtils.parse(data[3], allowHex: false),
        identifier: json);
  }
}

class BifrostAssetLPToken extends BaseBifrostAsset {
  final BifrostAssetNativeType tokenA;
  final int indexA;
  final BifrostAssetNativeType tokenB;
  final int indexB;

  const BifrostAssetLPToken(
      {required this.tokenA,
      required this.indexA,
      required this.tokenB,
      required this.indexB,
      required super.identifier})
      : super(type: BifrostAssetType.lpToken);
  factory BifrostAssetLPToken.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList(BifrostAssetType.lpToken.type);
    return BifrostAssetLPToken(
        tokenA: BifrostAssetNativeType.fromJson(data[0]),
        indexA: IntUtils.parse(data[1], allowHex: false),
        tokenB: BifrostAssetNativeType.fromJson(data[2]),
        indexB: IntUtils.parse(data[3], allowHex: false),
        identifier: json);
  }
}

class BifrostAssetForeignAsset extends BaseBifrostAsset {
  final int id;
  const BifrostAssetForeignAsset({required this.id, required super.identifier})
      : super(type: BifrostAssetType.foreignAsset);
  BifrostAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.foreignAsset.type),
        super(type: BifrostAssetType.foreignAsset, identifier: json);
}

class BifrostAssetToken2 extends BaseBifrostAsset {
  final int id;
  const BifrostAssetToken2({required this.id, required super.identifier})
      : super(type: BifrostAssetType.token2);
  BifrostAssetToken2.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.token2.type),
        super(type: BifrostAssetType.token2, identifier: json);
}

class BifrostAssetVToken2 extends BaseBifrostAsset {
  final int id;
  const BifrostAssetVToken2({required this.id, required super.identifier})
      : super(type: BifrostAssetType.vToken2);
  BifrostAssetVToken2.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.vToken2.type),
        super(type: BifrostAssetType.vToken2, identifier: json);
}

class BifrostAssetVSToken2 extends BaseBifrostAsset {
  final int id;
  const BifrostAssetVSToken2({required this.id, required super.identifier})
      : super(type: BifrostAssetType.vsToken2);
  BifrostAssetVSToken2.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.vsToken2.type),
        super(type: BifrostAssetType.vsToken2, identifier: json);
}

class BifrostAssetVSBond2 extends BaseBifrostAsset {
  final int a;
  final int b;
  final int c;
  final int d;

  const BifrostAssetVSBond2(
      {required this.a,
      required this.b,
      required this.c,
      required this.d,
      required super.identifier})
      : super(type: BifrostAssetType.vsBond2);
  factory BifrostAssetVSBond2.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsList(BifrostAssetType.vsBond2.type);
    return BifrostAssetVSBond2(
        a: IntUtils.parse(data[0], allowHex: false),
        b: IntUtils.parse(data[1], allowHex: false),
        c: IntUtils.parse(data[2], allowHex: false),
        d: IntUtils.parse(data[3], allowHex: false),
        identifier: json);
  }
}

class BifrostAssetStableLpToken extends BaseBifrostAsset {
  final int id;
  const BifrostAssetStableLpToken({required this.id, required super.identifier})
      : super(type: BifrostAssetType.stableLpToken);
  BifrostAssetStableLpToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.stableLpToken.type),
        super(type: BifrostAssetType.stableLpToken, identifier: json);
}

class BifrostAssetBLP extends BaseBifrostAsset {
  final int id;
  const BifrostAssetBLP({required this.id, required super.identifier})
      : super(type: BifrostAssetType.blp);
  BifrostAssetBLP.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.blp.type),
        super(type: BifrostAssetType.blp, identifier: json);
}

class BifrostAssetLend extends BaseBifrostAsset {
  final int id;
  const BifrostAssetLend({required this.id, required super.identifier})
      : super(type: BifrostAssetType.lend);
  BifrostAssetLend.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(BifrostAssetType.lend.type),
        super(type: BifrostAssetType.lend, identifier: json);
}

class BifrostAssetUnknown extends BaseBifrostAsset {
  const BifrostAssetUnknown({required super.identifier})
      : super(type: BifrostAssetType.unknown);
  BifrostAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: BifrostAssetType.unknown, identifier: json);
}

class BifrostAssetMetadata {
  final BigInt minimalBalance;
  final String name;
  final String symbol;
  final int decimals;
  // final bool isFrozen;
  BifrostAssetMetadata.fromJson(Map<String, dynamic> json)
      : minimalBalance = json.valueAsBigInt("minimal_balance"),
        decimals = json.valueAsInt("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        super();
  const BifrostAssetMetadata(
      {required this.minimalBalance,
      required this.name,
      required this.symbol,
      required this.decimals});
  Map<String, dynamic> toJson() {
    return {
      "minimal_balance": minimalBalance.toString(),
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
    };
  }
}

abstract class BaseBifrostNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseBifrostNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseBifrostNetworkAsset.fromJson(super.json) : super.fromJson();
}

class BifrostNetworkAsset extends BaseBifrostNetworkAsset {
  final BaseBifrostAsset asset;
  final BifrostAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  BifrostNetworkAsset(
      {required this.asset,
      required this.metadata,
      required super.isFeeToken,
      this.location})
      : super(
            isSpendable: asset.type.isSpendable,
            minBalance: metadata?.minimalBalance,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.tokens);
  @override
  int? get decimals => metadata?.decimals;

  @override
  Map<String, dynamic> get identifier => asset.toJson();
  factory BifrostNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = BaseBifrostAsset.fromJson(json.valueAs("asset"));
    final metadata = json.valueTo<BifrostAssetMetadata?, Map<String, dynamic>>(
      key: "metadata",
      parse: (v) {
        return BifrostAssetMetadata.fromJson(v);
      },
    );
    final bool isFeeToken = json.valueAs("is_fee_token");
    return BifrostNetworkAsset(
        asset: asset,
        metadata: metadata,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
        isFeeToken: isFeeToken);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "location": location?.toJson(),
      "is_fee_token": isFeeToken
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class BifrostNetworkNativeAsset extends BaseBifrostNetworkAsset {
  final BaseBifrostAsset asset;
  final BifrostAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  BifrostNetworkNativeAsset({required this.metadata, this.location})
      : asset = BifrostAsstConst.bnc,
        super(
            isSpendable: true,
            isFeeToken: true,
            minBalance: metadata?.minimalBalance,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.tokens);
  factory BifrostNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    final metadata = json.valueTo<BifrostAssetMetadata?, Map<String, dynamic>>(
      key: "metadata",
      parse: (v) {
        return BifrostAssetMetadata.fromJson(v);
      },
    );
    return BifrostNetworkNativeAsset(
      metadata: metadata,
      location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
          key: "location", parse: (v) => XCMVersionedLocation.fromJson(json)),
    );
  }
  @override
  SubstrateAssetType get type => SubstrateAssetType.native;
  @override
  SubtrateMetadataPallet get excutionPallet => SubtrateMetadataPallet.balances;

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "location": location?.toJson(),
      "is_fee_token": isFeeToken
    };
  }
}
