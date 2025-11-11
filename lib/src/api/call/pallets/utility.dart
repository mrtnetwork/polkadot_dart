import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

enum UtilityCallPalletMethod implements SubstrateCallPalletMethod {
  batch("batch", 0),
  batchAll("batch_all", 2);

  @override
  final String method;
  final int variantIndex;
  const UtilityCallPalletMethod(this.method, this.variantIndex);
  static UtilityCallPalletMethod fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static UtilityCallPalletMethod fromMethod(String? method) {
    return values.firstWhere((e) => e.method == method,
        orElse: () => throw ItemNotFoundException(value: method));
  }
}

abstract class UtilityCallPallet with SubstrateCallPallet {
  const UtilityCallPallet({required this.type, required this.pallet});
  final UtilityCallPalletMethod type;
  @override
  final SubtrateMetadataPallet pallet;
}

class UtilityCallPalletBatch extends UtilityCallPallet {
  final List<SubstrateCallPallet> calls;

  UtilityCallPalletBatch(
      {required List<SubstrateCallPallet> calls,
      super.pallet = SubtrateMetadataPallet.utility})
      : calls = calls.immutable,
        super(type: UtilityCallPalletMethod.batch);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: calls
          .map((e) => LookupRawParam(bytes: e.encodeCall(extrinsic: extrinsic)))
          .toList()
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {method ?? type.method: calls.map((e) => e.toJson()).toList()};
  }
}

class UtilityCallPalletBatchAll extends UtilityCallPallet {
  final List<SubstrateCallPallet> calls;

  UtilityCallPalletBatchAll(
      {required List<SubstrateCallPallet> calls,
      super.pallet = SubtrateMetadataPallet.utility})
      : calls = calls.immutable,
        super(type: UtilityCallPalletMethod.batchAll);

  @override
  List<int> encodeCall(
      {required MetadataWithExtrinsic extrinsic,
      String? pallet,
      String? method}) {
    return extrinsic.api
        .encodeCall(palletNameOrIndex: pallet ?? this.pallet.name, value: {
      method ?? type.method: calls
          .map((e) => LookupRawParam(bytes: e.encodeCall(extrinsic: extrinsic)))
          .toList()
    });
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {method ?? type.method: calls.map((e) => e.toJson()).toList()};
  }
}
