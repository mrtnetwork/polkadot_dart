import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/substrate.dart';

/// Returns the metadata at a given version
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRPCRuntimeMetadataGetMetadataAtVersion
    extends SubstrateRPCRequest<String, VersionedMetadata?> {
  const SubstrateRPCRuntimeMetadataGetMetadataAtVersion(this.version);
  final int version;

  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

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
