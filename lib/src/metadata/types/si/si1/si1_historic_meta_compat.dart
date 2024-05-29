import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_template.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';

class Si1TypeDefHistoricMetaCompat extends Si1TypeDef<String> {
  final String type;
  Si1TypeDefHistoricMetaCompat(this.type);
  @override
  Layout<String> layout({String? property}) =>
      SubstrateMetadataLayouts.type(property: property);

  @override
  String scaleJsonSerialize({String? property}) {
    return type;
  }

  @override
  Si1TypeDefsIndexesConst get typeName =>
      Si1TypeDefsIndexesConst.historicMetaCompat;

  /// Returns the serialization layout of the type definition using the provided [registry], [value], and optional [property].
  @override
  Layout typeDefLayout(PortableRegistry registry, value, {String? property}) {
    throw UnimplementedError();
  }

  /// Decodes the data based on the type definition using the provided [registry] and [bytes].
  @override
  LayoutDecodeResult typeDefDecode(PortableRegistry registry, List<int> bytes) {
    throw UnimplementedError();
  }

  /// Returns the type template using the provided [registry].
  @override
  TypeTemlate typeTemplate(PortableRegistry registry, int id) {
    throw UnimplementedError();
  }

  @override
  Object? getValue(
      {required PortableRegistry registry,
      required Object? value,
      required bool fromTemplate,
      required int self}) {
    throw UnimplementedError();
  }
}
