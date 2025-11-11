import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum ForeignAssetsCallPalletMethod
    implements SubstrateCallPalletTransferMethod {
  transfer("transfer", 8),
  transferKeepAlive("transfer_keep_alive", 9),
  transferAll("transfer_all", 32);

  @override
  bool get keepAlive => this != transfer;

  @override
  bool get isTransferAll => this == transferAll;

  @override
  final String method;
  final int variantIndex;
  const ForeignAssetsCallPalletMethod(this.method, this.variantIndex);
  factory ForeignAssetsCallPalletMethod.fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class ForeignAssetsCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const ForeignAssetsCallPallet({required this.type, required this.pallet});
  @override
  final ForeignAssetsCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class ForeignAssetsCallPalletTransfer extends ForeignAssetsCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress target;
  final BigInt amount;

  const ForeignAssetsCallPalletTransfer(
      {required this.id,
      required this.target,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.foreignAssets})
      : super(type: ForeignAssetsCallPalletMethod.transfer);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    final json = {
      method ?? type.method: {
        "id": id.toJson(),
        "target": extrinsic.extrinsic.encodeAddress(target),
        "amount": amount
      }
    };
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: json);
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "target": target.address,
        "amount": amount,
        "id": id.toJson()
      }
    };
  }
}

class ForeignAssetsCallPalletTransferKeepAlive extends ForeignAssetsCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress target;
  final BigInt amount;
  const ForeignAssetsCallPalletTransferKeepAlive(
      {required this.id,
      required this.target,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.foreignAssets})
      : super(type: ForeignAssetsCallPalletMethod.transferKeepAlive);
  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": {
          "parents": id.parents,
          "interior": {
            id.interior.type.type:
                id.interior.junctions.map((e) => e.toJson()).toList()
          }
        },
        "target": extrinsic.extrinsic.encodeAddress(target),
        "amount": amount
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "target": target.address,
        "amount": amount,
        "id": id.toJson()
      }
    };
  }
}

class ForeignAssetsCallPalletTransferAll extends ForeignAssetsCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress dest;
  final bool keepAlive;

  const ForeignAssetsCallPalletTransferAll(
      {required this.id,
      required this.dest,
      required this.keepAlive,
      super.pallet = SubtrateMetadataPallet.foreignAssets})
      : super(type: ForeignAssetsCallPalletMethod.transferAll);

  @override
  ForeignAssetsCallPalletMethod get type =>
      ForeignAssetsCallPalletMethod.transferAll;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": {
          "parents": id.parents,
          "interior": {
            id.interior.type.type:
                id.interior.junctions.map((e) => e.toJson()).toList()
          }
        },
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "keep_alive": keepAlive
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "keep_alive": keepAlive,
        "id": id.toJson()
      }
    };
  }
}
