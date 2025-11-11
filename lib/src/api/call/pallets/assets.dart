import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum AssetsCallPalletMethod implements SubstrateCallPalletTransferMethod {
  transfer("transfer", 8),
  transferKeepAlive("transfer_keep_alive", 9),
  transferAll("transfer_all", 32);

  @override
  bool get keepAlive => this != transfer;
  @override
  final String method;
  final int variantIndex;
  const AssetsCallPalletMethod(this.method, this.variantIndex);
  factory AssetsCallPalletMethod.fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }

  @override
  bool get isTransferAll => this == transferAll;
}

abstract class AssetsCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const AssetsCallPallet({required this.pallet, required this.type});
  @override
  final AssetsCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class AssetsCallPalletTransfer extends AssetsCallPallet {
  final BigInt id;
  final BaseSubstrateAddress target;
  final BigInt amount;

  const AssetsCallPalletTransfer(
      {required this.id,
      required this.target,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.assets})
      : super(type: AssetsCallPalletMethod.transfer);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": id,
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
        "id": id
      }
    };
  }
}

class AssetsCallPalletTransferKeepAlive extends AssetsCallPalletTransfer {
  const AssetsCallPalletTransferKeepAlive(
      {required super.id, required super.target, required super.amount});

  @override
  AssetsCallPalletMethod get type => AssetsCallPalletMethod.transferKeepAlive;
}

class AssetsCallPalletTransferAll extends AssetsCallPallet {
  final BigInt id;
  final BaseSubstrateAddress dest;
  final bool keepAlive;

  const AssetsCallPalletTransferAll(
      {required this.id,
      required this.dest,
      required this.keepAlive,
      super.pallet = SubtrateMetadataPallet.assets})
      : super(type: AssetsCallPalletMethod.transferAll);

  @override
  AssetsCallPalletMethod get type => AssetsCallPalletMethod.transferAll;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "id": id,
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
        "id": id
      }
    };
  }
}
