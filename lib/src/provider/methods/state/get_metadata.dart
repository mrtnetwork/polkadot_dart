import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/versioned_metadata.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the runtime metadata.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetMetadata
    extends SubstrateRPCRequest<String, VersionedMetadata> {
  const SubstrateRPCStateGetMetadata({this.atBlockHash});

  final String? atBlockHash;

  /// state_getMetadata
  @override
  String get rpcMethod => SubstrateRPCMethods.getMetadata.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }

  @override
  VersionedMetadata onResonse(String result) {
    final toBytes = BytesUtils.fromHexString(result);
    final versioned = VersionedMetadata.fromBytes(toBytes);

    return versioned;
  }
}
