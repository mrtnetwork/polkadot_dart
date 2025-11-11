import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/types/types.dart';
import 'package:polkadot_dart/src/networks/utils/utils.dart';

enum JamtonAssetType {
  native('Native'),
  dexShare('DexShare'),
  foreignAsset('ForeignAsset'),
  unknown("Unknown");

  final String type;

  const JamtonAssetType(this.type);
  static JamtonAssetType fromJson(Map<String, dynamic>? json) {
    final type =
        values.firstWhereNullable((e) => e.type == json?.keys.firstOrNull);
    return type ?? JamtonAssetType.unknown;
  }
}

class JamtonAsstConst {
  static final BaseJamtonAsset jamtom =
      JamtonAssetNative(id: 0, identifier: {JamtonAssetType.native.type: 0});
}

abstract class BaseJamtonAsset {
  final Map<String, dynamic> identifier;
  final JamtonAssetType type;
  const BaseJamtonAsset({required this.type, required this.identifier});
  Map<String, dynamic> toJson() => identifier;
  factory BaseJamtonAsset.fromJson(Map<String, dynamic> json) {
    final type = JamtonAssetType.fromJson(json);
    return switch (type) {
      JamtonAssetType.native => JamtonAssetNative.fromJson(json),
      JamtonAssetType.foreignAsset => JamtonAssetForeignAsset.fromJson(json),
      JamtonAssetType.dexShare => JamtonAssetDexShare.fromJson(json),
      JamtonAssetType.unknown => JamtonAssetUnknown.fromJson(json),
    };
  }
}

class JamtonAssetForeignAsset extends BaseJamtonAsset {
  final int id;
  const JamtonAssetForeignAsset({required this.id, required super.identifier})
      : super(type: JamtonAssetType.foreignAsset);
  JamtonAssetForeignAsset.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(JamtonAssetType.foreignAsset.type),
        super(type: JamtonAssetType.foreignAsset, identifier: json);
}

class JamtonAssetNative extends BaseJamtonAsset {
  final int id;
  const JamtonAssetNative({required this.id, required super.identifier})
      : super(type: JamtonAssetType.native);
  JamtonAssetNative.fromJson(Map<String, dynamic> json)
      : id = json.valueAs(JamtonAssetType.native.type),
        super(type: JamtonAssetType.native, identifier: json);
}

class JamtonAssetUnknown extends BaseJamtonAsset {
  const JamtonAssetUnknown({required super.identifier})
      : super(type: JamtonAssetType.foreignAsset);
  JamtonAssetUnknown.fromJson(Map<String, dynamic> json)
      : super(type: JamtonAssetType.unknown, identifier: json);
}

class JamtonAssetDexShare extends BaseJamtonAsset {
  final List<BaseJamtonAsset> assets;
  const JamtonAssetDexShare({required this.assets, required super.identifier})
      : super(type: JamtonAssetType.dexShare);
  JamtonAssetDexShare.fromJson(Map<String, dynamic> json)
      : assets = json
            .valueEnsureAsList(JamtonAssetType.dexShare.type)
            .map((e) => BaseJamtonAsset.fromJson(e))
            .toList(),
        super(type: JamtonAssetType.dexShare, identifier: json);
}

class JamtonAssetMetadata {
  final BigInt existentialDeposit;
  final String name;
  final String symbol;
  final int decimals;
  final XCMVersionedLocation? location;
  // final bool isFrozen;
  JamtonAssetMetadata.fromJson(Map<String, dynamic> json)
      : existentialDeposit = json.valueAs("existential_deposit"),
        decimals = json.valueAs("decimals"),
        name = SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("name")),
        symbol =
            SubstrateNetworkControllerUtils.tryToUtf8(json.valueAs("symbol")),
        location = MetadataUtils.parseOptional<XCMVersionedLocation,
            Map<String, dynamic>>(
          json.valueAs("location"),
          parse: (v) {
            return XCMVersionedLocation.fromJson(v);
          },
        ),
        super();
  const JamtonAssetMetadata(
      {required this.existentialDeposit,
      required this.name,
      required this.symbol,
      required this.decimals,
      this.location});
  Map<String, dynamic> toJson() {
    return {
      "existential_deposit": existentialDeposit.toString(),
      "name": name,
      "symbol": symbol,
      "decimals": decimals,
      "location": location?.toJson()
    };
  }
}

abstract class BaseJamtonNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseJamtonNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet,
      required super.chargeAssetTxPayment});

  BaseJamtonNetworkAsset.fromJson(super.json) : super.fromJson();

  @override
  Object? asChargeTxPaymentAssetId(
      {required BaseSubstrateNetwork network, required XCMVersion version}) {
    if (chargeAssetTxPayment) {
      return getAssetId(version: version, reserveNetwork: network).toJson();
    }
    return null;
  }
}

class JamtonNetworkAsset extends BaseJamtonNetworkAsset {
  final BaseJamtonAsset asset;
  final JamtonAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  JamtonNetworkAsset({
    required this.asset,
    required this.metadata,
    required super.isFeeToken,
    required super.chargeAssetTxPayment,
    required this.location,
  }) : super(
            isSpendable: asset.type == JamtonAssetType.native ||
                asset.type == JamtonAssetType.foreignAsset,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.currencies);
  factory JamtonNetworkAsset.fromJson(Map<String, dynamic> json) {
    return JamtonNetworkAsset(
      asset: BaseJamtonAsset.fromJson(json.valueAs("asset")),
      metadata: json.valueTo<JamtonAssetMetadata?, Map<String, dynamic>>(
          key: "metadata", parse: JamtonAssetMetadata.fromJson),
      isFeeToken: json.valueAs("is_fee_token"),
      chargeAssetTxPayment: json.valueAs("charge_asset_tx_payment"),
      location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
          key: "location", parse: XCMVersionedLocation.fromJson),
    );
  }
  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "location": location?.toJson(),
      "is_fee_token": isFeeToken,
      "charge_asset_tx_payment": chargeAssetTxPayment
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    if (identifier is! Map) return false;
    return CompareUtils.mapIsEqual(this.identifier, identifier);
  }
}

class JamtonNetworkNativeAsset extends BaseJamtonNetworkAsset {
  final BaseJamtonAsset asset;
  final JamtonAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;
  JamtonNetworkNativeAsset({
    BaseJamtonAsset? asset,
    required this.metadata,
    required this.location,
  })  : asset = asset ?? JamtonAsstConst.jamtom,
        super(
            chargeAssetTxPayment: true,
            isFeeToken: true,
            isSpendable: true,
            minBalance: metadata?.existentialDeposit,
            name: metadata?.name,
            symbol: metadata?.symbol,
            decimals: metadata?.decimals,
            excutionPallet: SubtrateMetadataPallet.balances);
  factory JamtonNetworkNativeAsset.fromJson(Map<String, dynamic> json) {
    return JamtonNetworkNativeAsset(
      asset: BaseJamtonAsset.fromJson(json.valueAs("asset")),
      metadata: json.valueTo<JamtonAssetMetadata?, Map<String, dynamic>>(
          key: "metadata", parse: JamtonAssetMetadata.fromJson),
      location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
          key: "location", parse: XCMVersionedLocation.fromJson),
    );
  }
  @override
  Map<String, dynamic> get identifier => asset.toJson();

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "location": location?.toJson(),
      "is_fee_token": isFeeToken,
      "charge_asset_tx_payment": chargeAssetTxPayment
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
