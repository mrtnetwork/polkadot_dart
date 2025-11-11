import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/portable_type.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/models/type_info.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.dart';
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
  Map<String, dynamic> serializeJson({String? property}) {
    return {"types": types.values.map((e) => e.serializeJson()).toList()};
  }

  PortableTypeV14 getLookupTByPath(List<String> paths) {
    final id = types.entries
        .firstWhere(
          (element) =>
              CompareUtils.iterableIsEqual(element.value.type.path, paths),
          orElse: () => throw MetadataException("lookup id does not found.",
              details: {"path": paths.join(", ")}),
        )
        .value;
    return id;
  }

  PortableTypeV14 getTypeByPath(List<String> paths) {
    final type = types.entries
        .firstWhere(
          (element) =>
              CompareUtils.iterableIsEqual(element.value.type.path, paths),
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
  List<int> encode(int id, dynamic value, {String? property}) {
    final correctValue = getValue(id: id, value: value, fromTemplate: false);
    final encode =
        serializationLayout(id, property: property).serialize(correctValue);
    return encode;
  }

  @override
  dynamic decode(int id, List<int> bytes,
      {String? property, int offset = 0, LookupDecodeParams? params}) {
    final decode = serializationLayout(id, property: property)
        .deserialize(bytes, offset: offset);
    return decode.value;
  }

  @override
  Si1TypeDefSequence findEventRecordLookup({int? knownId}) {
    if (knownId != null) {
      return Si1TypeDefSequence(knownId);
    }
    final eventPalle = types.entries
        .firstWhere(
          (element) => CompareUtils.iterableIsEqual(
              element.value.type.path, MetadataConstant.eventPath),
          orElse: () =>
              throw const MetadataException("lookup id does not found."),
        )
        .value;
    return Si1TypeDefSequence(eventPalle.id);
  }

  @override
  Si1Type scaleType(int id) {
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

  @override
  MetadataTypeInfo typeInfo(int id) {
    return type(id).type.typeInfo(this, id);
  }

  @override
  PortableType? typeByPaths(List<String> paths) {
    return types.values.firstWhereNullable((e) {
      return CompareUtils.iterableIsEqual(e.type.path, paths);
    });
  }

  @override
  PortableType? typeByPathTail(String path) {
    return types.values.firstWhereNullable((e) {
      return e.type.path.lastOrNull == path;
    });
  }

  @override
  int? typeByFieldName(String name) {
    for (final i in types.values) {
      final f = i.type.def.typeByFieldName(this, i.id, name);
      if (f != null) return f;
    }
    return null;
  }

  @override
  int? typeByName(String name) {
    for (final i in types.values) {
      final f = i.type.def.typeByName(this, i.id, name);
      if (f != null) return f;
    }
    return null;
  }

  @override
  Layout serializationLayout(int lookup,
      {String? property, LookupDecodeParams? params}) {
    return type(lookup)
        .type
        .serializationLayout(this, property: property, params: params);
  }
}
