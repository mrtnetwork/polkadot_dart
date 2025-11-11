import 'package:polkadot_dart/src/api/runtime/runtime/asset_conversion_api.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/dry_run.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/ethereum_rpc_apis.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/xcm_payment_api.dart';

class SubstrateQuickRuntimeApi {
  static const SubstrateRuntimeApiXCMPayment xcmPayment =
      SubstrateRuntimeApiXCMPayment();
  static final SubstrateRuntimeApiDryRun dryRun = SubstrateRuntimeApiDryRun();
  static const SubstrateRuntimeApiAssetConversion assetConversion =
      SubstrateRuntimeApiAssetConversion();
  static const SubstrateRuntimeApiEthereumRuntimeRPCApis
      ethereumRuntimeRPCApis = SubstrateRuntimeApiEthereumRuntimeRPCApis();
}
