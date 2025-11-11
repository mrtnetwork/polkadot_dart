import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

enum EthereumRuntimeRpcsApiCallSucceedType {
  stopped("Stopped"),
  returned("Returned"),
  suicided("Suicided"),
  unknown("Unknown");

  const EthereumRuntimeRpcsApiCallSucceedType(this.type);
  final String type;

  static EthereumRuntimeRpcsApiCallSucceedType fromJson(
      Map<String, dynamic>? json) {
    final type = values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => EthereumRuntimeRpcsApiCallSucceedType.unknown);
    return type;
  }
}

enum EthereumRuntimeRpcsApiCallErrorType {
  stackUnderflow('StackUnderflow'),
  stackOverflow('StackOverflow'),
  invalidJump('InvalidJump'),
  invalidRange('InvalidRange'),
  designatedInvalid('DesignatedInvalid'),
  callTooDeep('CallTooDeep'),
  createCollision('CreateCollision'),
  createContractLimit('CreateContractLimit'),
  invalidCode('InvalidCode'),
  outOfOffset('OutOfOffset'),
  outOfGas('OutOfGas'),
  outOfFund('OutOfFund'),
  pcUnderflow('PCUnderflow'),
  createEmpty('CreateEmpty'),
  other('Other'),
  maxNonce('MaxNonce'),
  unknown('Unknown');

  final String type;

  const EthereumRuntimeRpcsApiCallErrorType(this.type);

  static EthereumRuntimeRpcsApiCallErrorType fromJson(
      Map<String, dynamic>? json) {
    final type = values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => EthereumRuntimeRpcsApiCallErrorType.unknown);
    return type;
  }
}

enum EthereumRuntimeRpcsApiCallRevertType {
  reverted('Reverted'),
  unknown('Unknown');

  final String type;

  const EthereumRuntimeRpcsApiCallRevertType(this.type);

  static EthereumRuntimeRpcsApiCallRevertType fromJson(
      Map<String, dynamic>? json) {
    final type = values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => EthereumRuntimeRpcsApiCallRevertType.unknown);
    return type;
  }

  static EthereumRuntimeRpcsApiCallRevertType fromType(String? type) {
    final result = values.firstWhere((e) => e.type == type,
        orElse: () => EthereumRuntimeRpcsApiCallRevertType.unknown);
    return result;
  }
}

enum EthereumRuntimeRpcsApiCallFatalType {
  notSupported('NotSupported'),
  unhandledInterrupt('UnhandledInterrupt'),
  callErrorAsFatal('CallErrorAsFatal'),
  other('Other'),
  unknown('Unknown');

  final String type;

  const EthereumRuntimeRpcsApiCallFatalType(this.type);

  static EthereumRuntimeRpcsApiCallFatalType fromJson(
      Map<String, dynamic>? json) {
    final type = values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => EthereumRuntimeRpcsApiCallFatalType.unknown);
    return type;
  }

  static EthereumRuntimeRpcsApiCallFatalType fromType(String? type) {
    final result = values.firstWhere((e) => e.type == type,
        orElse: () => EthereumRuntimeRpcsApiCallFatalType.unknown);
    return result;
  }
}

enum EthereumRuntimeRpcsApiCallExitReasonType {
  succeed('Succeed'),
  error('Error'),
  revert('Revert'),
  fatal('Other'),
  unknown('Unknown');

  final String type;

  const EthereumRuntimeRpcsApiCallExitReasonType(this.type);

  static EthereumRuntimeRpcsApiCallExitReasonType fromJson(
      Map<String, dynamic>? json) {
    final type = values.firstWhere((e) => e.type == json?.keys.firstOrNull,
        orElse: () => EthereumRuntimeRpcsApiCallExitReasonType.unknown);
    return type;
  }

  static EthereumRuntimeRpcsApiCallExitReasonType fromType(String? type) {
    final result = values.firstWhere((e) => e.type == type,
        orElse: () => EthereumRuntimeRpcsApiCallExitReasonType.unknown);
    return result;
  }

  bool get isSucceed => this == succeed;
}

