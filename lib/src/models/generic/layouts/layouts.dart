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
      LayoutConst.compactBigintU64(property: "ref_time"),
      LayoutConst.compactBigintU64(property: "proof_size"),
    ], property: property);
  }

  static StructLayout frameSupportDispatchPerDispatchClass({String? property}) {
    return LayoutConst.struct([
      spWeightsWeightV2Weight(property: "normal"),
      spWeightsWeightV2Weight(property: "operational"),
      spWeightsWeightV2Weight(property: "mandatory"),
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

  static StructLayout multisigTimepoint({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u32(property: "height"),
      LayoutConst.u32(property: "index"),
    ], property: property);
  }

  static StructLayout account({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u32(property: "nonce"),
      LayoutConst.u32(property: "consumers"),
      LayoutConst.u32(property: "providers"),
      LayoutConst.i32(property: "sufficients"),
      accountData(property: "data")
    ], property: property);
  }

  static StructLayout accountData({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u128(property: "free"),
      LayoutConst.u128(property: "reserved"),
      LayoutConst.u128(property: "frozen"),
      LayoutConst.u128(property: "flags"),
    ], property: property);
  }

  static Layout<List> runtimeVersionApi({String? property}) {
    return LayoutConst.tuple([
      LayoutConst.fixedBlobN(8),
      LayoutConst.u32(),
    ], property: property);
  }

  static Layout<List> runtimeVersion({String? property}) {
    return LayoutConst.tuple([
      LayoutConst.compactString(property: "spec_name"),
      LayoutConst.compactString(property: "impl_name"),
      LayoutConst.u32(property: "authoring_version"),
      LayoutConst.u32(property: "spec_version"),
      LayoutConst.u32(property: "impl_version"),
      LayoutConst.compactVec(runtimeVersionApi(), property: "abis"),
      LayoutConst.u32(property: "transaction_version"),
      LayoutConst.u8(property: "state_version"),
    ], property: property);
  }
}
