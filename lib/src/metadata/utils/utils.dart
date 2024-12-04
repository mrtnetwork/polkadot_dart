import 'package:polkadot_dart/src/metadata/metadata.dart';

class MetadataTemplateBuilder {
  static String _getCompositeType(List<TypeTemlate> children) {
    if (children.isEmpty) return "null";
    final isStruct = children[0].hasName;
    if (children.length == 1 && !children[0].hasName) {
      return _correctType(children[0]);
    }
    if (isStruct) {
      return "Map";
    }
    return "Tuple";
  }

  static String _getArrayType(List<TypeTemlate> children, int? length) {
    assert((children.isEmpty || children.length == 1) && length != null,
        "Array types must accept one element");
    if (children.isEmpty) return "[]";
    final child = children[0];
    if (child.isPrimitive) return "[${child.primitive!.type.name};$length]";

    return "[${_correctType(child)};$length]";
  }

  static String _getTuppleType(List<TypeTemlate> children) {
    return "Tuple(${children.map((e) => _correctType(e)).join(", ")})";
  }

  static String _getSequanceType(TypeTemlate template) {
    assert(template.children.length == 1 && template.length == null,
        "Array must have length 1");
    final child = template.children[0];
    if (child.isPrimitive) return "Vec<${child.primitive!.type.name}>";
    if (template.typeName != null) return template.typeName!;
    if (template.path.isNotEmpty) return "Vec<${template.path.last}>";
    return "Vec<T>";
  }

  static Map<String, dynamic> _createStructValues(List<TypeTemlate> children) {
    if (children.length == 1 && !children[0].hasName) {
      return buildJson(children[0]);
    }
    if (children.isNotEmpty && children[0].hasName) {
      final Map<String, dynamic> valueTemplate = {};
      for (final i in children) {
        valueTemplate[i.name!] = buildJson(i);
      }
      return {"type": "Map", "value": valueTemplate};
    }

    return {
      "type": "Tuple",
      "value": children.map((e) => buildJson(e)).toList()
    };
  }

  static Map<String, dynamic> _createVariantStruct(List<TypeTemlate> children) {
    assert(children.isNotEmpty);
    if (children.length == 1) {
      return buildJson(children[0]);
    }
    return _createStructValues(children);
  }

  static Map<String, dynamic>? _createVariantsValues(TypeTemlate template) {
    if (template.children.isEmpty) {
      return null;
    }
    return {
      "type": _correctType(template),
      ..._createVariantStruct(template.children)
    };
  }

  static Map<String, Object> _createVariantValue(TypeTemlate template) {
    final Map<String, dynamic> variants = {};
    if (!template.supported) {
      return {
        "variants":
            "${template.typeName} does not support to build variants. please look at metadata json file",
        "path": template.path
      };
    }
    for (final i in template.children) {
      variants[i.name!] = _createVariantsValues(i);
    }

    return {"variants": variants};
  }

  static List<Map<String, dynamic>>? _createArrayAndSequanceValue(
      TypeTemlate template) {
    assert(template.children.length == 1);
    final child = template.children[0];
    if (child.isPrimitive) return null;
    return [buildJson(child)];
  }

  static List<Map<String, dynamic>> _createTuppleValue(
      List<TypeTemlate> children) {
    return children.map((e) => buildJson(e)).toList();
  }

  static Map<String, dynamic> _createOptionValue(List<TypeTemlate> children) {
    assert(children.length == 1);
    final template = buildJson(children[0]);
    template["type"] = "Option<${template["type"]}>";
    return template;
  }

  static String _compactType(List<TypeTemlate> children) {
    assert(children.length == 1);
    return _correctType(children[0]);
  }

  static String _correctType(TypeTemlate template) {
    if (template.type == null) return _getCompositeType(template.children);
    switch (template.type) {
      case Si1TypeDefsIndexesConst.composite:
        return _getCompositeType(template.children);
      case Si1TypeDefsIndexesConst.array:
        return _getArrayType(template.children, template.length);
      case Si1TypeDefsIndexesConst.sequence:
        return _getSequanceType(template);
      case Si1TypeDefsIndexesConst.primitive:
        return template.primitive!.type.name;
      case Si1TypeDefsIndexesConst.compact:
        return _compactType(template.children);
      case Si1TypeDefsIndexesConst.variant:
        return "Enum";
      case Si1TypeDefsIndexesConst.historicMetaCompat:
        return "HistoricMetaCompat";
      case Si1TypeDefsIndexesConst.bitSequence:
        return "[U8]";
      case Si1TypeDefsIndexesConst.option:
        return "Option<${_correctType(template.children[0])}>";
      default:
        return _getTuppleType(template.children);
    }
  }

