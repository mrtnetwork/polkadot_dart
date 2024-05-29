import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';

class GenericLayouts {
  static Layout<Map<String, dynamic>> era({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.none(property: "Immortal"),
      ...List.generate(
          255, (index) => LayoutConst.u8(property: "Mortal${index + 1}"))
    ], property: property);
  }

  static StructLayout spWeightsWeightV2Weight({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactBigintU64(property: "refTime"),
      LayoutConst.compactBigintU64(property: "proofSize"),
    ], property: property);
  }

  static Layout<Map<String, dynamic>> signature({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.fixedBlobN(SubstrateConstant.signatureLength,
          property: GenericConstants.multiSignatureEd25519IndexKey),
      LayoutConst.fixedBlobN(SubstrateConstant.signatureLength,
          property: GenericConstants.multiSignatureSr25519IndexKey),
      LayoutConst.fixedBlobN(SubstrateConstant.ecdsaSignatureLength,
          property: GenericConstants.multiSignatureEcdsaIndexKey),
    ], property: property);
  }

  static Layout<int> accountIndex({String? property}) {
    return LayoutConst.compactIntU32(property: property);
  }

  static Layout<List<int>> accountRaw({String? property}) {
    return LayoutConst.bytes(property: property);
  }

  static Layout<Map<String, dynamic>> multiAddress({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.fixedBlob32(property: GenericConstants.idIndexKey),
      accountIndex(property: GenericConstants.indexIndexKey),
      accountRaw(property: GenericConstants.rawIndexKey),
      LayoutConst.fixedBlob32(property: GenericConstants.address32IndexKey),
    ], property: property);
  }
}
