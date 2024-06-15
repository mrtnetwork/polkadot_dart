import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class RuntimeVersionApi extends SubstrateSerialization<List> {
  final List<int> apiId;
  final int version;
  RuntimeVersionApi({required List<int> apiId, required this.version})
      : apiId = BytesUtils.toBytes(apiId, unmodifiable: true);
  RuntimeVersionApi.deserializeJson(List json)
      : apiId =
            BytesUtils.toBytes((json[0] as List).cast(), unmodifiable: true),
        version = json[1];

  @override
  Layout<List> layout({String? property}) {
    return GenericLayouts.runtimeVersionApi(property: property);
  }

  @override
  List scaleJsonSerialize({String? property}) {
    return [apiId, version];
  }
}
