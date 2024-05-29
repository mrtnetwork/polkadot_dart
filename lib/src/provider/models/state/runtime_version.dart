import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/numbers/int_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'runtime_version_api.dart';

class RuntimeVersion with JsonSerialization {
  final String specName;
  final String implName;
  final int authoringVersion;
  final int specVersion;
  final int implVersion;
  final List<RuntimeVersionApi> apis;
  final int transactionVersion;
  final int stateVersion;
  RuntimeVersion(
      {required this.specName,
      required this.implName,
      required this.authoringVersion,
      required this.specVersion,
      required this.implVersion,
      required List<RuntimeVersionApi> apis,
      required this.transactionVersion,
      required this.stateVersion})
      : apis = List<RuntimeVersionApi>.unmodifiable(apis);
  factory RuntimeVersion.fromJson(Map<String, dynamic> json) {
    return RuntimeVersion(
        specName: json["specName"],
        implName: json["implName"],
        authoringVersion: IntUtils.parse(json["authoringVersion"]),
        specVersion: IntUtils.parse(json["specVersion"]),
        implVersion: IntUtils.parse(json["implVersion"]),
        apis: (json["apis"] as List)
            .map((e) => RuntimeVersionApi(
                apiId: BytesUtils.fromHexString(e[0]),
                version: IntUtils.parse(e[1])))
            .toList(),
        transactionVersion: IntUtils.parse(json["transactionVersion"]),
        stateVersion: IntUtils.parse(json["stateVersion"]));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "specName": specName,
      "implName": implName,
      "authoringVersion": authoringVersion,
      "specVersion": specVersion,
      "implVersion": implVersion,
      "apis": apis
          .map(
              (e) => [BytesUtils.toHexString(e.apiId, prefix: "0x"), e.version])
          .toList(),
      "transactionVersion": transactionVersion,
      "stateVersion": stateVersion
    };
  }
}
