import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class RuntimeVersionApi extends SubstrateSerialization<List> {
  final String apiId;
  final int version;
  RuntimeVersionApi({required this.apiId, required this.version});
  factory RuntimeVersionApi.deserializeJson(List json) {
    return RuntimeVersionApi(apiId: json[0], version: json[1]);
  }

  static Layout<List> layout_({String? property}) {
    return LayoutConst.tuple([
      LayoutConst.fixedBlobN(8),
      LayoutConst.u32(),
    ], property: property);
  }

  @override
  Layout<List> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  List serializeJson({String? property}) {
    return [apiId, version];
  }
}
