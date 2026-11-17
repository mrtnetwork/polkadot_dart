import 'package:blockchain_utils/blockchain_utils.dart' show BuBytes, BuError, DefaultErrorType;
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/encoding/layout/layout.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/models/fixed_bytes.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class SubstrateBaseAccountId<T> extends SubstrateSerialization<T> {
  String get name;
  BuBytes accountBytes();
}

class SubstrateAccount32 extends ScaleFixedBytes
    implements SubstrateBaseAccountId<List<int>> {
  SubstrateAccount32.fromHex(super.hex)
    : super.fromHex(lengthInBytes: SubstrateConstant.accountIdLengthInBytes);
  SubstrateAccount32(super.bytes)
    : super(lengthInBytes: SubstrateConstant.accountIdLengthInBytes);

  @override
  String get name => GenericConstants.address32IndexKey;

  @override
  BuBytes accountBytes() {
    return bytes.clone().asImmutableBytes;
  }
}

class SubstrateAccount20 extends ScaleFixedBytes
    implements SubstrateBaseAccountId<List<int>> {
  SubstrateAccount20.fromHex(super.hex)
    : super.fromHex(lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  SubstrateAccount20(super.bytes)
    : super(lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  SubstrateAccount20.deserializeJson(super.bytes)
    : super(lengthInBytes: SubstrateConstant.accountId20LengthInBytes);
  @override
  String get name => GenericConstants.address20IndexKey;
  @override
  BuBytes accountBytes() {
    return bytes.clone().asImmutableBytes;
  }
}

/// It's an account ID (pubkey).
class SubstrateAccountId extends SubstrateAccount32 {
  BuBytes get publicKey => bytes;
  SubstrateAccountId(super.publicKey);
  SubstrateAccountId.deserializeJson(super.bytes);
  @override
  String get name => GenericConstants.idIndexKey;
}

class SubstrateAccountIndex extends SubstrateBaseAccountId<int> {
  final int index;
  SubstrateAccountIndex(this.index);

  @override
  String get name => GenericConstants.indexIndexKey;
  static Layout<int> layout_({String? property}) {
    return LayoutConst.compactIntU32(property: property);
  }

  @override
  Layout<int> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  BuBytes accountBytes() {
    throw BuError(DefaultErrorType.invalidArgument, 
      "Cannot access account bytes from account index.",
    );
  }

  @override
  int serializeJson({String? property}) {
    return index;
  }
}

class SubstrateAccountRaw extends SubstrateBaseAccountId<List<int>> {
  final BuBytes bytes;
  SubstrateAccountRaw(List<int> bytes) : bytes = bytes.asImmutableBytes;

  @override
  String get name => GenericConstants.rawIndexKey;

  static Layout<List<int>> layout_({String? property}) {
    return LayoutConst.bytes(property: property);
  }

  @override
  Layout<List<int>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  BuBytes accountBytes() {
    return bytes.clone().asImmutableBytes;
  }

  @override
  BuBytes serializeJson({String? property}) {
    return bytes;
  }
}