abstract class BaseEthereumRuntimeRpcsApiCallExitReason {
  final EthereumRuntimeRpcsApiCallExitReasonType type;
  final Map<String, dynamic> result;
  bool get isSucceed => type.isSucceed;
  Map<String, dynamic> toJson() => result;
  const BaseEthereumRuntimeRpcsApiCallExitReason(
      {required this.type, required this.result});
  factory BaseEthereumRuntimeRpcsApiCallExitReason.fromJson(
      Map<String, dynamic> json) {
    final type = EthereumRuntimeRpcsApiCallExitReasonType.fromJson(json);
    return switch (type) {
      EthereumRuntimeRpcsApiCallExitReasonType.succeed =>
        EthereumRuntimeRpcsApiCallSucceed.fromJson(json),
      EthereumRuntimeRpcsApiCallExitReasonType.fatal =>
        BaseEthereumRuntimeRpcsApiCallExitReason.fromJson(json),
      EthereumRuntimeRpcsApiCallExitReasonType.error =>
        EthereumRuntimeRpcsApiCallError.fromJson(json),
      EthereumRuntimeRpcsApiCallExitReasonType.revert =>
        EthereumRuntimeRpcsApiCallRevert.fromJson(json),
      EthereumRuntimeRpcsApiCallExitReasonType.unknown =>
        EthereumRuntimeRpcsApiCallUnknown.fromJson(json),
    };
  }
}

class EthereumRuntimeRpcsApiCallSucceed
    extends BaseEthereumRuntimeRpcsApiCallExitReason {
  final EthereumRuntimeRpcsApiCallSucceedType reason;
  const EthereumRuntimeRpcsApiCallSucceed(
      {required this.reason, required super.result})
      : super(type: EthereumRuntimeRpcsApiCallExitReasonType.succeed);
  factory EthereumRuntimeRpcsApiCallSucceed.fromJson(
      Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallSucceed(
        reason: EthereumRuntimeRpcsApiCallSucceedType.fromJson(json
            .valueAs(EthereumRuntimeRpcsApiCallExitReasonType.succeed.type)),
        result: json);
  }
}

class EthereumRuntimeRpcsApiCallFatal
    extends BaseEthereumRuntimeRpcsApiCallExitReason {
  final EthereumRuntimeRpcsApiCallFatalType reason;
  const EthereumRuntimeRpcsApiCallFatal(
      {required this.reason, required super.result})
      : super(type: EthereumRuntimeRpcsApiCallExitReasonType.fatal);
  factory EthereumRuntimeRpcsApiCallFatal.fromJson(Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallFatal(
        reason: EthereumRuntimeRpcsApiCallFatalType.fromJson(
            json.valueAs(EthereumRuntimeRpcsApiCallExitReasonType.fatal.type)),
        result: json);
  }
}

class EthereumRuntimeRpcsApiCallError
    extends BaseEthereumRuntimeRpcsApiCallExitReason {
  final EthereumRuntimeRpcsApiCallErrorType reason;
  const EthereumRuntimeRpcsApiCallError(
      {required this.reason, required super.result})
      : super(type: EthereumRuntimeRpcsApiCallExitReasonType.error);
  factory EthereumRuntimeRpcsApiCallError.fromJson(Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallError(
        reason: EthereumRuntimeRpcsApiCallErrorType.fromJson(
            json.valueAs(EthereumRuntimeRpcsApiCallExitReasonType.error.type)),
        result: json);
  }
}

class EthereumRuntimeRpcsApiCallRevert
    extends BaseEthereumRuntimeRpcsApiCallExitReason {
  final EthereumRuntimeRpcsApiCallRevertType reason;
  const EthereumRuntimeRpcsApiCallRevert(
      {required this.reason, required super.result})
      : super(type: EthereumRuntimeRpcsApiCallExitReasonType.revert);
  factory EthereumRuntimeRpcsApiCallRevert.fromJson(Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallRevert(
        reason: EthereumRuntimeRpcsApiCallRevertType.fromJson(
            json.valueAs(EthereumRuntimeRpcsApiCallExitReasonType.revert.type)),
        result: json);
  }
}

class EthereumRuntimeRpcsApiCallUnknown
    extends BaseEthereumRuntimeRpcsApiCallExitReason {
  const EthereumRuntimeRpcsApiCallUnknown({required super.result})
      : super(type: EthereumRuntimeRpcsApiCallExitReasonType.unknown);
  factory EthereumRuntimeRpcsApiCallUnknown.fromJson(
      Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallUnknown(result: json);
  }
}

