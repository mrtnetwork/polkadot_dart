import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';
import 'package:polkadot_dart/src/models/generic/models/fixed_bytes.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class SubstrateBaseAccountId<T> extends SubstrateSerialization<T> {
  String get name;
}

class SubstrateAccount32 extends ScaleFixedBytes
    implements SubstrateBaseAccountId<List<int>> {
  SubstrateAccount32.fromHex(String hex)
      : super.fromHex(hex,
            lengthInBytes: SubstrateConstant.accountIdLengthInBytes);
  SubstrateAccount32(List<int> bytes)
      : super(bytes, lengthInBytes: SubstrateConstant.accountIdLengthInBytes);

  @override
  String get name => GenericConstants.address32IndexKey;
}

class SubstrateAccount20 extends ScaleFixedBytes
    implements SubstrateBaseAccountId<List<int>> {
  SubstrateAccount20.fromHex(String hex)
      : super.fromHex(hex,
            lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  SubstrateAccount20(List<int> bytes)
      : super(bytes, lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  SubstrateAccount20.deserializeJson(List<int> bytes)
      : super(bytes, lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  @override
  String get name => GenericConstants.address20IndexKey;
}

class SubstrateAccountId extends SubstrateAccount32 {
  final SubstrateAddress address;
  SubstrateAccountId(this.address) : super(address.toBytes());
  SubstrateAccountId.deserializeJson(List<int> bytes)
      : address = SubstrateAddress.fromBytes(bytes),
        super(bytes);
  @override
  String get name => GenericConstants.idIndexKey;
}

class SubstrateAccountIndex extends SubstrateBaseAccountId<int> {
  final int index;
  SubstrateAccountIndex(this.index);

  @override
  String get name => GenericConstants.indexIndexKey;

  @override
  Layout<int> layout({String? property}) {
    return GenericLayouts.accountIndex(property: property);
  }

  @override
  int scaleJsonSerialize({String? property}) {
    return index;
  }
}

class SubstrateAccountRaw extends SubstrateBaseAccountId<List<int>> {
  final List<int> bytes;
  SubstrateAccountRaw(List<int> bytes)
      : bytes = BytesUtils.toBytes(bytes, unmodifiable: true);

  @override
  String get name => GenericConstants.rawIndexKey;

  @override
  Layout<List<int>> layout({String? property}) {
    return GenericLayouts.accountRaw(property: property);
  }

  @override
  List<int> scaleJsonSerialize({String? property}) {
    return bytes;
  }
}
