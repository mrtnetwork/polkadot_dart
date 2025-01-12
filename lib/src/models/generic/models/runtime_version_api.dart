import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class RuntimeVersionApi extends SubstrateSerialization<List> {
  final String apiId;
  final int version;
  RuntimeVersionApi({required this.apiId, required this.version});
  factory RuntimeVersionApi.deserializeJson(List json) {
    return RuntimeVersionApi(apiId: json[0], version: json[1]);
  }

  @override
  Layout<List> layout({String? property}) {
    return GenericLayouts.runtimeVersionApi(property: property);
  }

  @override
  List scaleJsonSerialize({String? property}) {
    return [apiId, version];
  }
}
