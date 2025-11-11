import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum XTokenCallPalletMethod implements SubstrateCallPalletXCMTransferMethod {
  transfer("transfer", 0),
  transferMultiasset("transfer_multiasset", 1),
  transferWithFee("transfer_with_fee", 2),
  transferMultiassetWithFee("transfer_multiasset_with_fee", 3),
  transferMulticurrencies("transfer_multicurrencies", 4),
  transferMultiassets("transfer_multiassets", 5);

  @override
  final String method;
  final int variantIndex;
  const XTokenCallPalletMethod(this.method, this.variantIndex);
  static XTokenCallPalletMethod findMethod(
      {required int assetsLength,
      required bool hasIdentifier,
      required bool hasFee}) {
    bool multiAssetsTransfer = assetsLength > 1;
    if (!hasIdentifier) {
      if (multiAssetsTransfer) {
        return XTokenCallPalletMethod.transferMultiassets;
      }
      if (hasFee) return XTokenCallPalletMethod.transferMultiassetWithFee;
      return XTokenCallPalletMethod.transferMultiasset;
    }
    if (multiAssetsTransfer) {
      return XTokenCallPalletMethod.transferMulticurrencies;
    }
    if (hasFee) return XTokenCallPalletMethod.transferWithFee;
    return XTokenCallPalletMethod.transfer;
  }

  static XTokenCallPalletMethod fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XTokenCallPalletMethod fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class XTokenCallPallet
    with SubstrateCallPallet
    implements SubstrateXCMCallPallet {
  const XTokenCallPallet({required this.type, required this.pallet});
  @override
  final XTokenCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class XTokenCallPalletTransfer extends XTokenCallPallet {
  final Object currencyId;
  final BigInt amount;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  @override
  XCMMultiLocation get destination => dest.location;

  const XTokenCallPalletTransfer(
      {required this.currencyId,
      required this.amount,
      required this.dest,
      required this.destWeightLimit,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transfer);

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
        "currency_id": currencyId,
        "amount": amount,
        "dest": dest.toJson(),
        "dest_weight_limit": destWeightLimit.toJson()
      }
    };
  }
}

class XTokenCallPalletTransferMultiAsset extends XTokenCallPallet {
  final XCMVersionedAsset asset;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  @override
  XCMMultiLocation get destination => dest.location;

  const XTokenCallPalletTransferMultiAsset(
      {required this.asset,
      required this.dest,
      required this.destWeightLimit,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transferMultiasset);

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
        "dest_weight_limit": destWeightLimit.toJson()
      }
    };
  }
}

class XTokenCallPalletTransferWithFee extends XTokenCallPallet {
  final Object currencyId;
  final BigInt amount;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  final BigInt fee;
  @override
  XCMMultiLocation get destination => dest.location;

  const XTokenCallPalletTransferWithFee(
      {required this.currencyId,
      required this.amount,
      required this.dest,
      required this.destWeightLimit,
      required this.fee,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transferWithFee);

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
        "currency_id": currencyId,
        "amount": amount,
        "dest": dest.toJson(),
        "dest_weight_limit": destWeightLimit.toJson(),
        "fee": fee
      }
    };
  }
}

class XTokenCallPalletTransferMultiAssetWithFee extends XTokenCallPallet {
  final XCMVersionedAsset asset;
  final XCMVersionedAsset fee;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  @override
  XCMMultiLocation get destination => dest.location;
  const XTokenCallPalletTransferMultiAssetWithFee(
      {required this.asset,
      required this.dest,
      required this.destWeightLimit,
      required this.fee,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transferMultiassetWithFee);

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
        "dest_weight_limit": destWeightLimit.toJson(),
        "fee": fee.toJson()
      }
    };
  }
}

class XTokenTransferTokenWithAmount {
  final BigInt amount;
  final Object currencyId;
  const XTokenTransferTokenWithAmount(
      {required this.amount, required this.currencyId});
}

class XTokenCallPalletTransferMulticurrencies extends XTokenCallPallet {
  final List<XTokenTransferTokenWithAmount> tokens;
  final int feeItem;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  @override
  XCMMultiLocation get destination => dest.location;
  const XTokenCallPalletTransferMulticurrencies(
      {required this.tokens,
      required this.dest,
      required this.destWeightLimit,
      required this.feeItem,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transferMulticurrencies);

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
        "currencies": tokens.map((e) => [e.currencyId, e.amount]).toList(),
        "dest": dest.toJson(),
        "dest_weight_limit": destWeightLimit.toJson(),
        "fee_item": feeItem
      }
    };
  }
}

class XTokenCallPalletTransferMultiAssets extends XTokenCallPallet {
  final XCMVersionedAssets assets;
  final int feeItem;
  final XCMVersionedLocation dest;
  final XCMV3WeightLimit destWeightLimit;
  @override
  XCMMultiLocation get destination => dest.location;
  const XTokenCallPalletTransferMultiAssets(
      {required this.assets,
      required this.dest,
      required this.destWeightLimit,
      required this.feeItem,
      super.pallet = SubtrateMetadataPallet.xTokens})
      : super(type: XTokenCallPalletMethod.transferMultiassets);

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
        "assets": assets.toJson(),
        "dest": dest.toJson(),
        "fee_item": feeItem,
        "dest_weight_limit": destWeightLimit.toJson()
      }
    };
  }
}
