import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/networks/controllers/moonbeam/constants.dart';

class MoonbeamNetworkControllerUtils {
  static SubstrateEthereumAddress formatAssetIdToERC20(String id) {
    if (id.startsWith('0x')) {
      return SubstrateEthereumAddress(id);
    }
    final inBig = BigintUtils.parse(id, allowHex: false);
    final bytes = inBig.toBeBytes(length: 16);
    return SubstrateEthereumAddress.fromBytes([
      ...MoonbeamNetworkControllerConst.moonbeamAssetIdPrefix,
      ...bytes,
    ]);
  }
}
