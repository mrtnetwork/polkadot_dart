import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/metadata/types/si/si0/si0_type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/metadata/utils/utils.dart';

class TypeTemlate {
  /// self lookup id
  final int lookupId;

  /// if field has name
  final String? name;

  /// if field has typeName
  final String? typeName;

  /// length of array
  final int? length;

  final int? variantIndex;
  final bool? isCompact;

  final Si0TypeDefPrimitive? primitive;

  final Si1TypeDefsIndexesConst? type;

  final List<TypeTemlate> children;

  final List<String> path;

  bool get supported => MetadataUtils.supportedTemplate(path);

  const TypeTemlate({
    required this.lookupId,
    this.isCompact,
    this.name,
    this.typeName,
    this.primitive,
    required this.type,
    this.children = const [],
    this.length,
    this.path = const [],
    this.variantIndex,
  });

  TypeTemlate copyWith(
      {int? lookupId,
      String? name,
      String? typeName,
      Si0TypeDefPrimitive? primitive,
      Si1TypeDefsIndexesConst? type,
      List<TypeTemlate>? children,
      int? length,
      List<String>? path,
      bool? isCompact,
      int? variantIndex}) {
    return TypeTemlate(
        lookupId: lookupId ?? this.lookupId,
        type: type ?? this.type,
        children: children ?? this.children,
        length: length ?? this.length,
        name: name ?? this.name,
        primitive: primitive ?? this.primitive,
        typeName: typeName ?? this.typeName,
        path: path ?? this.path,
        isCompact: isCompact ?? this.isCompact,
        variantIndex: variantIndex ?? this.variantIndex);
  }

  Map<String, dynamic> toJson() {
    return {
      "lookupId": lookupId,
      "name": name,
      "typeName": typeName,
      "length": length,
      "primitive": primitive?.type.name,
      "type": type?.name,
      "children": children.map((e) => e.toJson()).toList(),
      "path": path,
      "isCompact": isCompact,
      "variantIndex": variantIndex
    };
  }

  bool get hasName => name != null;
  bool get isPrimitive => primitive != null;
  bool get isVariant => type == Si1TypeDefsIndexesConst.variant;

  Map<String, dynamic> buildJsonTemplate() {
    return MetadataTemplateBuilder.buildJson(this);
  }

  String buildJsonTemplateAsString() {
    return StringUtils.fromJson(buildJsonTemplate());
  }

  String showTemolate() {
    return StringUtils.fromJson(MetadataTemplateBuilder.buildString(this));
  }

  @override
  String toString() {
    return showTemolate();
  }
}
