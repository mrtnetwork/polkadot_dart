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
        "Array must have length 1");
    if (children.isEmpty) return "[]";
    final child = children[0];
    if (child.isPrimitive) return "[${child.primitive!.type.name};$length]";

    return "[${_correctType(child)};$length]";
  }

  static String _getTuppleType(List<TypeTemlate> children) {
    return "Tuple(${children.map((e) => _compactType(e.children)).join(", ")})";
  }

  static String _getSequanceType(TypeTemlate temlate) {
    assert(temlate.children.length == 1 && temlate.length == null,
        "Array must have length 1");
    final child = temlate.children[0];
    if (child.isPrimitive) return "Vec<${child.primitive!.type.name}>";
    if (temlate.typeName != null) return temlate.typeName!;
    if (temlate.path.isNotEmpty) return "Vec<${temlate.path.last}>";
    return "Vec<T>";
  }

  static Map<String, dynamic> _createStructValue2(List<TypeTemlate> children) {
    assert(children.isNotEmpty);
    if (children.length == 1 && !children[0].hasName) {
      return buildJson(children[0]);
    }
    if (children[0].hasName) {
      Map<String, dynamic> valueTemplate = {};
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
    return _createStructValue2(children);
  }

  static Map<String, dynamic>? _createVariantsValues(TypeTemlate temlate) {
    if (temlate.children.isEmpty) {
      return null;
    }
    return {
      "type": _correctType(temlate),
      ..._createVariantStruct(temlate.children)
    };
  }

  static Map<String, Object> _createVariantValue(TypeTemlate temlate) {
    final Map<String, dynamic> variants = {};
    for (final i in temlate.children) {
      variants[i.name!] = _createVariantsValues(i);
    }

    return {"variants": variants};
  }

  static List<Map<String, dynamic>>? _createArrayAndSequanceValue(
      TypeTemlate temlate) {
    assert(temlate.children.length == 1);
    final child = temlate.children[0];
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

  static String _correctType(TypeTemlate temlate) {
    if (temlate.type == null) return _getCompositeType(temlate.children);
    switch (temlate.type) {
      case Si1TypeDefsIndexesConst.composite:
        return _getCompositeType(temlate.children);
      case Si1TypeDefsIndexesConst.array:
        return _getArrayType(temlate.children, temlate.length);
      case Si1TypeDefsIndexesConst.sequence:
        return _getSequanceType(temlate);
      case Si1TypeDefsIndexesConst.primitive:
        return temlate.primitive!.type.name;
      case Si1TypeDefsIndexesConst.compact:
        return _compactType(temlate.children);
      case Si1TypeDefsIndexesConst.variant:
        return "Enum";
      case Si1TypeDefsIndexesConst.historicMetaCompat:
        return "HistoricMetaCompat";
      case Si1TypeDefsIndexesConst.bitSequence:
        return "[U8]";
      case Si1TypeDefsIndexesConst.option:
        return "Option<${_correctType(temlate.children[0])}>";
      default:
        return _getTuppleType(temlate.children);
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
        return _createStructValue2(template.children);
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

  static String _getArrayStringType(TypeTemlate temlate) {
    assert(
        (temlate.children.isEmpty || temlate.children.length == 1) &&
            temlate.length != null,
        "Array must have length 1");
    if (temlate.children.isEmpty) return "[;${temlate.length}]";
    final child = temlate.children[0];
    return "[${buildString(child)};${temlate.length}]";
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

  static String _getCompositeStringType(TypeTemlate temlate) {
    if (temlate.children.isEmpty) return "null";
    final isStruct = temlate.children[0].hasName;
    if (temlate.children.length == 1 && !isStruct) {
      return buildString(temlate.children[0]);
    }
    if (isStruct) {
      return "Map${{for (final i in temlate.children) i.name: buildString(i)}}";
    }
    return _tupleStringType(temlate.children);
  }

  static String _getVariantStringType(TypeTemlate temlate) {
    if (temlate.children.length == 1) {
      return buildString(temlate.children[0]);
    }
    return _getCompositeStringType(temlate);
  }

  static String _getVariantsStringType(TypeTemlate temlate) {
    final values = {
      for (final i in temlate.children) i.name: _getVariantStringType(i)
    };
    return "OneOf$values";
  }

  static String buildString(TypeTemlate temlate) {
    if (temlate.type == null) return _getCompositeStringType(temlate);
    switch (temlate.type) {
      case Si1TypeDefsIndexesConst.composite:
        return _getCompositeStringType(temlate);
      case Si1TypeDefsIndexesConst.array:
        return _getArrayStringType(temlate);
      case Si1TypeDefsIndexesConst.sequence:
        return _getSequanceStringType(temlate);
      case Si1TypeDefsIndexesConst.primitive:
        return temlate.primitive!.type.name;
      case Si1TypeDefsIndexesConst.compact:
        return _compactStringType(temlate);
      case Si1TypeDefsIndexesConst.variant:
        return _getVariantsStringType(temlate);
      case Si1TypeDefsIndexesConst.historicMetaCompat:
        return "HistoricMetaCompat";
      case Si1TypeDefsIndexesConst.bitSequence:
        return "[U8]";
      case Si1TypeDefsIndexesConst.option:
        return "Option<${buildString(temlate.children[0])}>";
      default:
        return _tupleStringType(temlate.children);
    }
  }
}
