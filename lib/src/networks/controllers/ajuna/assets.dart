import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/api.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/core.dart';
import 'package:polkadot_dart/src/networks/types/types/config.dart';

abstract class BaseAjunaNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseAjunaNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet,
      required super.chargeAssetTxPayment});
  BaseAjunaNetworkAsset.fromJson(super.json) : super.fromJson();
}

class AjunaNetworkAsset extends BaseAjunaNetworkAsset {
  final PolkadotAssetHubAsset asset;
  final PolkadotAssetHubAssetMetadata? metadata;
  @override
  final XCMVersionedLocation? location;

  final BigInt? unitsPerSecond;
  AjunaNetworkAsset(
      {required this.asset,
      required this.metadata,
      required super.isFeeToken,
      required super.chargeAssetTxPayment,
      this.unitsPerSecond,
      this.location})
      : super(
            decimals: metadata?.decimals,
            isSpendable:
                asset.asset.status != BasePolkadotNetworkAssetsStatus.frozen,
            excutionPallet: SubtrateMetadataPallet.assets,
            minBalance: asset.asset.minBalance,
            name: metadata?.name,
            symbol: metadata?.symbol);
  @override
  BigInt get identifier => asset.assetId;
  factory AjunaNetworkAsset.fromJson(Map<String, dynamic> json) {
    final asset = PolkadotAssetHubAsset.fromJson(json.valueAs("asset"));
    final metadata =
        json.valueTo<PolkadotAssetHubAssetMetadata?, Map<String, dynamic>>(
      key: "metadata",
      parse: (v) {
        return PolkadotAssetHubAssetMetadata.fromJson(v);
      },
    );
    final bool isFeeToken = json.valueAs("is_fee_token");
    return AjunaNetworkAsset(
        asset: asset,
        chargeAssetTxPayment: json.valueAs("charge_asset_tx_payment"),
        metadata: metadata,
        location: json.valueTo<XCMVersionedLocation?, Map<String, dynamic>>(
            key: "location", parse: (v) => XCMVersionedLocation.fromJson(v)),
        isFeeToken: isFeeToken,
        unitsPerSecond: json.valueAsBigInt("units_per_second"));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "metadata": metadata?.toJson(),
      "is_fee_token": isFeeToken,
      "units_per_second": unitsPerSecond?.toString(),
      "location": location?.toJson(),
      "charge_asset_tx_payment": chargeAssetTxPayment,
      "type": type.name
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }

  @override
  Object? get xTokenTransferId => throw DartSubstratePluginException(
      "This asset does not support transfers via the XTokens pallet. ");

  @override
  Object? asChargeTxPaymentAssetId(
      {required BaseSubstrateNetwork network, required XCMVersion version}) {
    if (chargeAssetTxPayment) {
      return {"WithId": asset.assetId};
    }
    return null;
  }
}

class AjunaNetworkNativeAsset extends BaseAjunaNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  AjunaNetworkNativeAsset(
      {required this.location,
      super.isFeeToken = true,
      super.isSpendable = true,
      required super.name,
      required super.symbol,
      required super.decimals,
      super.minBalance})
      : super(
            excutionPallet: SubtrateMetadataPallet.balances,
            chargeAssetTxPayment: true);
  AjunaNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }

  @override
  Object? get xTokenTransferId => {"AJUN": null};

  @override
  Object? asChargeTxPaymentAssetId(
      {required BaseSubstrateNetwork network, required XCMVersion version}) {
    if (chargeAssetTxPayment) {
      return {"Native": null};
    }
    return null;
  }
}
