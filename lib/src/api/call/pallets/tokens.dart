import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum TokensCallPalletMethod implements SubstrateCallPalletTransferMethod {
  transfer("transfer", 0),
  transferAll("transfer_all", 1),
  transferKeepAlive("transfer_keep_alive", 2);

  @override
  bool get isTransferAll => this == transferAll;
  factory TokensCallPalletMethod.fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
  @override
  bool get keepAlive => this != transfer;

  @override
  final String method;
  final int variantIndex;
  const TokensCallPalletMethod(this.method, this.variantIndex);
}

abstract class TokensCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const TokensCallPallet({required this.type, required this.pallet});
  @override
  final TokensCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class TokensCallPalletTransfer extends TokensCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  final Object currencyId;

  const TokensCallPalletTransfer(
      {required this.dest,
      required this.currencyId,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.tokens})
      : super(type: TokensCallPalletMethod.transfer);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "currency_id": currencyId,
        "amount": amount,
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "amount": amount,
        "currency_id": currencyId
      }
    };
  }
}

class TokensCallPalletTransferKeepAlive extends TokensCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  final Object currencyId;

  TokensCallPalletTransferKeepAlive(
      {required this.dest,
      required this.currencyId,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.tokens})
      : super(type: TokensCallPalletMethod.transferKeepAlive);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "currency_id": currencyId,
        "amount": amount,
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "amount": amount,
        "currency_id": currencyId
      }
    };
  }
}

class TokensCallPalletTransferAll extends TokensCallPallet {
  final BaseSubstrateAddress dest;
  final bool keepAlive;
  final Object currencyId;

  const TokensCallPalletTransferAll(
      {required this.dest,
      required this.currencyId,
      required this.keepAlive,
      super.pallet = SubtrateMetadataPallet.tokens})
      : super(type: TokensCallPalletMethod.transferAll);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "currency_id": currencyId,
        "keep_alive": keepAlive,
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {
        "dest": dest.address,
        "keep_alive": keepAlive,
        "currency_id": currencyId
      }
    };
  }
}
