import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum PendulumAssetStellarType {
  stellarNative('StellarNative'),
  alphaNum4('AlphaNum4'),
  alphaNum12('AlphaNum12'),
  unknown("Unknown");

  final String type;

  const PendulumAssetStellarType(this.type);
  static PendulumAssetStellarType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? PendulumAssetStellarType.unknown;
  }
}

enum PendulumAssetType {
  native('Native'),
  xcm('XCM'),
  stellar('Stellar'),
  zenlinkLPToken('ZenlinkLPToken'),
  token('Token'),
  unknown("Unknown");

  final String type;

  const PendulumAssetType(this.type);
  static PendulumAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? PendulumAssetType.unknown;
  }
}

class PendulumAsstConst {
  static final BasePendulumAsset cfg =
      PendulumAssetNative(identifier: {PendulumAssetType.native.type: null});
}

abstract class BasePendulumAsset {
  final Map<String, dynamic> identifier;
  final PendulumAssetType type;
  const BasePendulumAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BasePendulumAsset.fromJson(Map<String, dynamic> json) {
    final type = PendulumAssetType.fromJson(json);
    return switch (type) {
      PendulumAssetType.xcm => PendulumAssetXCM.fromJson(json),
      PendulumAssetType.native => PendulumAssetNative.fromJson(json),
      PendulumAssetType.stellar => PendulumAssetStellar.fromJson(json),
      PendulumAssetType.zenlinkLPToken =>
        PendulumAssetZenlinkLPToken.fromJson(json),
      PendulumAssetType.token => PendulumAssetToken.fromJson(json),
      PendulumAssetType.unknown => PendulumAssetUnknown.fromJson(json),
    };
  }
}

class PendulumAssetNative extends BasePendulumAsset {
  const PendulumAssetNative({required super.identifier})
      : super(type: PendulumAssetType.native);
  PendulumAssetNative.fromJson(Map<String, dynamic> json)
      : super(type: PendulumAssetType.native, identifier: json);
}

abstract class BasePendulumAssetStellar {
  final Map<String, dynamic> identifier;
  final PendulumAssetStellarType stellarAssetType;
  const BasePendulumAssetStellar(
      {required this.stellarAssetType, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BasePendulumAssetStellar.fromJson(Map<String, dynamic> json) {
    final type = PendulumAssetStellarType.fromJson(json);
    return switch (type) {
      PendulumAssetStellarType.stellarNative =>
        PendulumStellarAssetNative.fromJson(json),
      PendulumAssetStellarType.alphaNum4 =>
        PendulumStellarAssetAlphaNum4.fromJson(json),
      PendulumAssetStellarType.alphaNum12 =>
        PendulumStellarAssetAlphaNum12.fromJson(json),
      PendulumAssetStellarType.unknown =>
        PendulumStellarAssetUnknown.fromJson(json),
    };
  }
}

class PendulumStellarAssetNative extends BasePendulumAssetStellar {
  const PendulumStellarAssetNative({required super.identifier})
      : super(stellarAssetType: PendulumAssetStellarType.stellarNative);
  PendulumStellarAssetNative.fromJson(Map<String, dynamic> json)
      : super(
            stellarAssetType: PendulumAssetStellarType.stellarNative,
            identifier: json);
}

class PendulumStellarAssetAlphaNum4 extends BasePendulumAssetStellar {
  final List<int> issuer;
  final List<int> code;
  PendulumStellarAssetAlphaNum4(
      {required List<int> issuer,
      required List<int> code,
      required super.identifier})
      : issuer = issuer.exc(32).asImmutableBytes,
        code = code.exc(4).asImmutableBytes,
        super(stellarAssetType: PendulumAssetStellarType.alphaNum4);
  factory PendulumStellarAssetAlphaNum4.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        PendulumAssetStellarType.alphaNum4.type);
    return PendulumStellarAssetAlphaNum4(
        issuer: data.valueAsBytes("issuer"),
        code: data.valueAsBytes("code"),
        identifier: json);
  }
}

