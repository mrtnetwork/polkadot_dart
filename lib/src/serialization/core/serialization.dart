import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/layout/byte/byte_handler.dart';

mixin JsonSerialization {
  Map<String, dynamic> toJson();
  @override
  String toString() {
    return "$runtimeType${toJson()}";
  }
}

abstract class SubstrateSerialization<T> {
  const SubstrateSerialization();

  List<int> serialize({String? property}) {
    final scaleLayout = layout();
    final LayoutByteWriter data = LayoutByteWriter(scaleLayout.span);
    final size =
        scaleLayout.encode(scaleJsonSerialize(property: property), data);
    if (scaleLayout.span < 0) {
      return data.sublist(0, size);
    }
    return data.toBytes();
  }

  Layout<T> layout({String? property});

  T scaleJsonSerialize({String? property});

  String toHex({String? prefix, bool lowerCase = true}) {
    return BytesUtils.toHexString(serialize(),
        lowerCase: lowerCase, prefix: prefix);
  }

  @override
  String toString() {
    return "$runtimeType${scaleJsonSerialize()}";
  }
}
