import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/models/fixed_bytes.dart';

class SubstrateHash256 extends ScaleFixedBytes {
  SubstrateHash256.fromHex(String hex)
      : super.fromHex(hex,
            lengthInBytes: SubstrateConstant.blockHashBytesLength);
  SubstrateHash256(List<int> hashBytes)
      : super(hashBytes, lengthInBytes: SubstrateConstant.blockHashBytesLength);
}
