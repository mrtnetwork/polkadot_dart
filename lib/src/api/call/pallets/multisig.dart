import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/modesl.dart';

enum MultisigCallPalletMethod implements SubstrateCallPalletMethod {
  asMultiThreshold1("as_multi_threshold_1", 0),
  asMulti("as_multi", 1),
  approveAsMulti("approve_as_multi", 2),
  cancelAsMulti("cancel_as_multi", 3),
  pokeDeposit("poke_deposit", 4);

  @override
  final String method;
  final int variantIndex;
  const MultisigCallPalletMethod(this.method, this.variantIndex);
  static MultisigCallPalletMethod fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static MultisigCallPalletMethod fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class MultisigCallPallet with SubstrateCallPallet {
  const MultisigCallPallet({required this.type, required this.pallet});
  final MultisigCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class MultisigCallPalletAsMulti extends MultisigCallPallet {
  final int threshold;
  final List<BaseSubstrateAddress> otherSignatories;
  final MultisigExtrinsicInfo? maybeTimepoint;
  final List<int> call;
  final SubstrateWeightV2 maxWeight;

  MultisigCallPalletAsMulti(
      {required int threshold,
      required List<BaseSubstrateAddress> otherSignatories,
      this.maybeTimepoint,
      required List<int> call,
      required this.maxWeight,
      super.pallet = SubtrateMetadataPallet.multisig})
      : otherSignatories = otherSignatories.immutable,
        call = call.asImmutableBytes,
        threshold = threshold.asUint16,
        super(type: MultisigCallPalletMethod.asMulti);

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
        "threshold": threshold,
        "other_signatories": otherSignatories.map((e) => e.toBytes()).toList(),
        "maybe_timepoint":
            MetadataUtils.toOptionalJson(maybeTimepoint?.toJson()),
        "call": LookupRawParam(bytes: call),
        "max_weight": maxWeight.toJson()
      }
    };
  }
}

class MultisigCallPalletApproveAsMulti extends MultisigCallPallet {
  final int threshold;
  final List<BaseSubstrateAddress> otherSignatories;
  final MultisigExtrinsicInfo? maybeTimepoint;
  final List<int> callHash;
  final SubstrateWeightV2 maxWeight;
  factory MultisigCallPalletApproveAsMulti.fromCall(
      {required int threshold,
      required List<BaseSubstrateAddress> otherSignatories,
      MultisigExtrinsicInfo? maybeTimepoint,
      SubtrateMetadataPallet pallet = SubtrateMetadataPallet.multisig,
      required List<int> call,
      required SubstrateWeightV2 maxWeight}) {
    return MultisigCallPalletApproveAsMulti(
        threshold: threshold,
        otherSignatories: otherSignatories,
        callHash: QuickCrypto.blake2b256Hash(call),
        maxWeight: maxWeight,
        maybeTimepoint: maybeTimepoint,
        pallet: pallet);
  }

  MultisigCallPalletApproveAsMulti(
      {required int threshold,
      required List<BaseSubstrateAddress> otherSignatories,
      this.maybeTimepoint,
      required List<int> callHash,
      required this.maxWeight,
      super.pallet = SubtrateMetadataPallet.multisig})
      : otherSignatories = otherSignatories.immutable,
        callHash = callHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        threshold = threshold.asUint16,
        super(type: MultisigCallPalletMethod.approveAsMulti);

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
        "threshold": threshold,
        "other_signatories": otherSignatories.map((e) => e.toBytes()).toList(),
        "maybe_timepoint":
            MetadataUtils.toOptionalJson(maybeTimepoint?.toJson()),
        "call_hash": callHash,
        "max_weight": maxWeight.toJson()
      }
    };
  }
}

class MultisigCallPalletCancelAsMulti extends MultisigCallPallet {
  final int threshold;
  final List<BaseSubstrateAddress> otherSignatories;
  final MultisigExtrinsicInfo timepoint;
  final List<int> callHash;

  MultisigCallPalletCancelAsMulti({
    required int threshold,
    required List<BaseSubstrateAddress> otherSignatories,
    required this.timepoint,
    required List<int> callHash,
    super.pallet = SubtrateMetadataPallet.multisig,
  })  : otherSignatories = otherSignatories.immutable,
        callHash = callHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        threshold = threshold.asUint16,
        super(type: MultisigCallPalletMethod.cancelAsMulti);

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
        "threshold": threshold,
        "other_signatories": otherSignatories.map((e) => e.toBytes()).toList(),
        "timepoint": timepoint.toJson(),
        "call_hash": callHash,
      }
    };
  }
}

class MultisigCallPalletAsMultiThreshold1 extends MultisigCallPallet {
  final List<BaseSubstrateAddress> otherSignatories;
  final List<int> call;

  MultisigCallPalletAsMultiThreshold1({
    required List<BaseSubstrateAddress> otherSignatories,
    required List<int> call,
    super.pallet = SubtrateMetadataPallet.multisig,
  })  : otherSignatories = otherSignatories.immutable,
        call = call.asImmutableBytes,
        super(type: MultisigCallPalletMethod.asMultiThreshold1);

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
        "other_signatories": otherSignatories.map((e) => e.toBytes()).toList(),
        "call": LookupRawParam(bytes: call),
      }
    };
  }
}

class MultisigCallPalletPokeDeposit extends MultisigCallPallet {
  final int threshold;
  final List<BaseSubstrateAddress> otherSignatories;
  final List<int> callHash;

  MultisigCallPalletPokeDeposit({
    required int threshold,
    required List<BaseSubstrateAddress> otherSignatories,
    required List<int> callHash,
    super.pallet = SubtrateMetadataPallet.multisig,
  })  : otherSignatories = otherSignatories.immutable,
        callHash = callHash
            .exc(SubstrateConstant.blockHashBytesLength)
            .asImmutableBytes,
        threshold = threshold.asUint16,
        super(type: MultisigCallPalletMethod.pokeDeposit);

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
        "threshold": threshold,
        "other_signatories": otherSignatories.map((e) => e.toBytes()).toList(),
        "call_hash": callHash,
      }
    };
  }
}
