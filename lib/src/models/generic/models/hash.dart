import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/models/fixed_bytes.dart';

class SubstrateHash256 extends ScaleFixedBytes {
  SubstrateHash256.fromHex(super.hex)
      : super.fromHex(lengthInBytes: SubstrateConstant.blockHashBytesLength);
  SubstrateHash256(super.hashBytes)
      : super(lengthInBytes: SubstrateConstant.blockHashBytesLength);
}
