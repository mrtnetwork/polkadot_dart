import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/src/provider/core/core.dart';

/// Returns the supported metadata versions.
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeMetadataGetVersions
    extends SubstrateRequest<String, List<int>> {
  const SubstrateRequestRuntimeMetadataGetVersions();

  /// sync_state_genSyncSpec
  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["Metadata_metadata_versions", "0x"];
  }

  @override
  List<int> onResonse(String result) {
    final layput = LayoutConst.compactArray(LayoutConst.u32());
    return List<int>.from(
        layput.deserialize(BytesUtils.fromHexString(result)).value);
  }
}