class EthereumRuntimeRpcsApiCallUsedGas {
  final List<BigInt> standard;
  final List<BigInt> effective;
  EthereumRuntimeRpcsApiCallUsedGas(
      {required List<BigInt> standard, required List<BigInt> effective})
      : standard = standard.exc(4).toImutableList,
        effective = effective.exc(4).toImutableList;
  factory EthereumRuntimeRpcsApiCallUsedGas.fromJson(
      Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallUsedGas(
        effective: json.valueEnsureAsList<BigInt>("effective"),
        standard: json.valueEnsureAsList<BigInt>("standard"));
  }
  Map<String, dynamic> toJson() {
    return {"effective": effective, "standard": standard};
  }
}

class EthereumRuntimeRpcsApiCallWeightInfo {
  final BigInt? refTimeLimit;
  final BigInt? proofSizeLimit;
  final BigInt? refTimeUsage;
  final BigInt? proofSizeUsage;
  const EthereumRuntimeRpcsApiCallWeightInfo(
      {this.refTimeLimit,
      this.proofSizeLimit,
      this.refTimeUsage,
      this.proofSizeUsage});
  factory EthereumRuntimeRpcsApiCallWeightInfo.fromJson(
      Map<String, dynamic> json) {
    final Map<String, dynamic>? result = MetadataUtils.parseOptional(json);
    if (result == null) return EthereumRuntimeRpcsApiCallWeightInfo();
    return EthereumRuntimeRpcsApiCallWeightInfo(
      refTimeLimit:
          MetadataUtils.parseOptional(result.valueAs("ref_time_limit")),
      proofSizeLimit:
          MetadataUtils.parseOptional(result.valueAs("proof_size_limit")),
      refTimeUsage:
          MetadataUtils.parseOptional(result.valueAs("ref_time_usage")),
      proofSizeUsage:
          MetadataUtils.parseOptional(result.valueAs("proof_size_usage")),
    );
  }
  Map<String, dynamic> toJson() {
    return MetadataUtils.toOptionalJson({
      "ref_time_limit": MetadataUtils.toOptionalJson(refTimeLimit),
      "proof_size_limit": MetadataUtils.toOptionalJson(proofSizeLimit),
      "ref_time_usage": MetadataUtils.toOptionalJson(refTimeUsage),
      "proof_size_usage": MetadataUtils.toOptionalJson(proofSizeUsage),
    });
  }
}

class EthereumRuntimeRpcsApiCallLog {
  final SubstrateEthereumAddress address;
  final List<String> topics;
  final List<int> data;
  const EthereumRuntimeRpcsApiCallLog(
      {required this.address, required this.topics, required this.data});
  factory EthereumRuntimeRpcsApiCallLog.fromJson(Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCallLog(
        address:
            SubstrateEthereumAddress.fromBytes(json.valueAsBytes("address")),
        data: json.valueAsBytes("data"),
        topics: json.valueEnsureAsList<String>("topics"));
  }

  Map<String, dynamic> toJson() {
    return {
      "address": address.address,
      "topics": topics,
      "data": BytesUtils.toHexString(data)
    };
  }
}

class EthereumRuntimeRpcsApiCall {
  final BaseEthereumRuntimeRpcsApiCallExitReason exitReason;
  final List<int> value;
  final EthereumRuntimeRpcsApiCallUsedGas usedGas;
  final EthereumRuntimeRpcsApiCallWeightInfo weightInfo;
  final List<EthereumRuntimeRpcsApiCallLog> logs;
  const EthereumRuntimeRpcsApiCall(
      {required this.exitReason,
      required this.value,
      required this.usedGas,
      required this.weightInfo,
      required this.logs});
  Map<String, dynamic> toJson() {
    return {
      "exit_reason": exitReason.toJson(),
      "value": BytesUtils.toHexString(value),
      "used_gas": usedGas.toJson(),
      "weight_info": weightInfo.toJson(),
      "logs": logs.map((e) => e.toJson()).toList()
    };
  }

  factory EthereumRuntimeRpcsApiCall.fromJson(Map<String, dynamic> json) {
    return EthereumRuntimeRpcsApiCall(
        exitReason: BaseEthereumRuntimeRpcsApiCallExitReason.fromJson(
            json.valueAs("exit_reason")),
        value: json.valueAsBytes("value"),
        usedGas: EthereumRuntimeRpcsApiCallUsedGas.fromJson(
            json.valueAs("used_gas")),
        weightInfo: EthereumRuntimeRpcsApiCallWeightInfo.fromJson(
            json.valueAs("weight_info")),
        logs: json
            .valueEnsureAsList<Map<String, dynamic>>("logs")
            .map((e) => EthereumRuntimeRpcsApiCallLog.fromJson(e))
            .toList());
  }
}