  static Map<String, Object?> _correctValue(TypeTemlate template) {
    if (template.isVariant) {
      return {"key": null, "value": null};
    }
    Object? val;
    switch (template.type) {
      case Si1TypeDefsIndexesConst.array:
      case Si1TypeDefsIndexesConst.sequence:
        val = _createArrayAndSequanceValue(template);
        break;
      case Si1TypeDefsIndexesConst.tuple:
        val = _createTuppleValue(template.children);
        break;

      default:
        break;
    }
    return {"value": val};
  }

  static Map<String, dynamic> buildJson(TypeTemlate template) {
    switch (template.type) {
      case Si1TypeDefsIndexesConst.composite:
        return _createStructValues(template.children);
      case Si1TypeDefsIndexesConst.option:
        return _createOptionValue(template.children);
      default:
    }
    return {
      "type": _correctType(template),
      ..._correctValue(template),
      if (template.isVariant) ..._createVariantValue(template),
    };
  }

  static String _getArrayStringType(TypeTemlate template) {
    assert(
        (template.children.isEmpty || template.children.length == 1) &&
            template.length != null,
        "Array must have length 1");
    if (template.children.isEmpty) return "[;${template.length}]";
    final child = template.children[0];
    return "[${buildString(child)};${template.length}]";
  }

  static String _getSequanceStringType(TypeTemlate template) {
    assert(template.children.length == 1 && template.length == null,
        "Array shuld be have children");
    if (template.children.isEmpty) return "[]";
    final child = template.children[0];
    return "[${buildString(child)}]";
  }

  static String _compactStringType(TypeTemlate template) {
    assert(template.children.length == 1);
    return buildString(template.children[0]);
  }

  static String _tupleStringType(List<TypeTemlate> children) {
    return "Tuple(${children.map((e) => buildString(e)).join(", ")})";
  }

  static String _getCompositeStringType(TypeTemlate template) {
    if (template.children.isEmpty) return "null";
    final isStruct = template.children[0].hasName;
    if (template.children.length == 1 && !isStruct) {
      return buildString(template.children[0]);
    }
    if (isStruct) {
      return "Map${{
        for (final i in template.children) i.name: buildString(i)
      }}";
    }
    return _tupleStringType(template.children);
  }

  static String _getVariantStringType(TypeTemlate template) {
    if (template.children.length == 1) {
      return buildString(template.children[0]);
    }
    return _getCompositeStringType(template);
  }

  static String _getVariantsStringType(TypeTemlate template) {
    if (!template.supported) {
      return "OneOf${{
        "variants":
            "${template.typeName} does not support to build variants. please look at metadata json file",
        "path": template.path
      }}";
    }
    final values = {
      for (final i in template.children) i.name: _getVariantStringType(i)
    };
    return "OneOf$values";
  }

  static String buildString(TypeTemlate template) {
    if (template.type == null) return _getCompositeStringType(template);
    switch (template.type) {
      case Si1TypeDefsIndexesConst.composite:
        return _getCompositeStringType(template);
      case Si1TypeDefsIndexesConst.array:
        return _getArrayStringType(template);
      case Si1TypeDefsIndexesConst.sequence:
        return _getSequanceStringType(template);
      case Si1TypeDefsIndexesConst.primitive:
        return template.primitive!.type.name;
      case Si1TypeDefsIndexesConst.compact:
        return _compactStringType(template);
      case Si1TypeDefsIndexesConst.variant:
        return _getVariantsStringType(template);
      case Si1TypeDefsIndexesConst.historicMetaCompat:
        return "HistoricMetaCompat";
      case Si1TypeDefsIndexesConst.bitSequence:
        return "[U8]";
      case Si1TypeDefsIndexesConst.option:
        return "Option<${buildString(template.children[0])}>";
      default:
        return _tupleStringType(template.children);
    }
  }
}
