import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/portable_type.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type_def_sequence.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/portable_type_v14.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class PortableRegistryV14 extends SubstrateSerialization<Map<String, dynamic>>
    implements PortableRegistry {
  final Map<int, PortableTypeV14> types;
  PortableRegistryV14(List<PortableTypeV14> types)
      : types = Map<int, PortableTypeV14>.unmodifiable(
            Map<int, PortableTypeV14>.fromEntries(types.map((type) {
          return MapEntry(type.id, type);
        })));
  PortableRegistryV14.deserializeJson(Map<String, dynamic> json)
      : types = Map<int, PortableTypeV14>.unmodifiable(
            Map<int, PortableTypeV14>.fromEntries(
                (json["types"] as List).map((e) {
          final type = PortableTypeV14.deserializeJson(e);
          return MapEntry(type.id, type);
        })));
  @override
  StructLayout layout({String? property}) =>
      SubstrateMetadataLayouts.portableRegistry(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"types": types.values.map((e) => e.scaleJsonSerialize()).toList()};
  }

  PortableTypeV14 getLookupTByPath(List<String> paths) {
    final id = types.entries
        .firstWhere(
          (element) => iterableIsEqual(element.value.type.path, paths),
          orElse: () => throw MetadataException("lookup id does not found.",
              details: {"path": paths.join(", ")}),
        )
        .value;
    return id;
  }

  PortableTypeV14 getTypeByPath(List<String> paths) {
    final type = types.entries
        .firstWhere(
          (element) => iterableIsEqual(element.value.type.path, paths),
          orElse: () => throw MetadataException("lookup id does not found.",
              details: {"path": paths.join(", ")}),
        )
        .value;
    return type;
  }

  List<PortableTypeV14> getTypesByMainPath(String path) {
    final type = types.entries.where(
      (element) {
        if (element.value.type.path.isEmpty) return false;
        return element.value.type.path[0] == path;
      },
    );
    return type.map((e) => e.value).toList();
  }

  @override
  PortableType type(int id) {
    final lookup = types[id];

    if (lookup == null) {
      throw MetadataException("lookup does not exist.",
          details: {"id": id, "ids": types.keys.join(", ")});
    }
    return lookup;
  }

  @override
  Layout typeDefLayout(int id, dynamic value, {String? property}) {
    return type(id).type.typeDefLayout(this, value, property: property);
  }

  @override
  List<int> encode(int id, dynamic value, {String? property}) {
    final layout = typeDefLayout(id, value, property: property);
    return layout.serialize(value);
  }

  @override
  dynamic decode(int id, List<int> bytes, {String? property}) {
    final decode = type(id).type.typeDefDecode(this, bytes);
    return decode.value;
  }

  @override
  Si1TypeDefSequence findEventRecordLookup({int? knownId}) {
    if (knownId != null) {
      return Si1TypeDefSequence(knownId);
    }
    final eventPalle = types.entries
        .firstWhere(
          (element) => iterableIsEqual(
              element.value.type.path, MetadataConstant.eventPath),
          orElse: () => throw MetadataException("lookup id does not found."),
        )
        .value;
    return Si1TypeDefSequence(eventPalle.id);
  }

  @override
  ScaleInfoVersioned scaleType(int id) {
    return type(id).type;
  }

  @override
  TypeTemlate typeTemplate(int id) {
    return type(id).type.typeTemplate(this, id);
  }

  @override
  Object? getValue(
      {required int id, required Object? value, required bool fromTemplate}) {
    return type(id).type.getValue(
        registry: this, value: value, fromTemplate: fromTemplate, self: id);
  }
}
