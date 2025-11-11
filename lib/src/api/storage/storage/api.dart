import 'package:polkadot_dart/src/api/storage/storage/asset_manager.dart';
import 'package:polkadot_dart/src/api/storage/storage/asset_registry.dart';
import 'package:polkadot_dart/src/api/storage/storage/assets.dart';
import 'package:polkadot_dart/src/api/storage/storage/assets_registry.dart';
import 'package:polkadot_dart/src/api/storage/storage/evm_foreign_assets.dart';
import 'package:polkadot_dart/src/api/storage/storage/foreign_assets.dart';
import 'package:polkadot_dart/src/api/storage/storage/fungible.dart';
import 'package:polkadot_dart/src/api/storage/storage/fungibless.dart';
import 'package:polkadot_dart/src/api/storage/storage/multisig.dart';
import 'package:polkadot_dart/src/api/storage/storage/orml_asset_registry.dart';
import 'package:polkadot_dart/src/api/storage/storage/orml_tokens.dart';
import 'package:polkadot_dart/src/api/storage/storage/polkadot_xcm.dart';
import 'package:polkadot_dart/src/api/storage/storage/pool_assets.dart';
import 'package:polkadot_dart/src/api/storage/storage/system.dart';
import 'package:polkadot_dart/src/api/storage/storage/tokens.dart';
import 'package:polkadot_dart/src/api/storage/storage/xc_assets_config.dart'
    show SubstrateStorageXcAssetConfig;
import 'package:polkadot_dart/src/api/storage/storage/xcm_info.dart';
import 'package:polkadot_dart/src/api/storage/storage/xcm_pallet.dart';
import 'package:polkadot_dart/src/api/storage/storage/xcm_transactor.dart';
import 'package:polkadot_dart/src/api/storage/storage/xcm_weight_trader.dart';

class SubstrateQuickStorageApi {
  static const SubstrateStorageSystem system = SubstrateStorageSystem();
  static const SubstrateStorageMultisig multisig = SubstrateStorageMultisig();
  static const SubstrateStoragePolkadotXCM polkadotXCM =
      SubstrateStoragePolkadotXCM();
  static const SubstrateStorageXCMPallet xcmPallet =
      SubstrateStorageXCMPallet();
  static const SubstrateStorageAssets assets = SubstrateStorageAssets();
  static const SubstrateStoragePoolAssets poolAssets =
      SubstrateStoragePoolAssets();
  static const SubstrateStorageForeignAssets foreignAssets =
      SubstrateStorageForeignAssets();
  static const SubstrateStorageXcAssetConfig xcAssetConfig =
      SubstrateStorageXcAssetConfig();
  static const SubstrateStorageAssetRegistry assetRegistry =
      SubstrateStorageAssetRegistry();
  static const SubstrateStorageAssetManager assetManager =
      SubstrateStorageAssetManager();
  static const SubstrateStorageAssetsRegistry assetsRegistry =
      SubstrateStorageAssetsRegistry();
  static const SubstrateStorageXcmInfo xcmInfo = SubstrateStorageXcmInfo();
  static const SubstrateStorageTokens tokens = SubstrateStorageTokens();
  static const SubstrateStorageOrmlAssetRegistry ormlAssetRegistry =
      SubstrateStorageOrmlAssetRegistry();
  static const SubstrateStorageOrmlTokens ormlTokens =
      SubstrateStorageOrmlTokens();
  static const SubstrateStorageFungibles fungibles =
      SubstrateStorageFungibles();
  static const SubstrateStorageFungible fungible = SubstrateStorageFungible();

  static const SubstrateStorageEvmForeignAssets evmForeignAssets =
      SubstrateStorageEvmForeignAssets();
  static const SubstrateStorageXCMTransactor xcmTransactor =
      SubstrateStorageXCMTransactor();
  static const SubstrateStorageXCMWeightTrader xcmWeightTrader =
      SubstrateStorageXCMWeightTrader();
}
