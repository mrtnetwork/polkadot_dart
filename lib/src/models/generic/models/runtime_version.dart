import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'runtime_version_api.dart';

class RuntimeVersion extends SubstrateSerialization<Map<String, dynamic>> {
  final String specName;
  final String implName;
  final int authoringVersion;
  final int specVersion;
  final int implVersion;
  final List<RuntimeVersionApi> apis;
  final int transactionVersion;
  final int? stateVersion;
  final int? systemVersion;
  RuntimeVersion(
      {required this.specName,
      required this.implName,
      required this.authoringVersion,
      required this.specVersion,
      required this.implVersion,
      required List<RuntimeVersionApi> apis,
      required this.transactionVersion,
      this.stateVersion,
      this.systemVersion})
      : apis = List<RuntimeVersionApi>.unmodifiable(apis);
  RuntimeVersion.deserializeJson(Map<String, dynamic> json)
      : specVersion = json["spec_version"],
        implVersion = json["impl_version"],
        authoringVersion = json["authoring_version"],
        transactionVersion = json["transaction_version"],
        stateVersion = json["state_version"],
        apis = List<RuntimeVersionApi>.unmodifiable((json["apis"] as List)
            .map((e) => RuntimeVersionApi.deserializeJson(e))),
        implName = json["impl_name"],
        specName = json["spec_name"],
        systemVersion = json["system_version"];
  factory RuntimeVersion.fromJson(Map<String, dynamic> json) {
    return RuntimeVersion(
        specName: json["specName"],
        implName: json["implName"],
        authoringVersion: IntUtils.parse(json["authoringVersion"]),
        specVersion: IntUtils.parse(json["specVersion"]),
        implVersion: IntUtils.parse(json["implVersion"]),
        apis: (json["apis"] as List)
            .map((e) =>
                RuntimeVersionApi(apiId: e[0], version: IntUtils.parse(e[1])))
            .toList(),
        transactionVersion: IntUtils.parse(json["transactionVersion"]),
        stateVersion: IntUtils.tryParse(json["stateVersion"]),
        systemVersion: IntUtils.tryParse(json["systemVersion"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "specName": specName,
      "implName": implName,
      "authoringVersion": authoringVersion,
      "specVersion": specVersion,
      "implVersion": implVersion,
      "apis": apis.map((e) => [e.apiId, e.version]).toList(),
      "transactionVersion": transactionVersion,
      "stateVersion": stateVersion,
      "systemVersion": systemVersion
    };
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "spec_name": specName,
      "impl_name": implName,
      "authoring_version": authoringVersion,
      "impl_version": implVersion,
      "apis": apis.map((e) => e.serializeJson()).toList(),
      "transaction_version": transactionVersion,
      "state_version": stateVersion,
      "spec_version": specVersion
    };
  }
}
