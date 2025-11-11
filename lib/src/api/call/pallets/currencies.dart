import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum CurrenciesCallPalletMethod implements SubstrateCallPalletTransferMethod {
  transfer("transfer", 0),
  transfernativeCurrency("transfer_native_currency", 1);

  @override
  final String method;
  final int variantIndex;
  const CurrenciesCallPalletMethod(this.method, this.variantIndex);
  @override
  bool get isTransferAll => false;
  @override
  bool get keepAlive => false;
}

abstract class CurrenciesCallPallet
    with SubstrateCallPallet
    implements SubstrateLocalTransferCallPallet {
  const CurrenciesCallPallet({required this.type, required this.pallet});
  @override
  final CurrenciesCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class CurrenciesCallPalletTransfer extends CurrenciesCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;
  final Object currencyId;

  const CurrenciesCallPalletTransfer(
      {required this.dest,
      required this.currencyId,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.currencies})
      : super(type: CurrenciesCallPalletMethod.transfer);

  @override
  CurrenciesCallPalletMethod get type => CurrenciesCallPalletMethod.transfer;

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

class CurrenciesCallPalletTransferNativeCurrency extends CurrenciesCallPallet {
  final BaseSubstrateAddress dest;
  final BigInt amount;

  const CurrenciesCallPalletTransferNativeCurrency(
      {required this.dest,
      required this.amount,
      super.pallet = SubtrateMetadataPallet.currencies})
      : super(type: CurrenciesCallPalletMethod.transfernativeCurrency);

  @override
  CurrenciesCallPalletMethod get type =>
      CurrenciesCallPalletMethod.transfernativeCurrency;

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
