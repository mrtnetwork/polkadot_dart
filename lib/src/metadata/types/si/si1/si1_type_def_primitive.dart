import 'package:polkadot_dart/src/metadata/types/si/si0/si0_type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';

class Si1TypeDefPrimitive extends Si0TypeDefPrimitive
    implements Si1TypeDef<Map<String, dynamic>> {
  Si1TypeDefPrimitive.deserializeJson(Map<String, dynamic> json)
      : super.deserializeJson(json);
  Si1TypeDefPrimitive(String type) : super(type);
  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.primitive;
}
