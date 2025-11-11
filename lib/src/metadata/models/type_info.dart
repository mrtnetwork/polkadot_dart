import 'package:blockchain_utils/exception/exception/exception.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si.dart';

class MetadataTypeInfoUtils {
  static String? toCamelCase(String? input) {
    if (input == null) return null;
    if (input.isEmpty) {
      return input;
    }
    input = input.replaceAll('-', ' ').replaceAll('_', ' ');

    final List<String> words = input.split(' ');

    // Capitalize the first letter of each words
    final List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return '';
      }
    }).toList();

    // Join the words to form CamelCase
    final String camelCaseString = capitalizedWords.join('');

    return camelCaseString;
  }
}

enum MetadataTypes {
  none,
  boolean,
  string,
  int,
  bigInt,
  array,
  sequence,
  tuple,
  composit,
  variant
}

abstract class MetadataTypeInfo<T> {
  final String? name;
  final int typeId;
  final List<String>? docs;
  final List<String>? paths;
  bool get isNone => typeName == MetadataTypes.none;
  late String? viewName = MetadataTypeInfoUtils.toCamelCase(name);
  MetadataTypeInfo(
      {required this.typeId,
      this.name,
      List<String>? docs,
      List<String>? paths})
      : docs = docs?.emptyAsNull?.immutable,
        paths = paths?.emptyAsNull?.immutable;
  MetadataTypeInfo<T> copyWith(
      {String? name, List<String>? paths, List<String>? docs, int? typeId});
  bool get isPromitive;
  MetadataTypes get typeName;

  E cast<E extends MetadataTypeInfo>() {
    if (this is! E) {
      throw CastFailedException<E>(value: this);
    }
    return this as E;
  }

  E? findType<E extends MetadataTypeInfo>(String name) {
    if (this.name == name && this is E) return this as E;
    return null;
  }

  List<String> getTypeNames() {
    if (name == null) return [];
    return [name!];
  }
}

abstract class MetadataTypeInfoPromitive<T> extends MetadataTypeInfo {
  MetadataTypeInfoPromitive(
      {required super.typeId,
      required super.name,
      super.docs,
      super.paths,
      required this.primitiveType});
  @override
  bool get isPromitive => true;
  final PrimitiveTypes primitiveType;
}

class MetadataTypeInfoBoolean extends MetadataTypeInfoPromitive<bool> {
  MetadataTypeInfoBoolean(
      {required super.typeId, super.name, super.docs, super.paths})
      : super(primitiveType: PrimitiveTypes.boolType);
  @override
  String toString() {
    return "bool";
  }

