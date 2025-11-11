import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum BalancesCallPalletMethod implements SubstrateCallPalletTransferMethod {
  transferAllowDeath("transfer_allow_death", 0),
  transferKeepAlive("transfer_keep_alive", 2),
  transferAll("transfer_all", 3);

  @override
  final String method;
  final int variantIndex;
  @override
  bool get keepAlive => this != transferAllowDeath;
  @override
  bool get isTransferAll => this == transferAll;
  const BalancesCallPalletMethod(this.method, this.variantIndex);

  factory BalancesCallPalletMethod.fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class BalancesCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const BalancesCallPallet({required this.type, required this.pallet});
  @override
  final BalancesCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class BalancesCallPalletTransferAllowDeath extends BalancesCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  const BalancesCallPalletTransferAllowDeath(
      {required this.dest,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.balances})
      : super(type: BalancesCallPalletMethod.transferAllowDeath);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "value": amount
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "value": amount,
      }
    };
  }
}

class BalancesCallPalletTransferKeepAlive extends BalancesCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  const BalancesCallPalletTransferKeepAlive(
      {required this.dest,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.balances})
      : super(type: BalancesCallPalletMethod.transferKeepAlive);
  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "value": amount
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "value": amount,
      }
    };
  }
}

class BalancesCallPalletTransferAll extends BalancesCallPallet {
  final BaseSubstrateAddress dest;
  final bool keepAlive;

  const BalancesCallPalletTransferAll(
      {required this.dest,
      required this.keepAlive,
      super.pallet = SubtrateMetadataPallet.balances})
      : super(type: BalancesCallPalletMethod.transferAll);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
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
      }
    };
  }
}
