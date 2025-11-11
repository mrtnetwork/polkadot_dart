import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum AssetManagerCallPalletMethod implements SubstrateCallPalletTransferMethod {
  transfer("transfer", 0),
  transfernativeCurrency("transfer_native_currency", 1);

  @override
  final String method;
  final int variantIndex;
  const AssetManagerCallPalletMethod(this.method, this.variantIndex);
  @override
  bool get isTransferAll => false;
  @override
  bool get keepAlive => false;
}

abstract class AssetManagerCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const AssetManagerCallPallet({required this.type, required this.pallet});
  @override
  final AssetManagerCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class AssetManagerCallPalletTransfer extends AssetManagerCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  final Object currencyId;

  const AssetManagerCallPalletTransfer(
      {required this.dest,
      required this.currencyId,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.assetManager})
      : super(type: AssetManagerCallPalletMethod.transfer);

  @override
  AssetManagerCallPalletMethod get type =>
      AssetManagerCallPalletMethod.transfer;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "amount": amount,
        "currency_id": currencyId
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

class AssetManagerCallPalletTransferNativeCurrency
    extends AssetManagerCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;

  const AssetManagerCallPalletTransferNativeCurrency(
      {required this.dest,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.assetManager})
      : super(type: AssetManagerCallPalletMethod.transfernativeCurrency);

  @override
  AssetManagerCallPalletMethod get type =>
      AssetManagerCallPalletMethod.transfernativeCurrency;

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      type.method: {
        "dest": extrinsic.extrinsic.encodeAddress(dest),
        "amount": amount,
      }
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {
      method ?? type.method: {"dest": dest.address, "amount": amount}
    };
  }
}
