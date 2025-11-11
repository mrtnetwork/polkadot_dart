import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/networks/controllers/asset_hub/asset.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/types/types/config.dart';

/// Represents the balance of a specific asset in a Substrate account.
class SubstrateAccountAssetBalance<ASSET extends BaseSubstrateNetworkAsset> {
  /// The associated network asset.
  final ASSET asset;

  /// Free (spendable) balance.
  final BigInt free;

  /// Reserved balance, if any.
  final BigInt? reserved;

  /// Frozen balance, if any.
  final BigInt? frozen;

  /// balance status
  /// exists on networks using asset pallet.
  final PolkadotAssetBalanceStatus? status;

  /// balance reason
  /// exists on networks using asset pallet.
  final BasePolkadotAssetBalanceReason? reason;

  /// Creates a new account asset balance.
  const SubstrateAccountAssetBalance({
    required this.asset,
    required this.free,
    this.reserved,
    this.frozen,
    this.status,
    this.reason,
  });

  /// Converts the balance to JSON.
  Map<String, dynamic> toJson() {
    return {
      "asset": asset.toJson(),
      "free": free,
      "reserved": reserved,
      "status": status?.toJson(),
      "reason": reason?.toJson()
    }.notNullValue;
  }
}

/// Represents all asset balances of a Substrate account for a given network.
class SubstrateNetworkAccountBalances<ASSET extends BaseSubstrateNetworkAsset>
    with BaseSubstrateNetworkAssets<ASSET> {
  /// List of asset balances in this account.
  final List<SubstrateAccountAssetBalance<ASSET>> balances;

  /// The network these balances belong to.
  @override
  final BaseSubstrateNetwork network;

  /// Creates a new network account balances object.
  SubstrateNetworkAccountBalances({
    required List<SubstrateAccountAssetBalance<ASSET>> balances,
    required this.network,
  }) : balances = balances.immutable;

  /// Extracted list of assets from the balances.
  @override
  late final List<ASSET> assets = balances.map((e) => e.asset).toImutableList;

  /// Converts all balances to JSON.
  Map<String, dynamic> toJson() {
    return {
      "network": network.networkName,
      "assets": balances.map((e) => e.toJson()).toList()
    };
  }

  SubstrateAccountAssetBalance? findBalance(ASSET asset) {
    return balances.firstWhereNullable((e) => e.asset == asset);
  }
}
