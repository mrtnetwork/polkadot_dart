import 'package:blockchain_utils/utils/numbers/utils/int_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class RpcMethods with JsonSerialization {
  final int? version;
  final List<String> methods;
  RpcMethods({required this.version, required List<String> methods})
      : methods = List<String>.unmodifiable(methods);
  factory RpcMethods.fromJson(Map<String, dynamic> json) {
    return RpcMethods(
        version: IntUtils.tryParse(json["version"]),
        methods: (json["methods"] as List).cast());
  }

  @override
  Map<String, dynamic> toJson() {
    return {"version": version, "methods": methods};
  }
}
