import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRequestRuntimeMetadataGetMetadataAtVersion
    extends SubstrateRequest<String, VersionedMetadata?> {
  const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(this.version);
  final int version;

  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    final val = BytesUtils.toHexString(LayoutConst.u32().serialize(version),
        prefix: "0x");

    return ["Metadata_metadata_at_version", val, null];
  }

  @override
  VersionedMetadata<SubstrateMetadata>? onResonse(String result) {
    final toBytes = BytesUtils.fromHexString(result);
    final decode =
        LayoutConst.optional(LayoutConst.bytes()).deserialize(toBytes).value;
    if (decode == null) return null;
    return VersionedMetadata.fromBytes(decode);
  }
}