class PendulumStellarAssetAlphaNum12 extends BasePendulumAssetStellar {
  final List<int> issuer;
  final List<int> code;
  PendulumStellarAssetAlphaNum12(
      {required List<int> issuer,
      required List<int> code,
      required super.identifier})
      : issuer = issuer.exc(32).asImmutableBytes,
        code = code.exc(12).asImmutableBytes,
        super(stellarAssetType: PendulumAssetStellarType.alphaNum12);
  factory PendulumStellarAssetAlphaNum12.fromJson(Map<String, dynamic> json) {
    final data = json.valueEnsureAsMap<String, dynamic>(
        PendulumAssetStellarType.alphaNum12.type);
    return PendulumStellarAssetAlphaNum12(
        issuer: data.valueAsBytes("issuer"),
        code: data.valueAsBytes("code"),
        identifier: json);
  }
}

class PendulumStellarAssetUnknown extends BasePendulumAssetStellar {
  PendulumStellarAssetUnknown({required super.identifier})
      : super(stellarAssetType: PendulumAssetStellarType.unknown);
  PendulumStellarAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(
            stellarAssetType: PendulumAssetStellarType.stellarNative,
            identifier: json);
}

class PendulumAssetStellar extends BasePendulumAsset {
  final BasePendulumAssetStellar asset;
  const PendulumAssetStellar({required super.identifier, required this.asset})
      : super(type: PendulumAssetType.stellar);

  PendulumAssetStellar.fromJson(Map<String, dynamic> json)
      : asset = BasePendulumAssetStellar.fromJson(
            json.valueEnsureAsMap(PendulumAssetType.stellar.type)),
        super(type: PendulumAssetType.stellar, identifier: json);
}

class PendulumAssetZenlinkLPToken extends BasePendulumAsset {
  final int a;
  final int b;
  final int c;
  final int d;
  const PendulumAssetZenlinkLPToken(
      {required this.a,
      required this.b,
      required this.c,
      required this.d,
      required super.identifier})
      : super(type: PendulumAssetType.zenlinkLPToken);
  factory PendulumAssetZenlinkLPToken.fromJson(Map<String, dynamic> json) {
    final data =
        json.valueEnsureAsList<int>(PendulumAssetType.zenlinkLPToken.type);
    return PendulumAssetZenlinkLPToken(
        a: data[0], b: data[1], c: data[2], d: data[3], identifier: json);
  }
}

class PendulumAssetXCM extends BasePendulumAsset {
  final int id;
  const PendulumAssetXCM({required this.id, required super.identifier})
      : super(type: PendulumAssetType.xcm);
  PendulumAssetXCM.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(PendulumAssetType.xcm.type),
        super(type: PendulumAssetType.xcm, identifier: json);
}

class PendulumAssetToken extends BasePendulumAsset {
  final BigInt id;
  const PendulumAssetToken({required this.id, required super.identifier})
      : super(type: PendulumAssetType.token);
  PendulumAssetToken.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(PendulumAssetType.token.type),
        super(type: PendulumAssetType.token, identifier: json);
}

class PendulumAssetUnknown extends BasePendulumAsset {
  const PendulumAssetUnknown({required super.identifier})
      : super(type: PendulumAssetType.unknown);
  PendulumAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: PendulumAssetType.unknown, identifier: json);
}

class PendulumAssetMetadatAdditionalDiaKeys {
  final String blockchain;
  final String symbol;
  const PendulumAssetMetadatAdditionalDiaKeys(
      {required this.blockchain, required this.symbol});
  factory PendulumAssetMetadatAdditionalDiaKeys.fromJson(
      Map<String, dynamic> json) {
    return PendulumAssetMetadatAdditionalDiaKeys(
        symbol:
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        blockchain: SubstrateNetworkControllerUtils.tryToUtf8(
            json.valueAs("blockchain")));
  }
  Map<String, dynamic> toJson() {
    return {"symbol": symbol, "blockchain": blockchain};
  }
}

