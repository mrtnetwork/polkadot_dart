import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum XTransferCallPalletMethod implements SubstrateCallPalletXCMTransferMethod {
  transfer("transfer", 0),
  transferGeneric("transfer_generic", 1);

  @override
  final String method;
  final int variantIndex;
  const XTransferCallPalletMethod(this.method, this.variantIndex);
  static XTransferCallPalletMethod fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XTransferCallPalletMethod fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class XTransferCallPallet
    with SubstrateCallPallet
    implements SubstrateXCMCallPallet {
  const XTransferCallPallet({required this.type, required this.pallet});
  @override
  final XTransferCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class XTransferCallPalletTransfer extends XTransferCallPallet {
  final XCMV3MultiAsset asset;
  final XCMV3MultiLocation dest;
  final SubstrateWeightV2? destWeight;
  @override
  XCMMultiLocation get destination => dest;

  const XTransferCallPalletTransfer(
      {required this.asset,
      required this.dest,
      required this.destWeight,
      super.pallet = SubtrateMetadataPallet.xTransfer})
      : super(type: XTransferCallPalletMethod.transfer);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api.encodeCall(
        palletNameOrIndex: pallet ?? this.pallet.name,
        value: toJson(method: method));
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "asset": asset.toJson(),
        "dest": dest.toJson(),
        "dest_weight": MetadataUtils.toOptionalJson(destWeight?.toJson())
      }
    };
  }
}

class XTransferCallPalletTransferGeneric extends XTransferCallPallet {
  final List<int> data;
  final XCMV3MultiLocation dest;
  final SubstrateWeightV2? destWeight;
  @override
  XCMMultiLocation get destination => dest;

  XTransferCallPalletTransferGeneric(
      {required List<int> data,
      required this.dest,
      required this.destWeight,
      super.pallet = SubtrateMetadataPallet.xTransfer})
      : data = data.asImmutableBytes,
        super(type: XTransferCallPalletMethod.transferGeneric);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api.encodeCall(
        palletNameOrIndex: pallet ?? this.pallet.name,
        value: toJson(method: method));
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "data": data,
        "dest": dest.toJson(),
        "dest_weight": MetadataUtils.toOptionalJson(destWeight?.toJson())
      }
    };
  }
}
