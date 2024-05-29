import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';
import 'account_id.dart';

class SubstrateMultiAddress
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBaseAccountId value;
  const SubstrateMultiAddress(this.value);

  factory SubstrateMultiAddress.deserializeJson(Map<String, dynamic> json) {
    final key = SubstrateEnumSerializationUtils.getScaleEnumKey(json, keys: [
      GenericConstants.idIndexKey,
      GenericConstants.address20IndexKey,
      GenericConstants.address32IndexKey,
      GenericConstants.rawIndexKey,
      GenericConstants.indexIndexKey
    ]);
    final SubstrateBaseAccountId account;
    switch (key) {
      case GenericConstants.idIndexKey:
        account = SubstrateAccountId.deserializeJson(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key));
        break;
      case GenericConstants.address32IndexKey:
        account = SubstrateAccount32(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key));
        break;
      case GenericConstants.address20IndexKey:
        account = SubstrateAccount20(
            SubstrateEnumSerializationUtils.getScaleEnumValue(json, key));
        break;
      default:
        throw UnimplementedError();
    }
    return SubstrateMultiAddress(account);
  }
  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      GenericLayouts.multiAddress(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {value.name: value.scaleJsonSerialize()};
  }
}
