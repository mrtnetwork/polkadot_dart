import 'dart:math' as math;

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/utils/casting_utils.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class _SubstrateEraConst {
  static const String immortal = "Immortal";
  static const String mortal = "Mortal";
  static const int maximumEraIndex = 255;
}

class _EraUtils {
  static int getTrailingZeros(int period) {
    int count = 0;
    while ((period & 1) == 0) {
      count++;
      period >>= 1;
    }
    return count;
  }

  static List<int> blockNumberToEra(int blockNumber,
      {int period = SubstrateConstant.defaultMortalLength}) {
    int calPeriod =
        math.pow(2, (math.log(period) / math.log(2)).ceil()).toInt();
    calPeriod = math.min(math.max(calPeriod, 4), 1 << 16);
    final phase = blockNumber % calPeriod;
    final encoded = math.min(15, math.max(1, getTrailingZeros(calPeriod) - 1)) +
        ((phase ~/ (math.max(calPeriod >> 12, 1)) << 4));
    final toBytes = [encoded & mask8, encoded >> 8];
    return toBytes;
  }

  static List<int> encodeEraPhase({required int phase, required int period}) {
    final encoded = math.min(15, math.max(1, getTrailingZeros(period) - 1)) +
        ((phase ~/ (math.max(period >> 12, 1)) << 4));
    final toBytes = [encoded & mask8, encoded >> 8];
    return toBytes;
  }
}

abstract class SubstrateBaseEra
    extends SubstrateSerialization<Map<String, dynamic>> {
  const SubstrateBaseEra();
  factory SubstrateBaseEra.deserializeJson(Map<String, dynamic> json) {
    final key = json.keys.firstOrNull;
    if (key == _SubstrateEraConst.immortal) return ImmortalEra();
    final eraIndex =
        int.tryParse(key?.replaceFirst(_SubstrateEraConst.mortal, '') ?? '');
    if (eraIndex == null || eraIndex > 255 || eraIndex < 0) {
      throw DartSubstratePluginException("Invalid provided era json.",
          details: {"value": key});
    }
    return MortalEra(index: eraIndex, era: json.valueAs(key!));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.none(property: "Immortal"),
      ...List.generate(
          255, (index) => LayoutConst.u8(property: "Mortal${index + 1}"))
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class ImmortalEra extends SubstrateBaseEra {
  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {_SubstrateEraConst.immortal: null};
  }
}

class MortalEra extends SubstrateBaseEra {
  final int index;
  final int era;
  MortalEra({required int index, required int era})
      : index = MetadataCastingUtils.validateU8(index,
            max: _SubstrateEraConst.maximumEraIndex),
        era = MetadataCastingUtils.validateU8(era);
  factory MortalEra.fromPhase({required int period, required int phase}) {
    final encode = _EraUtils.encodeEraPhase(phase: phase, period: period);
    return MortalEra(index: encode[0], era: encode[1]);
  }
  factory MortalEra.fromBlockNumber(
      {required int blockNumber,
      int period = SubstrateConstant.defaultMortalLength}) {
    final encode = _EraUtils.blockNumberToEra(blockNumber, period: period);
    return MortalEra(index: encode[0], era: encode[1]);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"${_SubstrateEraConst.mortal}$index": era};
  }

  @override
  String toString() {
    return "${_SubstrateEraConst.mortal}$index ($era)";
  }
}