  @override
  MetadataTypeInfoPromitive<bool> copyWith({
    String? name,
    List<String>? paths,
    List<String>? docs,
    int? typeId,
  }) {
    return MetadataTypeInfoBoolean(
        typeId: typeId ?? this.typeId,
        name: name ?? this.name,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => true;

  @override
  MetadataTypes get typeName => MetadataTypes.boolean;
}

class MetadataTypeInfoString extends MetadataTypeInfoPromitive<String> {
  MetadataTypeInfoString(
      {required super.typeId, super.name, super.docs, super.paths})
      : super(primitiveType: PrimitiveTypes.strType);
  @override
  String toString() {
    return "String";
  }

  @override
  MetadataTypeInfoPromitive<String> copyWith({
    int? typeId,
    String? name,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoString(
        name: name ?? super.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => true;

  @override
  MetadataTypes get typeName => MetadataTypes.string;
}

abstract class MetadataTypeInfoNumeric<T> extends MetadataTypeInfoPromitive<T> {
  MetadataTypeInfoNumeric({
    required super.typeId,
    required super.name,
    required super.primitiveType,
    super.docs,
    super.paths,
  });

  @override
  bool get isPromitive => true;
  bool get isBigInt => false;

  @override
  MetadataTypes get typeName => MetadataTypes.int;

  @override
  E? findType<E extends MetadataTypeInfo>(String name) {
    if (this.name == name && this is E) return this as E;
    return null;
  }
}

class MetadataTypeInfoBigInt extends MetadataTypeInfoNumeric<BigInt> {
  MetadataTypeInfoBigInt(
      {required super.typeId,
      required super.name,
      required super.primitiveType,
      super.docs,
      super.paths});
  @override
  String toString() {
    return "MetadataTypeInfoNumeric.${primitiveType.name}";
  }

  @override
  MetadataTypeInfoPromitive<BigInt> copyWith(
      {bool? sign,
      int? bitLength,
      String? name,
      int? typeId,
      List<String>? paths,
      List<String>? docs,
      PrimitiveTypes? primitiveType}) {
    return MetadataTypeInfoBigInt(
        typeId: typeId ?? this.typeId,
        name: name ?? this.name,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs,
        primitiveType: primitiveType ?? this.primitiveType);
  }

  @override
  MetadataTypes get typeName => MetadataTypes.bigInt;

  @override
  bool get isBigInt => true;
}

class MetadataTypeInfoInt extends MetadataTypeInfoNumeric<int> {
  MetadataTypeInfoInt(
      {required super.name,
      required super.typeId,
      required super.primitiveType,
      super.docs,
      super.paths});
  @override
  MetadataTypeInfoPromitive<int> copyWith(
      {bool? sign,
      int? bitLength,
      String? name,
      int? typeId,
      List<String>? paths,
      List<String>? docs,
      PrimitiveTypes? primitiveType}) {
    return MetadataTypeInfoInt(
        typeId: typeId ?? this.typeId,
        name: name ?? this.name,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs,
        primitiveType: primitiveType ?? this.primitiveType);
  }

  @override
  String toString() {
    return "MetadataTypeInfoNumeric.${primitiveType.name}";
  }
}

class MetadataTypeInfoArray<T extends MetadataTypeInfo>
    extends MetadataTypeInfoSequence<T> {
  MetadataTypeInfoArray(
      {required super.type,
      required int super.length,
      required super.typeId,
      required super.name,
      super.docs,
      super.paths});
  @override
  String toString() {
    return "List<$type>";
  }

  @override
  MetadataTypeInfoArray<T> copyWith({
    String? name,
    T? type,
    int? length,
    int? typeId,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoArray(
        type: type ?? this.type,
        length: length ?? this.length!,
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => false;

  @override
  MetadataTypes get typeName => MetadataTypes.array;
}

class MetadataTypeInfoNone extends MetadataTypeInfo {
  MetadataTypeInfoNone(
      {required super.typeId, required super.name, super.docs, super.paths});
  @override
  String toString() {
    return "None";
  }

  @override
  MetadataTypeInfo copyWith({
    String? name,
    int? typeId,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoNone(
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => throw UnimplementedError();

  @override
  MetadataTypes get typeName => MetadataTypes.none;
  @override
  List<String> getTypeNames() {
    return [];
  }
}

class MetadataTypeInfoTuple<T extends MetadataTypeInfo>
    extends MetadataTypeInfo {
  final List<T> types;
  MetadataTypeInfoTuple(
      {required this.types,
      required super.typeId,
      required super.name,
      super.docs,
      super.paths});
  @override
  String toString() {
    return "Tuple(${types.join(", ")})";
  }

  @override
  MetadataTypeInfo copyWith({
    String? name,
    List<T>? types,
    int? typeId,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoTuple(
        types: types ?? this.types,
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => false;

  @override
  MetadataTypes get typeName => MetadataTypes.tuple;

  @override
  E? findType<E extends MetadataTypeInfo>(String name) {
    for (final i in types) {
      final type = i.findType<E>(name);
      if (type != null) return type;
    }
    if (this.name == name && this is E) return this as E;
    return null;
  }

  @override
  List<String> getTypeNames() {
    return types.map((e) => e.getTypeNames()).expand((e) => e).toList();
  }
}

class MetadataTypeInfoComposit<T extends MetadataTypeInfo>
    extends MetadataTypeInfo {
  final List<T> types;
  MetadataTypeInfoComposit(
      {required this.types,
      required super.name,
      required super.typeId,
      super.docs,
      super.paths});
  @override
  String toString() {
    return "MetadataTypeInfoComposit(${types.toString()})";
  }

  @override
  MetadataTypeInfo copyWith({
    List<T>? types,
    String? name,
    int? typeId,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoComposit(
        types: types ?? this.types,
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => false;

  @override
  MetadataTypes get typeName => MetadataTypes.composit;
  @override
  E? findType<E extends MetadataTypeInfo>(String name) {
    for (final i in types) {
      final type = i.findType<E>(name);
      if (type != null) return type;
    }
    if (this.name == name && this is E) return this as E;
    return null;
  }

  @override
  List<String> getTypeNames() {
    return types.map((e) => e.getTypeNames()).expand((e) => e).toList();
  }
}

class MetadataTypeInfoSequence<T extends MetadataTypeInfo>
    extends MetadataTypeInfo<List<T>> {
  final T type;
  final int? length;
  MetadataTypeInfoSequence(
      {required this.type,
      required super.name,
      required super.typeId,
      this.length,
      super.docs,
      super.paths});

  @override
  String toString() {
    return "List<$type>";
  }

  @override
  MetadataTypeInfo<List<T>> copyWith(
      {T? type,
      String? name,
      int? typeId,
      List<String>? paths,
      List<String>? docs,
      int? length}) {
    return MetadataTypeInfoSequence(
        type: type ?? this.type,
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs,
        length: length ?? this.length);
  }

  @override
  bool get isPromitive => false;

  @override
  MetadataTypes get typeName => MetadataTypes.sequence;

  @override
  E? findType<E extends MetadataTypeInfo>(String name) {
    final type = this.type.findType<E>(name);
    if (type != null) return type;
    if (this.name == name && this is E) return this as E;
    return null;
  }

  @override
  List<String> getTypeNames() {
    if (name == null) return [];
    return [name!];
  }
}

class MetadataTypeInfoVariant extends MetadataTypeInfo {
  final List<Si1Variant> variants;
  MetadataTypeInfoVariant({
    required this.variants,
    required super.typeId,
    required super.name,
    super.docs,
    super.paths,
  });
  @override
  String toString() {
    return "Enum{${variants.join(", ")}}";
  }

  @override
  MetadataTypeInfo copyWith({
    List<Si1Variant>? variants,
    String? name,
    int? typeId,
    List<String>? paths,
    List<String>? docs,
  }) {
    return MetadataTypeInfoVariant(
        variants: variants ?? this.variants,
        name: name ?? this.name,
        typeId: typeId ?? super.typeId,
        paths: paths ?? this.paths,
        docs: docs ?? this.docs);
  }

  @override
  bool get isPromitive => false;

  @override
  MetadataTypes get typeName => MetadataTypes.variant;
}
