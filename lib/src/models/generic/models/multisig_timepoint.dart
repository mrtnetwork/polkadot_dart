//  interface PalletMultisigTimepoint extends Struct {
//       readonly height: u32;
//       readonly index: u32;
//   }

import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class MultisigTimepoint extends SubstrateSerialization<Map<String, dynamic>> {
  final int height;
  final int index;
  const MultisigTimepoint({required this.height, required this.index});
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return GenericLayouts.multisigTimepoint(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {"height": height, "index": index};
  }
}
