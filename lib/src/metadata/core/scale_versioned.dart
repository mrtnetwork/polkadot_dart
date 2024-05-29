import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'portable_registry.dart';

/// Abstract class representing versioned scale information in the Substrate framework.
abstract class ScaleInfoVersioned {
  /// Returns the serialization layout of a type definition for the given [registry], [value], and optional [property].
  Layout typeDefLayout(PortableRegistry registry, dynamic value,
      {String? property});

  /// Decodes a type definition for the given [registry] and byte [bytes] array.
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes);

  /// Gets the constant indexes for the type name.
  Si1TypeDefsIndexesConst get typeName;

  /// The path for the type definition.
  abstract final List<String> path;

  /// The scale type definition.
  abstract final ScaleTypeDef def;

  /// Returns the template for the type definition for the given [registry] and [id].
  TypeTemlate typeTemplate(PortableRegistry registry, int id);

  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self});

  PrimitiveTypes? toPrimitive();
}

/// Abstract class representing a scale type definition in the Substrate framework.
abstract class ScaleTypeDef {
  /// Returns the serialization layout of a type definition for the given [registry], [value], and optional [property].
  Layout typeDefLayout(PortableRegistry registry, Object? value,
      {String? property});

  /// Decodes a type definition for the given [registry] and byte [bytes] array.
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes);

  /// Gets the constant indexes for the type name.
  Si1TypeDefsIndexesConst get typeName;

  /// Returns the template for the type definition for the given [registry] and [id].
  TypeTemlate typeTemplate(PortableRegistry registry, int id);

  /// Gets the value of the type definition for the given [registry], [value], [fromTemplate].
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self});
}
