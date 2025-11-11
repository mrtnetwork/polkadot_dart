import 'package:blockchain_utils/blockchain_utils.dart';

import 'header.dart';

class SubstrateBlockResponse {
  final SubstrateHeaderResponse header;
  final List<String> extrinsics;
  SubstrateBlockResponse(
      {required this.header, required List<String> extrinsics})
      : extrinsics =
            extrinsics.map((e) => StringUtils.normalizeHex(e)).toImutableList;
  factory SubstrateBlockResponse.fromJson(Map<String, dynamic> json) {
    return SubstrateBlockResponse(
        header: SubstrateHeaderResponse.fromJson(json["header"]),
        extrinsics: (json["extrinsics"] as List).cast());
  }

  int? findExtrinsicIndex(String extrinsic) {
    extrinsic = StringUtils.normalizeHex(extrinsic);
    final index = extrinsics.indexOf(extrinsic);
    if (index.isNegative) return null;
    return index;
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
