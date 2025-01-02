import 'package:polkadot_dart/src/metadata/types/si/si0/si0_type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';

class Si1TypeDefPrimitive extends Si0TypeDefPrimitive
    implements Si1TypeDef<Map<String, dynamic>> {
  Si1TypeDefPrimitive.deserializeJson(super.json) : super.deserializeJson();
  Si1TypeDefPrimitive(super.type);
  @override
  Si1TypeDefsIndexesConst get typeName => Si1TypeDefsIndexesConst.primitive;
}
