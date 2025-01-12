import 'dart:typed_data';

import 'package:blockchain_utils/blockchain_utils.dart';

class SubstrateSerializationUtils {
  static Tuple<int, BigInt> decodeLength(
      {required List<int> bytes, required int offset, bool sign = false}) {
    final int byte = bytes[offset];
    switch (byte & 0x03) {
      case 0x00:
        return Tuple(1, BigInt.from(byte) >> 2);
      case 0x01:
        final val = BigintUtils.fromBytes(bytes.sublist(offset, offset + 2),
            sign: sign, byteOrder: Endian.little);
        return Tuple(2, val >> 2);
      case 0x02:
        final val = BigintUtils.fromBytes(bytes.sublist(offset, offset + 4),
            sign: sign, byteOrder: Endian.little);
        return Tuple(4, val >> 2);
      default:
        final int o = (byte >> 2) + 5;
        final val = BigintUtils.fromBytes(bytes.sublist(offset + 1, offset + o),
            sign: sign, byteOrder: Endian.little);
        return Tuple(o, val);
    }
  }
}
