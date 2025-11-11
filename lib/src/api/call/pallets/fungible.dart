import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum FungiblesCallPalletMethod implements SubstrateCallPalletTransferMethod {
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
  const FungiblesCallPalletMethod(this.method, this.variantIndex);
  factory FungiblesCallPalletMethod.fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class FungiblesCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const FungiblesCallPallet({required this.type, required this.pallet});
  @override
  final FungiblesCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class FungiblesCallPalletTransfer extends FungiblesCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress target;
  final BigInt amount;

  const FungiblesCallPalletTransfer(
      {required this.id,
      required this.target,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.fungibles})
      : super(type: FungiblesCallPalletMethod.transfer);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": {"parents": id.parents, "interior": id.interior.toJson()},
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

class FungiblesCallPalletTransferKeepAlive extends FungiblesCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress target;
  final BigInt amount;
  const FungiblesCallPalletTransferKeepAlive(
      {required this.id,
      required this.target,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.fungibles})
      : super(type: FungiblesCallPalletMethod.transferKeepAlive);
  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": {"parents": id.parents, "interior": id.interior.toJson()},
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

class FungiblesCallPalletTransferAll extends FungiblesCallPallet {
  final XCMMultiLocation id;
  final BaseSubstrateAddress dest;
  final bool keepAlive;

  const FungiblesCallPalletTransferAll(
      {required this.id,
      required this.dest,
      required this.keepAlive,
      super.pallet = SubtrateMetadataPallet.fungibles})
      : super(type: FungiblesCallPalletMethod.transferAll);

  @override
  FungiblesCallPalletMethod get type => FungiblesCallPalletMethod.transferAll;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": {"parents": id.parents, "interior": id.interior.toJson()},
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
