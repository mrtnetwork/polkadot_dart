import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

import 'account_id.dart';

class SubstrateMultiAddress
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBaseAccountId value;
  const SubstrateMultiAddress(this.value);

  factory SubstrateMultiAddress.deserializeJson(Map<String, dynamic> json) {
    final key = json.keys.firstOrNull;
    final SubstrateBaseAccountId account;
    switch (key) {
      case GenericConstants.idIndexKey:
        account = SubstrateAccountId.deserializeJson(
            json.valueEnsureAsList<int>(key!));
        break;
      case GenericConstants.address32IndexKey:
        account = SubstrateAccount32(json.valueEnsureAsList<int>(key!));
        break;
      case GenericConstants.address20IndexKey:
        account = SubstrateAccount20(json.valueEnsureAsList<int>(key!));
        break;
      default:
        throw ItemNotFoundException();
    }
    return SubstrateMultiAddress(account);
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.fixedBlob32(property: GenericConstants.idIndexKey),
      SubstrateAccountIndex.layout_(property: GenericConstants.indexIndexKey),
      SubstrateAccountRaw.layout_(property: GenericConstants.rawIndexKey),
      LayoutConst.fixedBlob32(property: GenericConstants.address32IndexKey),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      layout_(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {value.name: value.serializeJson()};
  }
}
