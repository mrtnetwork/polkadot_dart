import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type_def_sequence.dart';
import 'portable_type.dart';

/// Abstract class representing a registry for portable type information in the Substrate framework.
abstract class PortableRegistry {
  /// Returns the Serialization layout of a type definition for the given [lookup] identifier and [value].
  ///
  /// [lookup] is the identifier for the type definition.
  /// [value] is the dynamic value to layout.
  /// [property] is an optional property name.
  Layout typeDefLayout(int lookup, dynamic value, {String? property});

  /// Encodes a value for the given type definition [id].
  ///
  /// [id] is the identifier for the type definition.
  /// [value] is the value to encode.
  /// [property] is an optional property name.
  List<int> encode(int id, dynamic value, {String? property});

  /// Decodes a byte array for the given type definition [id].
  ///
  /// [id] is the identifier for the type definition.
  /// [bytes] is the byte array to decode.
  /// [property] is an optional property name.
  dynamic decode(int id, List<int> bytes, {String? property});

  /// Finds the lookup identifier for an event record sequence type definition.
  ///w
  /// [knownId] is an optional known identifier.
  Si1TypeDefSequence findEventRecordLookup({int? knownId});

  /// Returns the portable type information for the given [id].
  ///
  /// [id] is the identifier for the type.
  PortableType type(int id);

  /// Returns the versioned type definition for the given [id].
  ///
  /// [id] is the identifier for the type definition.
  ScaleInfoVersioned scaleType(int id);

  /// Returns the template for the type definition for the given [id].
  ///
  /// [id] is the identifier for the type definition.
  TypeTemlate typeTemplate(int id);

  Object? getValue(
      {required int id, required Object? value, required bool fromTemplate});
}