class PendulumAssetMetadatAdditional {
  final PendulumAssetMetadatAdditionalDiaKeys diaKeys;
  final BigInt feePerSecond;
  const PendulumAssetMetadatAdditional(
      {required this.diaKeys, required this.feePerSecond});
  PendulumAssetMetadatAdditional.fromJson(Map<String, dynamic> json)
      : diaKeys = PendulumAssetMetadatAdditionalDiaKeys.fromJson(
            json.valueAs("dia_keys")),
        feePerSecond = json.valueAs("fee_per_second");
  Map<String, dynamic> toJson() {
    return {
      "fee_per_second": feePerSecond.toString(),
      "dia_keys": diaKeys.toJson()
    };
  }
}

class PendulumAssetMetadata {
  final int decimals;
  final BigInt existentialDeposit;
  final String name;
  final String symbol;
  final XCMVersionedLocation? location;
  final PendulumAssetMetadatAdditional? additional;
  PendulumAssetMetadata copyWith({
    int? decimals,
    BigInt? existentialDeposit,
    String? name,
    String? symbol,
    XCMVersionedLocation? location,
    PendulumAssetMetadatAdditional? additional,
  }) {
    return PendulumAssetMetadata(
      decimals: decimals ?? this.decimals,
      existentialDeposit: existentialDeposit ?? this.existentialDeposit,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      location: location ?? this.location,
      additional: additional ?? this.additional,
    );
  }

  // final bool isFrozen;
  PendulumAssetMetadata.fromJson(Map<String, dynamic> json)
      : existentialDeposit = json.valueAs("existential_deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        additional =
            json.valueTo<PendulumAssetMetadatAdditional?, Map<String, dynamic>>(
                key: "additional",
                parse: (v) => PendulumAssetMetadatAdditional.fromJson(v)),
        location = MetadataUtils.parseOptional<XCMVersionedLocation,
                Map<String, dynamic>>(json.valueAs("location"),
            parse: (v) => XCMVersionedLocation.fromJson(v)),
        super();
  const PendulumAssetMetadata(
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

abstract class BasePendulumNetworkAsset extends BaseSubstrateNetworkAsset {
  BasePendulumNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BasePendulumNetworkAsset.fromJson(super.json) : super.fromJson();
}

class PendulumNetworkAsset extends BasePendulumNetworkAsset {
  final BasePendulumAsset asset;
  final PendulumAssetMetadata? metadata;
  @override
  XCMVersionedLocation? get location => metadata?.location;
  PendulumNetworkAsset({
    required this.asset,
    required this.metadata,
    bool? isFeeToken,
  }) : super(
            isFeeToken: isFeeToken ??
                ((metadata?.additional?.feePerSecond ?? BigInt.zero) >
                    BigInt.zero),
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.currencies);
  factory PendulumNetworkAsset.fromJson(Map<String, dynamic> json) {
    return PendulumNetworkAsset(
      asset: BasePendulumAsset.fromJson(json.valueAs("asset")),
      metadata: json.valueTo<PendulumAssetMetadata?, Map<String, dynamic>>(
          key: "metadata", parse: (v) => PendulumAssetMetadata.fromJson(v)),
      isFeeToken: json.valueAs("is_fee_token"),
    );
  }

  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
    };
  }

  List get variabels => [asset, location];

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class PendulumNetworkNativeAsset extends BasePendulumNetworkAsset {
  final BasePendulumAsset asset;
  final PendulumAssetMetadata? metadata;
  @override
  XCMVersionedLocation? get location => metadata?.location;

  PendulumNetworkNativeAsset({
    BasePendulumAsset? asset,
    required this.metadata,
  })  : asset = asset ?? PendulumAsstConst.cfg,
        super(
            isFeeToken: true,
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.balances);
  factory PendulumNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    return PendulumNetworkNativeAsset(
      asset: BasePendulumAsset.fromJson(json.valueAs("asset")),
      metadata: json.valueTo<PendulumAssetMetadata?, Map<String, dynamic>>(
          key: "metadata", parse: (v) => PendulumAssetMetadata.fromJson(v)),
    );
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

  List get variabels => [asset, location];

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;
}
