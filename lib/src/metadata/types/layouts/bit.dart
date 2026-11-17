import 'package:blockchain_utils/blockchain_utils.dart';

class SubstrateBitSequenceLayout extends Layout<List<int>> {
  SubstrateBitSequenceLayout({super.property}) : super(-1);
  final _lengthCodec = LayoutConst.compactIntU48();

  @override
  SubstrateBitSequenceLayout clone({String? newProperty}) {
    return SubstrateBitSequenceLayout(property: property);
  }

  @override
  int getSpan() {
    return -1;
  }

  @override
  LayoutDecodeResult<List<int>> decode(
    LayoutByteReader bytes, {
    int offset = 0,
  }) {
    final decode = bytes.decodeScaleAsInteger(offset);
    final totalLength =
        decode.consumed + IntUtils.bitlengthInBytes(decode.value);
    final result = bytes.sublist(
      offset + decode.consumed,
      offset + totalLength,
    );
    return LayoutDecodeResult(consumed: totalLength, value: result);
  }

  @override
  int encode(List<int> source, LayoutByteWriter writer, {int offset = 0}) {
    final int length = _lengthCodec.encode(
      source.length * 8,
      writer,
      offset: offset,
    );

    writer.setAll(offset + length, source);
    return source.length + length;
  }
}
