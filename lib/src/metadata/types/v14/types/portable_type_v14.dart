import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_type.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PortableTypeV14 extends SubstrateSerialization<Map<String, dynamic>>
    implements PortableType {
  @override
  final int id;
  @override
  final Si1Type type;
  const PortableTypeV14({required this.id, required this.type});
  PortableTypeV14.deserializeJson(Map<String, dynamic> json)
      : type = Si1Type.deserializeJson(json["type"]),
        id = json["id"];
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.portableTypeV14(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"id": id, "type": type.scaleJsonSerialize()};
  }
}
