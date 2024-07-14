import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/provider/core/core.dart';

/// Returns the supported metadata versions.
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRPCRuntimeAccountBalances
    extends SubstrateRPCRequest<String, List<int>> {
  const SubstrateRPCRuntimeAccountBalances({required this.address});
  final SubstrateAddress address;

  /// sync_state_genSyncSpec
  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return [
      "AssetsApi_account_balances",
      address.toAccountId().toHex(prefix: "0x")
    ];
  }

  @override
  List<int> onResonse(String result) {
    final layput = LayoutConst.compactArray(LayoutConst.u32());
    return List<int>.from(
        layput.deserialize(BytesUtils.fromHexString(result)).value);
  }
}
