import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/utils.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';

class MoonbeamForeignAsset {
  final String assetId;
  final String? name;
  final String symbol;
  final int decimals;
  final XCMVersionedLocation location;
  const MoonbeamForeignAsset(
      {required this.assetId,
      required this.name,
      required this.symbol,
      required this.decimals,
      required this.location});
  factory MoonbeamForeignAsset.fromJson(Map<String, dynamic> json) {
    return MoonbeamForeignAsset(
        name: json.valueAs("name"),
        symbol: json.valueAs("symbol"),
        decimals: json.valueAs("decimals"),
        assetId: json.valueAs("asset_id"),
        location:
            XCMVersionedLocation.deserialize(json.valueAsBytes("location")));
  }
  Map<String, dynamic> toJson() {
    return {
      "asset_id": assetId,
      "name": name,
      "symbol": symbol,
      "decimals": decimals.toString(),
      "location": BytesUtils.toHexString(location.serializeVariant()),
      // "address": MoonbeamNetworkControllerUtils.formatAssetIdToERC20(
      //     assetId.toString())
    };
  }

  SubstrateEthereumAddress evmAddress() {
    return MoonbeamNetworkControllerUtils.formatAssetIdToERC20(
        assetId.toString());
  }
}

abstract class BaseMoonbeamNetworkAsset extends BaseSubstrateNetworkAsset {
  BaseMoonbeamNetworkAsset(
      {required super.isSpendable,
      required super.isFeeToken,
      required super.minBalance,
      required super.name,
      required super.symbol,
      required super.decimals,
      required super.excutionPallet});
  BaseMoonbeamNetworkAsset.fromJson(super.json) : super.fromJson();
}

class MoonbeamNetworkAsset extends BaseMoonbeamNetworkAsset {
  final MoonbeamForeignAsset asset;
  @override
  late final XCMVersionedLocation location = asset.location;
  final BigInt? unitsPerSecond;
  MoonbeamNetworkAsset.fromJson(super.json)
      : asset = MoonbeamForeignAsset.fromJson(json.valueAs("asset")),
        unitsPerSecond = json.valueAs("units_per_second"),
        super.fromJson();
  MoonbeamNetworkAsset({
    required this.asset,
    required super.isFeeToken,
    this.unitsPerSecond,
  }) : super(
            decimals: asset.decimals,
            isSpendable: true,
            excutionPallet: SubtrateMetadataPallet.erc20XcmBridge,
            minBalance: BigInt.zero,
            name: asset.name,
            symbol: asset.symbol);
  @override
  String get identifier => asset.assetId;

  @override
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "units_per_second": unitsPerSecond?.toString(),
      ...super.toJson()
    };
  }

  @override
  bool identifierEqual(Object? identifier) {
    return identifier == this.identifier;
  }
}

class MoonbeamNetworkNativeAsset extends BaseMoonbeamNetworkAsset {
  @override
  final XCMVersionedLocation location;
  @override
  final Object? identifier = null;
  MoonbeamNetworkNativeAsset(
      {required this.location,
      super.isFeeToken = true,
      super.isSpendable = true,
      required super.name,
      required super.symbol,
      required super.decimals,
      super.minBalance})
      : super(excutionPallet: SubtrateMetadataPallet.balances);

  MoonbeamNetworkNativeAsset.fromJson(super.json)
      : location = XCMVersionedLocation.fromJson(json.valueAs("location")),
        super.fromJson();

  @override
  SubstrateAssetType get type => SubstrateAssetType.native;

  @override
  Map<String, dynamic> toJson() {
    return {"location": location.toJson(), ...super.toJson()};
  }

  @override
  bool identifierEqual(Object? identifier) {
    return false;
  }
}
