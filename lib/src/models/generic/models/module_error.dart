import 'package:blockchain_utils/blockchain_utils.dart';

class ModuleError {
  final int index;
  final List<int> error;

  const ModuleError({required this.error, required this.index});
  factory ModuleError.fromJson(Map<String, dynamic> json) {
    return ModuleError(
        error: BytesUtils.fromHexString(json["error"]),
        index: IntUtils.parse(json["index"]));
  }
  static ModuleError? tryFromJson(Object? json) {
    try {
      return ModuleError.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
