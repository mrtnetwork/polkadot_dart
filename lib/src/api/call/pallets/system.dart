import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/types/types.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';

enum SystemCallPalletMethod implements SubstrateCallPalletMethod {
  remark("remark", 0);

  @override
  final String method;
  final int variantIndex;
  const SystemCallPalletMethod(this.method, this.variantIndex);
  static SystemCallPalletMethod fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SystemCallPalletMethod name "$name".',
              ),
    );
  }

  static SystemCallPalletMethod fromMethod(String? method) {
    return values.firstWhere(
      (e) => e.method == method,
      orElse:
          () =>
              throw BuError(
                DefaultErrorType.invalidArgument,
                'Unknown SystemCallPalletMethod method "$method".',
              ),
    );
  }
}

abstract class SystemCallPallet with SubstrateCallPallet {
  const SystemCallPallet({required this.type, required this.pallet});
  final SystemCallPalletMethod type;
  @override
  final SubstrateMetadataPallet pallet;
}

class SystemCallPalletRemark extends SystemCallPallet {
  final BuBytes value;

  SystemCallPalletRemark({
    required List<int> value,
    super.pallet = SubstrateMetadataPallet.system,
  }) : value = value.asImmutableBytes,
       super(type: SystemCallPalletMethod.remark);

  @override
  BuBytes encodeCall({
    required MetadataWithExtrinsic extrinsic,
    String? pallet,
    String? method,
  }) {
    return extrinsic.api
        .encodeCall(
          palletNameOrIndex: pallet ?? this.pallet.name,
          value: toJson(method: method),
        )
        .asImmutableBytes;
  }

  @override
  Map<String, dynamic> toJson({String? method}) {
    return {method ?? type.method: value};
  }
}
