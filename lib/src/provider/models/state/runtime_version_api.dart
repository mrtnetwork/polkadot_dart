import 'package:blockchain_utils/binary/utils.dart';

class RuntimeVersionApi {
  final List<int> apiId;
  final int version;
  RuntimeVersionApi({required List<int> apiId, required this.version})
      : apiId = BytesUtils.toBytes(apiId, unmodifiable: true);
}
