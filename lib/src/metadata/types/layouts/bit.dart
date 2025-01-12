import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/layout/byte/byte_handler.dart';

class SubstrateBitSequenceLayout extends Layout<List<int>> {
  const SubstrateBitSequenceLayout({String? property})
      : super(-1, property: property);
  static final _lengthCodec = LayoutConst.compactIntU48();

  @override
  SubstrateBitSequenceLayout clone({String? newProperty}) {
    return SubstrateBitSequenceLayout(property: property);
  }

  @override
  int getSpan(LayoutByteReader? bytes, {int offset = 0, List<int>? source}) {
    return bytes!.getCompactTotalLenght(offset).item2 ~/ 8;
  }

  @override
  LayoutDecodeResult<List<int>> decode(LayoutByteReader bytes,
      {int offset = 0}) {
    final decode = bytes.getCompactLengthInfos(offset);
    final totalLength = decode.item1 + IntUtils.bitlengthInBytes(decode.item2);
    final result = bytes.sublist(offset + decode.item1, offset + 2);
    return LayoutDecodeResult(consumed: totalLength, value: result);
  }

  @override
  int encode(List<int> source, LayoutByteWriter writer, {int offset = 0}) {
    final int length =
        _lengthCodec.encode(source.length * 8, writer, offset: offset);

    writer.setAll(offset + length, source);
    return source.length + length;
  }
}
