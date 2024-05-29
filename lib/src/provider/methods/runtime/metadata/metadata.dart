import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

/// Returns the metadata of a runtime.
/// https://polkadot.js.org/docs/substrate/runtime/#metadata
class SubstrateRPCRuntimeMetadataGetMetadata
    extends SubstrateRPCRequest<String, VersionedMetadata?> {
  const SubstrateRPCRuntimeMetadataGetMetadata();

  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return ["Metadata_metadata", "0x", null];
  }

  @override
  VersionedMetadata<SubstrateMetadata>? onResonse(String result) {
    final toBytes = BytesUtils.fromHexString(result);
    final decode = LayoutConst.bytes().deserialize(toBytes).value;
    return VersionedMetadata.fromBytes(decode);
  }
}
