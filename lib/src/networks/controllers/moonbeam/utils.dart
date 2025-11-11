import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/constants.dart';

class MoonbeamNetworkControllerUtils {
  static SubstrateEthereumAddress formatAssetIdToERC20(String id) {
    if (id.startsWith('0x')) {
      return SubstrateEthereumAddress(id);
    }
    final inBig = BigInt.parse(id);
    final bytes = BigintUtils.toBytes(inBig, length: 16);
    return SubstrateEthereumAddress.fromBytes(
        [...MoonbeamNetworkControllerConst.moonbeamAssetIdPrefix, ...bytes]);
  }
}
