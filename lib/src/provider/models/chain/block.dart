import 'package:blockchain_utils/blockchain_utils.dart';

import 'header.dart';

class SubstrateBlockResponse {
  final SubstrateHeaderResponse header;
  final List<String> extrinsics;
  SubstrateBlockResponse(
      {required this.header, required List<String> extrinsics})
      : extrinsics = extrinsics.immutable;
  factory SubstrateBlockResponse.fromJson(Map<String, dynamic> json) {
    return SubstrateBlockResponse(
        header: SubstrateHeaderResponse.fromJson(json["header"]),
        extrinsics: (json["extrinsics"] as List).cast());
  }
}

class SubstrateGetBlockResponse {
  final SubstrateBlockResponse block;
  final List<List<String>>? justifications;
  const SubstrateGetBlockResponse({required this.block, this.justifications});
  factory SubstrateGetBlockResponse.fromJson(Map<String, dynamic> json) {
    return SubstrateGetBlockResponse(
        block: SubstrateBlockResponse.fromJson(json["block"]),
        justifications: (json["justifications"] as List?)
            ?.map((e) => (e as List).cast<String>().immutable)
            .cast<List<String>>()
            .toList()
            .immutable);
  }
}
