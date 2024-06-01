import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';

/// Extension to help with transaction encoding based on metadata
extension TransactionHelper on MetadataApi {
  /// Encode transfer with allow death
  List<int> transferAllowDeath(BigInt value, SubstrateAddress destination) {
    final amount = MetadataCastingUtils.castingIntegerValue(
        value: value, type: PrimitiveTypes.u128);
    try {
      final template = {
        "transfer_allow_death": {
          "dest": {"Id": destination.toBytes()},
          "value": amount
        }
      };
      return encodeCall(
          palletNameOrIndex: "balances", value: template, fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `transferAllowDeath`.",
          details: {"error": e.toString()});
    }
  }

  /// Encode transfer with keep alive
  List<int> transferKeepAlive(BigInt value, SubstrateAddress destination) {
    final amount = MetadataCastingUtils.castingIntegerValue(
        value: value, type: PrimitiveTypes.u128);
    try {
      final template = {
        "transfer_keep_alive": {
          "dest": {"Id": destination.toBytes()},
          "value": amount
        }
      };
      return encodeCall(
          palletNameOrIndex: "balances", value: template, fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `transferKeepAlive`.",
          details: {"error": e.toString()});
    }
  }

  /// Encode staking bond
  List<int> stakingBond(BigInt value, StakingPayeeOption payee) {
    final amount = MetadataCastingUtils.castingIntegerValue(
        value: value, type: PrimitiveTypes.u128);
    try {
      final boundTemolate = {
        "bond": {"value": amount, "payee": payee.scaleJsonSerialize()}
      };
      return encodeCall(
          palletNameOrIndex: "staking",
          value: boundTemolate,
          fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `stakingBond`.",
          details: {"error": e.toString()});
    }
  }

  /// Encode staking unbond
  List<int> stakingUnbond(BigInt value) {
    final amount = MetadataCastingUtils.castingIntegerValue(
        value: value, type: PrimitiveTypes.u128);
    try {
      final boundTemolate = {"unbond": amount};
      return encodeCall(
          palletNameOrIndex: "staking",
          value: boundTemolate,
          fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `stakingBond`.",
          details: {"error": e.toString()});
    }
  }

  /// Encode approve as multi
  List<int> approveAsMulti(
      {required int thresHold,
      required List<SubstrateAddress> otherSignatories,
      MultisigTimepoint? maybeTimepoint,
      required List<int> callHash,
      required SpWeightsWeightV2Weight maxWeight}) {
    try {
      final template = {
        "approve_as_multi": {
          "threshold": thresHold,
          "other_signatories":
              otherSignatories.map((e) => e.toBytes()).toList(),
          "maybe_timepoint": maybeTimepoint?.scaleJsonSerialize(),
          "call_hash": callHash,
          "max_weight": maxWeight.scaleJsonSerialize()
        }
      };
      return encodeCall(
          palletNameOrIndex: "multisig", value: template, fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `approveAsMulti`.",
          details: {"error": e.toString()});
    }
  }

  /// Encode as multi
  List<int> encodeAsMulti(
      {required int thresHold,
      required List<SubstrateAddress> otherSignatories,
      MultisigTimepoint? maybeTimepoint,
      required Map<String, dynamic> call,
      required SpWeightsWeightV2Weight maxWeight}) {
    try {
      final template = {
        "as_multi": {
          "threshold": thresHold,
          "other_signatories":
              otherSignatories.map((e) => e.toBytes()).toList(),
          "maybe_timepoint": maybeTimepoint?.scaleJsonSerialize(),
          "call": call,
          "max_weight": maxWeight.scaleJsonSerialize()
        }
      };
      return encodeCall(
          palletNameOrIndex: "multisig", value: template, fromTemplate: false);
    } catch (e) {
      throw MetadataException(
          "Method not working in current metadata. please use `encodeCall` method instead `approveAsMulti`.",
          details: {"error": e.toString()});
    }
  }
}
