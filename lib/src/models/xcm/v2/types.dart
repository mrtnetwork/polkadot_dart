import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/xcm/core/asset.dart';
import 'package:polkadot_dart/src/models/xcm/core/body.dart';
import 'package:polkadot_dart/src/models/xcm/core/fungibility.dart';
import 'package:polkadot_dart/src/models/xcm/core/junction.dart';
import 'package:polkadot_dart/src/models/xcm/core/location.dart';
import 'package:polkadot_dart/src/models/xcm/core/network_id.dart';
import 'package:polkadot_dart/src/models/xcm/core/versioned.dart';
import 'package:polkadot_dart/src/models/xcm/v3/types.dart';
import 'package:polkadot_dart/src/models/xcm/v4/types.dart';
import 'package:polkadot_dart/src/models/xcm/v5/types.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class XCMV2NetworkId extends SubstrateVariantSerialization
    with XCMNetworkId, Equality {
  const XCMV2NetworkId();

  factory XCMV2NetworkId.from(XCMNetworkId? network) {
    if (network is XCMV2NetworkId) return network;
    final type = network?.type;
    return switch (type) {
      null => XCMV2Any(),
      XCMNetworkIdType.polkadot => XCMV2Polkadot(),
      XCMNetworkIdType.kusama => XCMV2Kusama(),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 2.")
    };
  }

  factory XCMV2NetworkId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMNetworkIdType.fromName(decode.variantName);
    return switch (type) {
      XCMNetworkIdType.any => XCMV2Any.deserializeJson(decode.value),
      XCMNetworkIdType.named => XCMV2Named.deserializeJson(decode.value),
      XCMNetworkIdType.polkadot => XCMV2Polkadot.deserializeJson(decode.value),
      XCMNetworkIdType.kusama => XCMV2Kusama.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 2.")
    };
  }
  factory XCMV2NetworkId.fromJson(Map<String, dynamic> json) {
    final type = XCMNetworkIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMNetworkIdType.any => XCMV2Any.fromJson(json),
      XCMNetworkIdType.named => XCMV2Named.fromJson(json),
      XCMNetworkIdType.polkadot => XCMV2Polkadot.fromJson(json),
      XCMNetworkIdType.kusama => XCMV2Kusama.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsuported network id by version 2.")
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdAny.layout_(property: property),
        property: XCMNetworkIdType.any.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdNamed.layout_(property: property),
        property: XCMNetworkIdType.named.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMNetworkIdPolkadot.layout_(property: property),
        property: XCMNetworkIdType.polkadot.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMNetworkIdKusama.layout_(property: property),
        property: XCMNetworkIdType.kusama.name,
        index: 3,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2Any extends XCMV2NetworkId with XCMNetworkIdAny {
  const XCMV2Any();
  XCMV2Any.deserializeJson(Map<String, dynamic> json);
  factory XCMV2Any.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.any.type);
    return XCMV2Any();
  }
}

class XCMV2Named extends XCMV2NetworkId with XCMNetworkIdNamed {
  @override
  final List<int> name;
  XCMV2Named({required List<int> name})
      : name =
            name.max(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;
  factory XCMV2Named.fromJson(Map<String, dynamic> json) {
    return XCMV2Named(name: json.valueAsBytes(XCMNetworkIdType.named.type));
  }
  factory XCMV2Named.deserializeJson(Map<String, dynamic> json) {
    return XCMV2Named(name: (json["name"] as List).cast());
  }
}

class XCMV2Polkadot extends XCMV2NetworkId with XCMNetworkIdPolkadot {
  XCMV2Polkadot();
  XCMV2Polkadot.deserializeJson(Map<String, dynamic> json);
  factory XCMV2Polkadot.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.polkadot.type);
    return XCMV2Polkadot();
  }
}

class XCMV2Kusama extends XCMV2NetworkId with XCMNetworkIdKusama {
  XCMV2Kusama();
  XCMV2Kusama.deserializeJson(Map<String, dynamic> json);
  factory XCMV2Kusama.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMNetworkIdType.kusama.type);
    return XCMV2Kusama();
  }
}

abstract class XCMV2BodyId extends SubstrateVariantSerialization
    with XCMBodyId, Equality {
  const XCMV2BodyId();
  factory XCMV2BodyId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMBodyIdType.fromName(decode.variantName);
    return switch (type) {
      XCMBodyIdType.unit => XCMV2BodyIdUnit.deserializeJson(decode.value),
      XCMBodyIdType.named => XCMV2BodyIdNamed.deserializeJson(decode.value),
      XCMBodyIdType.indexId => XCMV2BodyIdIndex.deserializeJson(decode.value),
      XCMBodyIdType.executive =>
        XCMV2BodyIdExecutive.deserializeJson(decode.value),
      XCMBodyIdType.technical =>
        XCMV2BodyIdTechnical.deserializeJson(decode.value),
      XCMBodyIdType.legislative =>
        XCMV2BodyIdLegislative.deserializeJson(decode.value),
      XCMBodyIdType.judical => XCMV2BodyIdJudical.deserializeJson(decode.value),
      XCMBodyIdType.defense => XCMV2BodyIdDefense.deserializeJson(decode.value),
      XCMBodyIdType.administration =>
        XCMV2BodyIdAdministration.deserializeJson(decode.value),
      XCMBodyIdType.treasury =>
        XCMV2BodyIdTreasury.deserializeJson(decode.value),
      _ =>
        throw DartSubstratePluginException("Unsuported body id by version 2.")
    };
  }
  factory XCMV2BodyId.fromJson(Map<String, dynamic> json) {
    final type = XCMBodyIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMBodyIdType.unit => XCMV2BodyIdUnit.fromJson(json),
      XCMBodyIdType.named => XCMV2BodyIdNamed.fromJson(json),
      XCMBodyIdType.indexId => XCMV2BodyIdIndex.fromJson(json),
      XCMBodyIdType.executive => XCMV2BodyIdExecutive.fromJson(json),
      XCMBodyIdType.technical => XCMV2BodyIdTechnical.fromJson(json),
      XCMBodyIdType.legislative => XCMV2BodyIdLegislative.fromJson(json),
      XCMBodyIdType.judical => XCMV2BodyIdJudical.fromJson(json),
      XCMBodyIdType.defense => XCMV2BodyIdDefense.fromJson(json),
      XCMBodyIdType.administration => XCMV2BodyIdAdministration.fromJson(json),
      XCMBodyIdType.treasury => XCMV2BodyIdTreasury.fromJson(json),
      _ =>
        throw DartSubstratePluginException("Unsuported body id by version 2.")
    };
  }

  factory XCMV2BodyId.from(XCMBodyId body) {
    if (body is XCMV2BodyId) return body;
    final type = body.type;
    return switch (type) {
      XCMBodyIdType.unit => XCMV2BodyIdUnit(),
      XCMBodyIdType.named =>
        XCMV2BodyIdNamed(name: (body as XCMBodyIdNamed).name),
      XCMBodyIdType.indexId =>
        XCMV2BodyIdIndex(index: (body as XCMBodyIdIndex).index),
      XCMBodyIdType.executive => XCMV2BodyIdExecutive(),
      XCMBodyIdType.technical => XCMV2BodyIdTechnical(),
      XCMBodyIdType.legislative => XCMV2BodyIdLegislative(),
      XCMBodyIdType.judical => XCMV2BodyIdJudical(),
      XCMBodyIdType.defense => XCMV2BodyIdDefense(),
      XCMBodyIdType.administration => XCMV2BodyIdAdministration(),
      XCMBodyIdType.treasury => XCMV2BodyIdTreasury(),
      _ =>
        throw DartSubstratePluginException("Unsuported body id by version 2.")
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdUnit.layout_(property: property),
        property: XCMBodyIdType.unit.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdNamed.layout_(property: property),
        property: XCMBodyIdType.named.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdIndex.layout_(property: property),
        property: XCMBodyIdType.indexId.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdExecutive.layout_(property: property),
        property: XCMBodyIdType.executive.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdTechnical.layout_(property: property),
        property: XCMBodyIdType.technical.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyIdLegislative.layout_(property: property),
        property: XCMBodyIdType.legislative.name,
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdJudical.layout_(property: property),
        property: XCMBodyIdType.judical.name,
        index: 6,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdDefense.layout_(property: property),
        property: XCMBodyIdType.defense.name,
        index: 7,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyIdAdministration.layout_(property: property),
        property: XCMBodyIdType.administration.name,
        index: 8,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyIdTreasury.layout_(property: property),
        property: XCMBodyIdType.treasury.name,
        index: 9,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2BodyIdNamed extends XCMV2BodyId with XCMBodyIdNamed {
  @override
  final List<int> name;
  XCMV2BodyIdNamed({required List<int> name}) : name = name.asImmutableBytes;

  factory XCMV2BodyIdNamed.deserializeJson(Map<String, dynamic> json) {
    return XCMV2BodyIdNamed(name: (json["name"] as List).cast());
  }
  factory XCMV2BodyIdNamed.fromJson(Map<String, dynamic> json) {
    return XCMV2BodyIdNamed(name: json.valueAsBytes(XCMBodyIdType.named.type));
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: name};
  }
}

class XCMV2BodyIdUnit extends XCMV2BodyId with XCMBodyIdUnit {
  XCMV2BodyIdUnit();

  XCMV2BodyIdUnit.deserializeJson(Map<String, dynamic> json);
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }

  factory XCMV2BodyIdUnit.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.unit.type);
    return XCMV2BodyIdUnit();
  }
}

class XCMV2BodyIdIndex extends XCMV2BodyId with XCMBodyIdIndex {
  @override
  final int index;
  XCMV2BodyIdIndex({required int index}) : index = index.asUint32;

  factory XCMV2BodyIdIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV2BodyIdIndex(
      index: IntUtils.parse(json["index"]),
    );
  }
  factory XCMV2BodyIdIndex.fromJson(Map<String, dynamic> json) {
    return XCMV2BodyIdIndex(index: json.valueAs(XCMBodyIdType.indexId.type));
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: index};
  }
}

class XCMV2BodyIdExecutive extends XCMV2BodyId with XCMBodyIdExecutive {
  XCMV2BodyIdExecutive();
  XCMV2BodyIdExecutive.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdExecutive.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.executive.type);
    return XCMV2BodyIdExecutive();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdTechnical extends XCMV2BodyId with XCMBodyIdTechnical {
  XCMV2BodyIdTechnical();
  XCMV2BodyIdTechnical.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdTechnical.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.technical.type);
    return XCMV2BodyIdTechnical();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdLegislative extends XCMV2BodyId with XCMBodyIdLegislative {
  XCMV2BodyIdLegislative();
  XCMV2BodyIdLegislative.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdLegislative.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.legislative.type);
    return XCMV2BodyIdLegislative();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdJudical extends XCMV2BodyId with XCMBodyIdJudical {
  XCMV2BodyIdJudical();
  XCMV2BodyIdJudical.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdJudical.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.judical.type);
    return XCMV2BodyIdJudical();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdDefense extends XCMV2BodyId with XCMBodyIdDefense {
  XCMV2BodyIdDefense();
  XCMV2BodyIdDefense.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdDefense.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.defense.type);
    return XCMV2BodyIdDefense();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdAdministration extends XCMV2BodyId
    with XCMBodyIdAdministration {
  XCMV2BodyIdAdministration();
  XCMV2BodyIdAdministration.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdAdministration.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.administration.type);
    return XCMV2BodyIdAdministration();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2BodyIdTreasury extends XCMV2BodyId with XCMBodyIdTreasury {
  XCMV2BodyIdTreasury();
  XCMV2BodyIdTreasury.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyIdTreasury.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyIdType.treasury.type);
    return XCMV2BodyIdTreasury();
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

abstract class XCMV2BodyPart extends SubstrateVariantSerialization
    with XCMBodyPart, Equality {
  bool get isMajority => false;
  const XCMV2BodyPart();
  factory XCMV2BodyPart.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMBodyPartType.fromName(decode.variantName);
    return switch (type) {
      XCMBodyPartType.voice => XCMV2BodyPartVoice.deserializeJson(decode.value),
      XCMBodyPartType.members =>
        XCMV2BodyPartMembers.deserializeJson(decode.value),
      XCMBodyPartType.fraction =>
        XCMV2BodyPartFraction.deserializeJson(decode.value),
      XCMBodyPartType.atLeastProportion =>
        XCMV2BodyPartAtLeastProportion.deserializeJson(decode.value),
      XCMBodyPartType.moreThanProportion =>
        XCMV2BodyPartMoreThanProportion.deserializeJson(decode.value)
    };
  }
  factory XCMV2BodyPart.fromJson(Map<String, dynamic> json) {
    final type = XCMBodyPartType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMBodyPartType.voice => XCMV2BodyPartVoice.fromJson(json),
      XCMBodyPartType.members => XCMV2BodyPartMembers.fromJson(json),
      XCMBodyPartType.fraction => XCMV2BodyPartFraction.fromJson(json),
      XCMBodyPartType.atLeastProportion =>
        XCMV2BodyPartAtLeastProportion.fromJson(json),
      XCMBodyPartType.moreThanProportion =>
        XCMV2BodyPartMoreThanProportion.fromJson(json)
    };
  }

  factory XCMV2BodyPart.from(XCMBodyPart body) {
    if (body is XCMV2BodyPart) return body;
    final type = body.type;
    return switch (type) {
      XCMBodyPartType.voice => XCMV2BodyPartVoice(),
      XCMBodyPartType.members =>
        XCMV2BodyPartMembers(count: (body as XCMBodyPartMembers).count),
      XCMBodyPartType.fraction => () {
          final fraction = body as XCMBodyPartFraction;
          return XCMV2BodyPartFraction(
              denom: fraction.denom, nom: fraction.nom);
        }(),
      XCMBodyPartType.atLeastProportion => () {
          final fraction = body as XCMBodyPartAtLeastProportion;
          return XCMV2BodyPartAtLeastProportion(
              denom: fraction.denom, nom: fraction.nom);
        }(),
      XCMBodyPartType.moreThanProportion => () {
          final fraction = body as XCMBodyPartMoreThanProportion;
          return XCMV2BodyPartMoreThanProportion(
              denom: fraction.denom, nom: fraction.nom);
        }(),
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartVoice.layout_(property: property),
        property: XCMBodyPartType.voice.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartMembers.layout_(property: property),
        property: XCMBodyPartType.members.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) => XCMBodyPartFraction.layout_(property: property),
        property: XCMBodyPartType.fraction.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyPartAtLeastProportion.layout_(property: property),
        property: XCMBodyPartType.atLeastProportion.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMBodyPartMoreThanProportion.layout_(property: property),
        property: XCMBodyPartType.moreThanProportion.name,
        index: 4,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2BodyPartMembers extends XCMV2BodyPart with XCMBodyPartMembers {
  @override
  final int count;
  XCMV2BodyPartMembers({required int count}) : count = count.asUint32;

  factory XCMV2BodyPartMembers.deserializeJson(Map<String, dynamic> json) {
    return XCMV2BodyPartMembers(
      count: IntUtils.parse(json["count"]),
    );
  }
  factory XCMV2BodyPartMembers.fromJson(Map<String, dynamic> json) {
    final int count = json.valueAs(XCMBodyPartType.members.type);
    return XCMV2BodyPartMembers(count: count);
  }
}

class XCMV2BodyPartVoice extends XCMV2BodyPart with XCMBodyPartVoice {
  XCMV2BodyPartVoice();
  XCMV2BodyPartVoice.deserializeJson(Map<String, dynamic> json);
  factory XCMV2BodyPartVoice.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMBodyPartType.voice.type);
    return XCMV2BodyPartVoice();
  }
}

class XCMV2BodyPartFraction extends XCMV2BodyPart with XCMBodyPartFraction {
  @override
  final int nom;
  @override
  final int denom;
  @override
  bool get isMajority => nom * 2 > denom;
  XCMV2BodyPartFraction({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;
  factory XCMV2BodyPartFraction.fromJson(Map<String, dynamic> json) {
    final fraction =
        json.valueEnsureAsMap<String, dynamic>(XCMBodyPartType.fraction.type);
    return XCMV2BodyPartFraction(
        denom: fraction.valueAs("denom"), nom: fraction.valueAs("nom"));
  }
  XCMV2BodyPartFraction.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);
}

class XCMV2BodyPartAtLeastProportion extends XCMV2BodyPart
    with XCMBodyPartAtLeastProportion {
  @override
  bool get isMajority => nom * 2 > denom;
  @override
  final int nom;
  @override
  final int denom;

  XCMV2BodyPartAtLeastProportion({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;

  XCMV2BodyPartAtLeastProportion.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);

  factory XCMV2BodyPartAtLeastProportion.fromJson(Map<String, dynamic> json) {
    final atLeastProportion = json.valueEnsureAsMap<String, dynamic>(
        XCMBodyPartType.atLeastProportion.type);
    return XCMV2BodyPartAtLeastProportion(
        denom: atLeastProportion.valueAs("denom"),
        nom: atLeastProportion.valueAs("nom"));
  }
}

class XCMV2BodyPartMoreThanProportion extends XCMV2BodyPart
    with XCMBodyPartMoreThanProportion {
  @override
  bool get isMajority => nom * 2 >= denom;
  @override
  final int nom;
  @override
  final int denom;

  XCMV2BodyPartMoreThanProportion({required int nom, required int denom})
      : nom = nom.asUint32,
        denom = denom.asUint32;

  XCMV2BodyPartMoreThanProportion.deserializeJson(Map<String, dynamic> json)
      : nom = IntUtils.parse(json["nom"]),
        denom = IntUtils.parse(json["denom"]);

  factory XCMV2BodyPartMoreThanProportion.fromJson(Map<String, dynamic> json) {
    final moreThanProportion = json.valueEnsureAsMap<String, dynamic>(
        XCMBodyPartType.moreThanProportion.type);
    return XCMV2BodyPartMoreThanProportion(
        denom: moreThanProportion.valueAs("denom"),
        nom: moreThanProportion.valueAs("nom"));
  }
}

abstract class XCMV2Junction extends SubstrateVariantSerialization
    with XCMJunction, Equality {
  const XCMV2Junction();
  factory XCMV2Junction.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV2JunctionParaChain.deserializeJson(decode.value),
      XCMJunctionType.accountId32 =>
        XCMV2JunctionAccountId32.deserializeJson(decode.value),
      XCMJunctionType.accountIndex64 =>
        XCMV2JunctionAccountIndex64.deserializeJson(decode.value),
      XCMJunctionType.accountKey20 =>
        XCMV2JunctionAccountKey20.deserializeJson(decode.value),
      XCMJunctionType.palletInstance =>
        XCMV2JunctionPalletInstance.deserializeJson(decode.value),
      XCMJunctionType.generalIndex =>
        XCMV2JunctionGeneralIndex.deserializeJson(decode.value),
      XCMJunctionType.generalKey =>
        XCMV2JunctionGeneralKey.deserializeJson(decode.value),
      XCMJunctionType.onlyChild =>
        XCMV2JunctionOnlyChild.deserializeJson(decode.value),
      XCMJunctionType.plurality =>
        XCMV2JunctionPlurality.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException("Unsuported V2 Junction type.")
    };
  }
  factory XCMV2Junction.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionType.parachain => XCMV2JunctionParaChain.fromJson(json),
      XCMJunctionType.accountId32 => XCMV2JunctionAccountId32.fromJson(json),
      XCMJunctionType.accountIndex64 =>
        XCMV2JunctionAccountIndex64.fromJson(json),
      XCMJunctionType.accountKey20 => XCMV2JunctionAccountKey20.fromJson(json),
      XCMJunctionType.palletInstance =>
        XCMV2JunctionPalletInstance.fromJson(json),
      XCMJunctionType.generalIndex => XCMV2JunctionGeneralIndex.fromJson(json),
      XCMJunctionType.generalKey => XCMV2JunctionGeneralKey.fromJson(json),
      XCMJunctionType.onlyChild => XCMV2JunctionOnlyChild.fromJson(json),
      XCMJunctionType.plurality => XCMV2JunctionPlurality.fromJson(json),
      _ => throw DartSubstratePluginException("Unsuported V2 Junction type.")
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionParaChain.layout_(property: property),
        property: XCMJunctionType.parachain.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionAccountId32.layout_(property: property),
        property: XCMJunctionType.accountId32.name,
        index: 1,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionAccountIndex64.layout_(property: property),
        property: XCMJunctionType.accountIndex64.name,
        index: 2,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionAccountKey20.layout_(property: property),
        property: XCMJunctionType.accountKey20.name,
        index: 3,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionPalletInstance.layout_(property: property),
        property: XCMJunctionType.palletInstance.name,
        index: 4,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionGeneralIndex.layout_(property: property),
        property: XCMJunctionType.generalIndex.name,
        index: 5,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionGeneralKey.layout_(property: property),
        property: XCMJunctionType.generalKey.name,
        index: 6,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMJunctionOnlyChild.layout_(property: property),
        property: XCMJunctionType.onlyChild.name,
        index: 7,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2JunctionPlurality.layout_(property: property),
        property: XCMJunctionType.plurality.name,
        index: 8,
      ),
    ], property: property);
  }

  factory XCMV2Junction.from(XCMJunction junction) {
    if (junction is XCMV2Junction) return junction;
    final type = junction.type;
    return switch (type) {
      XCMJunctionType.parachain =>
        XCMV2JunctionParaChain(id: (junction as XCMJunctionParaChain).id),
      XCMJunctionType.accountId32 => () {
          final account32 = junction as XCMJunctionAccountId32;
          return XCMV2JunctionAccountId32(
              id: account32.id,
              network: XCMV2NetworkId.from(account32.network));
        }(),
      XCMJunctionType.accountIndex64 => () {
          final account = junction as XCMJunctionAccountIndex64;
          return XCMV2JunctionAccountIndex64(
              index: account.index,
              network: XCMV2NetworkId.from(account.network));
        }(),
      XCMJunctionType.accountKey20 => () {
          final account = junction as XCMJunctionAccountKey20;
          return XCMV2JunctionAccountKey20(
              key: account.key, network: XCMV2NetworkId.from(account.network));
        }(),
      XCMJunctionType.palletInstance => XCMV2JunctionPalletInstance(
          index: (junction as XCMJunctionPalletInstance).index),
      XCMJunctionType.generalIndex => XCMV2JunctionGeneralIndex(
          index: (junction as XCMJunctionGeneralIndex).index),
      XCMJunctionType.generalKey => () {
          final account = junction as XCMJunctionGeneralKey;
          return XCMV2JunctionGeneralKey(
              data: account.data.sublist(account.length),
              length: account.length);
        }(),
      XCMJunctionType.onlyChild => XCMV2JunctionOnlyChild(),
      XCMJunctionType.plurality => () {
          final plurality = junction as XCMJunctionPlurality;
          return XCMV2JunctionPlurality(
              id: XCMV2BodyId.from(plurality.id),
              part: XCMV2BodyPart.from(plurality.part));
        }(),
      _ => throw DartSubstratePluginException(
          "Unsuported junction by version 2.",
          details: {"type": junction.type})
    };
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2JunctionParaChain extends XCMV2Junction with XCMJunctionParaChain {
  @override
  final int id;
  XCMV2JunctionParaChain({required int id}) : id = id.asUint32;

  factory XCMV2JunctionParaChain.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionParaChain(id: IntUtils.parse(json["id"]));
  }
  factory XCMV2JunctionParaChain.fromJson(Map<String, dynamic> json) {
    return XCMV2JunctionParaChain(
        id: json.valueAs(XCMJunctionType.parachain.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.compactIntU32(property: "id")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id};
  }
}

class XCMV2JunctionAccountId32 extends XCMV2Junction
    with XCMJunctionAccountId32 {
  @override
  final XCMV2NetworkId network;
  @override
  final List<int> id;
  XCMV2JunctionAccountId32({required this.network, required List<int> id})
      : id = id.exc(SubstrateConstant.accountIdLengthInBytes).asImmutableBytes;

  factory XCMV2JunctionAccountId32.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionAccountId32(
        network: XCMV2NetworkId.deserializeJson(json["network"]),
        id: (json["id"] as List).cast());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2NetworkId.layout_(property: "network"),
      LayoutConst.fixedBlob32(property: "id")
    ], property: property);
  }

  factory XCMV2JunctionAccountId32.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountId32.type);
    return XCMV2JunctionAccountId32(
        network: XCMV2NetworkId.fromJson(
            accountId.valueEnsureAsMap<String, dynamic>("network")),
        id: accountId.valueAsBytes("id"));
  }
  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"network": network.toJson(), "id": id}
    };
  }
}

class XCMV2JunctionAccountIndex64 extends XCMV2Junction
    with XCMJunctionAccountIndex64 {
  @override
  final XCMV2NetworkId network;
  @override
  final BigInt index;
  XCMV2JunctionAccountIndex64({required this.network, required BigInt index})
      : index = index.asUint64;

  factory XCMV2JunctionAccountIndex64.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2JunctionAccountIndex64(
        network: XCMV2NetworkId.deserializeJson(json["network"]),
        index: BigintUtils.parse(json["index"]));
  }

  factory XCMV2JunctionAccountIndex64.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountIndex64.type);
    return XCMV2JunctionAccountIndex64(
        network: XCMV2NetworkId.fromJson(
            accountId.valueEnsureAsMap<String, dynamic>("network")),
        index: accountId.valueAs("index"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2NetworkId.layout_(property: "network"),
      LayoutConst.compactBigintU64(property: "index")
    ], property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"network": network.toJson(), "index": index}
    };
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

class XCMV2JunctionAccountKey20 extends XCMV2Junction
    with XCMJunctionAccountKey20 {
  @override
  final XCMV2NetworkId network;
  @override
  final List<int> key;
  XCMV2JunctionAccountKey20({required this.network, required List<int> key})
      : key = key
            .exc(SubstrateConstant.accountId20LengthInBytes)
            .asImmutableBytes;

  factory XCMV2JunctionAccountKey20.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionAccountKey20(
        network: XCMV2NetworkId.deserializeJson(json["network"]),
        key: (json["key"] as List).cast());
  }
  factory XCMV2JunctionAccountKey20.fromJson(Map<String, dynamic> json) {
    final accountId = json
        .valueEnsureAsMap<String, dynamic>(XCMJunctionType.accountKey20.type);
    return XCMV2JunctionAccountKey20(
        network: XCMV2NetworkId.fromJson(
            accountId.valueEnsureAsMap<String, dynamic>("network")),
        key: accountId.valueAsBytes("key"));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2NetworkId.layout_(property: "network"),
      LayoutConst.fixedBlobN(SubstrateConstant.accountId20LengthInBytes,
          property: "key")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      type.type: {"network": network.toJson(), "key": key}
    };
  }
}

class XCMV2JunctionPalletInstance extends XCMV2Junction
    with XCMJunctionPalletInstance {
  @override
  final int index;
  XCMV2JunctionPalletInstance({required int index}) : index = index.asUint8;

  factory XCMV2JunctionPalletInstance.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2JunctionPalletInstance(index: IntUtils.parse(json["index"]));
  }
  factory XCMV2JunctionPalletInstance.fromJson(Map<String, dynamic> json) {
    return XCMV2JunctionPalletInstance(
        index: json.valueAs(XCMJunctionType.palletInstance.type));
  }
}

class XCMV2JunctionGeneralIndex extends XCMV2Junction
    with XCMJunctionGeneralIndex {
  @override
  final BigInt index;
  XCMV2JunctionGeneralIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV2JunctionGeneralIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionGeneralIndex(index: BigintUtils.parse(json["index"]));
  }
  factory XCMV2JunctionGeneralIndex.fromJson(Map<String, dynamic> json) {
    return XCMV2JunctionGeneralIndex(
        index: json.valueAs(XCMJunctionType.generalIndex.type));
  }
}

class XCMV2JunctionGeneralKey extends XCMV2Junction with XCMJunctionGeneralKey {
  @override
  final List<int> data;
  @override
  final int length;
  XCMV2JunctionGeneralKey({required List<int> data, required this.length})
      : data = data.asImmutableBytes;

  factory XCMV2JunctionGeneralKey.deserializeJson(Map<String, dynamic> json) {
    final data = (json["data"] as List).cast<int>();
    return XCMV2JunctionGeneralKey(data: data, length: data.length);
  }
  factory XCMV2JunctionGeneralKey.fromJson(Map<String, dynamic> json) {
    final key = json.valueAsBytes<List<int>>(XCMJunctionType.generalKey.type);
    return XCMV2JunctionGeneralKey(length: key.length, data: key);
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.bytes(property: "data")],
        property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"data": data};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: data};
  }
}

class XCMV2JunctionOnlyChild extends XCMV2Junction with XCMJunctionOnlyChild {
  XCMV2JunctionOnlyChild();

  factory XCMV2JunctionOnlyChild.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionOnlyChild();
  }
  factory XCMV2JunctionOnlyChild.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionType.onlyChild.type);
    return XCMV2JunctionOnlyChild();
  }
}

class XCMV2JunctionPlurality extends XCMV2Junction with XCMJunctionPlurality {
  @override
  final XCMV2BodyId id;
  @override
  final XCMV2BodyPart part;
  XCMV2JunctionPlurality({required this.id, required this.part});

  factory XCMV2JunctionPlurality.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionPlurality(
        id: XCMV2BodyId.deserializeJson(json["id"]),
        part: XCMV2BodyPart.deserializeJson(json["part"]));
  }
  factory XCMV2JunctionPlurality.fromJson(Map<String, dynamic> json) {
    final plurality =
        json.valueEnsureAsMap<String, dynamic>(XCMJunctionType.plurality.type);
    return XCMV2JunctionPlurality(
        id: XCMV2BodyId.fromJson(plurality.valueAs("id")),
        part: XCMV2BodyPart.fromJson(plurality.valueAs("part")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2BodyId.layout_(property: "id"),
      XCMV2BodyPart.layout_(property: "part")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

typedef XCMV2InteriorMultiLocation = XCMV2Junctions;

abstract class XCMV2Junctions extends XCMJunctions<XCMV2Junction> {
  XCMV2Junctions({required super.type, required super.junctions});
  factory XCMV2Junctions.fromJunctions(List<XCMV2Junction> junctions) {
    final type = XCMJunctionsType.fromLength(junctions.length);
    return switch (type) {
      XCMJunctionsType.here => XCMV2JunctionsHere(),
      XCMJunctionsType.x1 => XCMV2JunctionsX1(junctions: junctions),
      XCMJunctionsType.x2 => XCMV2JunctionsX2(junctions: junctions),
      XCMJunctionsType.x3 => XCMV2JunctionsX3(junctions: junctions),
      XCMJunctionsType.x4 => XCMV2JunctionsX4(junctions: junctions),
      XCMJunctionsType.x5 => XCMV2JunctionsX5(junctions: junctions),
      XCMJunctionsType.x6 => XCMV2JunctionsX6(junctions: junctions),
      XCMJunctionsType.x7 => XCMV2JunctionsX7(junctions: junctions),
      XCMJunctionsType.x8 => XCMV2JunctionsX8(junctions: junctions),
    };
  }
  factory XCMV2Junctions.from(XCMJunctions junctions) {
    if (junctions is XCMV2Junctions) return junctions;
    final type = junctions.type;
    final vJunctions =
        junctions.junctions.map((e) => XCMV2Junction.from(e)).toList();
    return switch (type) {
      XCMJunctionsType.here => XCMV2JunctionsHere(),
      XCMJunctionsType.x1 => XCMV2JunctionsX1(junctions: vJunctions),
      XCMJunctionsType.x2 => XCMV2JunctionsX2(junctions: vJunctions),
      XCMJunctionsType.x3 => XCMV2JunctionsX3(junctions: vJunctions),
      XCMJunctionsType.x4 => XCMV2JunctionsX4(junctions: vJunctions),
      XCMJunctionsType.x5 => XCMV2JunctionsX5(junctions: vJunctions),
      XCMJunctionsType.x6 => XCMV2JunctionsX6(junctions: vJunctions),
      XCMJunctionsType.x7 => XCMV2JunctionsX7(junctions: vJunctions),
      XCMJunctionsType.x8 => XCMV2JunctionsX8(junctions: vJunctions),
    };
  }
  factory XCMV2Junctions.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMJunctionsType.fromName(decode.variantName);
    return switch (type) {
      XCMJunctionsType.here => XCMV2JunctionsHere.deserializeJson(decode.value),
      XCMJunctionsType.x1 => XCMV2JunctionsX1.deserializeJson(decode.value),
      XCMJunctionsType.x2 => XCMV2JunctionsX2.deserializeJson(decode.value),
      XCMJunctionsType.x3 => XCMV2JunctionsX3.deserializeJson(decode.value),
      XCMJunctionsType.x4 => XCMV2JunctionsX4.deserializeJson(decode.value),
      XCMJunctionsType.x5 => XCMV2JunctionsX5.deserializeJson(decode.value),
      XCMJunctionsType.x6 => XCMV2JunctionsX6.deserializeJson(decode.value),
      XCMJunctionsType.x7 => XCMV2JunctionsX7.deserializeJson(decode.value),
      XCMJunctionsType.x8 => XCMV2JunctionsX8.deserializeJson(decode.value),
    };
  }
  factory XCMV2Junctions.fromJson(Map<String, dynamic> json) {
    final type = XCMJunctionsType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMJunctionsType.here => XCMV2JunctionsHere.fromJson(json),
      XCMJunctionsType.x1 => XCMV2JunctionsX1.fromJson(json),
      XCMJunctionsType.x2 => XCMV2JunctionsX2.fromJson(json),
      XCMJunctionsType.x3 => XCMV2JunctionsX3.fromJson(json),
      XCMJunctionsType.x4 => XCMV2JunctionsX4.fromJson(json),
      XCMJunctionsType.x5 => XCMV2JunctionsX5.fromJson(json),
      XCMJunctionsType.x6 => XCMV2JunctionsX6.fromJson(json),
      XCMJunctionsType.x7 => XCMV2JunctionsX7.fromJson(json),
      XCMJunctionsType.x8 => XCMV2JunctionsX8.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsHere.layout_(property: property),
          property: XCMJunctionsType.here.name,
          index: 0),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x1, property: property),
          property: XCMJunctionsType.x1.name,
          index: 1),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x2, property: property),
          property: XCMJunctionsType.x2.name,
          index: 2),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x3, property: property),
          property: XCMJunctionsType.x3.name,
          index: 3),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x4, property: property),
          property: XCMJunctionsType.x4.name,
          index: 4),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x5, property: property),
          property: XCMJunctionsType.x5.name,
          index: 5),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x6, property: property),
          property: XCMJunctionsType.x6.name,
          index: 6),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x7, property: property),
          property: XCMJunctionsType.x7.name,
          index: 7),
      LazyVariantModel(
          layout: ({property}) =>
              XCMV2JunctionsX1.layout_(XCMJunctionsType.x8, property: property),
          property: XCMJunctionsType.x8.name,
          index: 8)
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2JunctionsHere extends XCMV2Junctions {
  XCMV2JunctionsHere() : super(type: XCMJunctionsType.here, junctions: []);
  factory XCMV2JunctionsHere.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMJunctionsType.here.type);
    return XCMV2JunctionsHere();
  }
  factory XCMV2JunctionsHere.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionsHere();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: null};
  }
}

class XCMV2JunctionsX1 extends XCMV2Junctions {
  XCMV2JunctionsX1._({required super.junctions, required super.type});
  XCMV2JunctionsX1({required super.junctions})
      : super(type: XCMJunctionsType.x1);
  XCMV2JunctionsX1._deserialize(Map<String, dynamic> json,
      {required super.type})
      : super(
            junctions: (json["junctions"] as List)
                .map((e) => XCMV2Junction.deserializeJson(e))
                .toList());
  factory XCMV2JunctionsX1.deserializeJson(Map<String, dynamic> json) {
    return XCMV2JunctionsX1(
        junctions: (json["junctions"] as List)
            .map((e) => XCMV2Junction.deserializeJson(e))
            .toList());
  }
  factory XCMV2JunctionsX1.fromJson(Map<String, dynamic> json) {
    return XCMV2JunctionsX1(junctions: [
      XCMV2Junction.fromJson(json.valueAs(XCMJunctionsType.x1.type))
    ]);
  }
  static Layout<Map<String, dynamic>> layout_(XCMJunctionsType type,
      {String? property}) {
    return LayoutConst.struct([
      LayoutConst.tuple(
          List.filled(type.junctionsLength, XCMV2Junction.layout_()),
          property: "junctions"),
    ], property: property ?? type.name);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(type, property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "junctions": junctions.map((e) => e.serializeJsonVariant()).toList()
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.first.toJson()};
  }
}

class XCMV2JunctionsX2 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX2.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x2);
  XCMV2JunctionsX2({required super.junctions})
      : super._(type: XCMJunctionsType.x2);
  factory XCMV2JunctionsX2.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x2.type);
    return XCMV2JunctionsX2(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX3 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX3.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x3);
  XCMV2JunctionsX3({required super.junctions})
      : super._(type: XCMJunctionsType.x3);
  factory XCMV2JunctionsX3.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x3.type);
    return XCMV2JunctionsX3(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX4 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX4.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x4);
  XCMV2JunctionsX4({required super.junctions})
      : super._(type: XCMJunctionsType.x4);
  factory XCMV2JunctionsX4.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x4.type);
    return XCMV2JunctionsX4(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX5 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX5.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x5);
  XCMV2JunctionsX5({required super.junctions})
      : super._(type: XCMJunctionsType.x5);
  factory XCMV2JunctionsX5.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x5.type);
    return XCMV2JunctionsX5(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX6 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX6.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x6);
  XCMV2JunctionsX6({required super.junctions})
      : super._(type: XCMJunctionsType.x6);
  factory XCMV2JunctionsX6.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x6.type);
    return XCMV2JunctionsX6(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX7 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX7.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x7);
  XCMV2JunctionsX7({required super.junctions})
      : super._(type: XCMJunctionsType.x7);
  factory XCMV2JunctionsX7.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x7.type);
    return XCMV2JunctionsX7(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

class XCMV2JunctionsX8 extends XCMV2JunctionsX1 {
  XCMV2JunctionsX8.deserializeJson(super.json)
      : super._deserialize(type: XCMJunctionsType.x8);
  XCMV2JunctionsX8({required super.junctions})
      : super._(type: XCMJunctionsType.x8);
  factory XCMV2JunctionsX8.fromJson(Map<String, dynamic> json) {
    final junctions =
        json.valueEnsureAsList<Map<String, dynamic>>(XCMJunctionsType.x8.type);
    return XCMV2JunctionsX8(
        junctions: junctions.map((e) => XCMV2Junction.fromJson(e)).toList());
  }
  @override
  Map<String, dynamic> toJson() {
    return {type.type: junctions.map((e) => e.toJson()).toList()};
  }
}

abstract class XCMV2AssetInstance extends SubstrateVariantSerialization
    with XCMAssetInstance, Equality {
  const XCMV2AssetInstance();
  factory XCMV2AssetInstance.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMAssetInstanceType.fromName(decode.variantName);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV2AssetInstanceUndefined.deserializeJson(decode.value),
      XCMAssetInstanceType.indexId =>
        XCMV2AssetInstanceIndex.deserializeJson(decode.value),
      XCMAssetInstanceType.array4 =>
        XCMV2AssetInstanceArray4.deserializeJson(decode.value),
      XCMAssetInstanceType.array8 =>
        XCMV2AssetInstanceArray8.deserializeJson(decode.value),
      XCMAssetInstanceType.array16 =>
        XCMV2AssetInstanceArray16.deserializeJson(decode.value),
      XCMAssetInstanceType.array32 =>
        XCMV2AssetInstanceArray32.deserializeJson(decode.value)
    };
  }
  factory XCMV2AssetInstance.fromJson(Map<String, dynamic> json) {
    final type = XCMAssetInstanceType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMAssetInstanceType.undefined =>
        XCMV2AssetInstanceUndefined.fromJson(json),
      XCMAssetInstanceType.indexId => XCMV2AssetInstanceIndex.fromJson(json),
      XCMAssetInstanceType.array4 => XCMV2AssetInstanceArray4.fromJson(json),
      XCMAssetInstanceType.array8 => XCMV2AssetInstanceArray8.fromJson(json),
      XCMAssetInstanceType.array16 => XCMV2AssetInstanceArray16.fromJson(json),
      XCMAssetInstanceType.array32 => XCMV2AssetInstanceArray32.fromJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return XCMAssetInstance.layout_(property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2AssetInstanceUndefined extends XCMV2AssetInstance
    with XCMAssetInstanceUndefined {
  XCMV2AssetInstanceUndefined();

  factory XCMV2AssetInstanceUndefined.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2AssetInstanceUndefined();
  }
  factory XCMV2AssetInstanceUndefined.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMAssetInstanceType.undefined.type);
    return XCMV2AssetInstanceUndefined();
  }
}

class XCMV2AssetInstanceIndex extends XCMV2AssetInstance
    with XCMAssetInstanceIndex {
  @override
  final BigInt index;
  XCMV2AssetInstanceIndex({required BigInt index}) : index = index.asUint128;

  factory XCMV2AssetInstanceIndex.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceIndex(index: BigintUtils.parse(json["index"]));
  }

  factory XCMV2AssetInstanceIndex.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceIndex(
        index: json.valueAs(XCMAssetInstanceType.indexId.type));
  }
}

class XCMV2AssetInstanceArray4 extends XCMV2AssetInstance
    with XCMAssetInstanceArray4 {
  @override
  final List<int> datum;
  XCMV2AssetInstanceArray4({required List<int> datum})
      : datum = datum.exc(4).asImmutableBytes;

  factory XCMV2AssetInstanceArray4.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray4(datum: (json["datum"] as List).cast());
  }
  factory XCMV2AssetInstanceArray4.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray4(
        datum: json.valueAsBytes(XCMAssetInstanceType.array4.type));
  }
}

class XCMV2AssetInstanceArray8 extends XCMV2AssetInstance
    with XCMAssetInstanceArray8 {
  @override
  final List<int> datum;
  XCMV2AssetInstanceArray8({required List<int> datum})
      : datum = datum.exc(8).asImmutableBytes;

  factory XCMV2AssetInstanceArray8.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray8(datum: (json["datum"] as List).cast());
  }
  factory XCMV2AssetInstanceArray8.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray8(
        datum: json.valueAsBytes(XCMAssetInstanceType.array8.type));
  }
}

class XCMV2AssetInstanceArray16 extends XCMV2AssetInstance
    with XCMAssetInstanceArray16 {
  @override
  final List<int> datum;
  XCMV2AssetInstanceArray16({required List<int> datum})
      : datum = datum.exc(16).asImmutableBytes;

  factory XCMV2AssetInstanceArray16.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray16(datum: (json["datum"] as List).cast());
  }
  factory XCMV2AssetInstanceArray16.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray16(
        datum: json.valueAsBytes(XCMAssetInstanceType.array16.type));
  }
}

class XCMV2AssetInstanceArray32 extends XCMV2AssetInstance
    with XCMAssetInstanceArray32 {
  @override
  final List<int> datum;
  XCMV2AssetInstanceArray32({required List<int> datum})
      : datum = datum.exc(32).asImmutableBytes;

  factory XCMV2AssetInstanceArray32.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray32(datum: (json["datum"] as List).cast());
  }
  factory XCMV2AssetInstanceArray32.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetInstanceArray32(
        datum: json.valueAsBytes(XCMAssetInstanceType.array32.type));
  }
}

abstract class XCMV2Fungibility extends SubstrateVariantSerialization
    with XCMFungibility, Equality {
  const XCMV2Fungibility();
  factory XCMV2Fungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMFungibilityType.fungible =>
        XCMV2FungibilityFungible.deserializeJson(decode.value),
      XCMFungibilityType.nonFungible =>
        XCMV2FungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV2Fungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMFungibilityType.fungible => XCMV2FungibilityFungible.fromJson(json),
      XCMFungibilityType.nonFungible =>
        XCMV2FungibilityNonFungible.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMFungibilityFungible.layout_(property: property),
        property: XCMFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2FungibilityNonFungible.layout_(property: property),
        property: XCMFungibilityType.nonFungible.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2FungibilityFungible extends XCMV2Fungibility
    with XCMFungibilityFungible {
  @override
  final BigInt units;

  XCMV2FungibilityFungible({required BigInt units}) : units = units.asUint128;

  factory XCMV2FungibilityFungible.deserializeJson(Map<String, dynamic> json) {
    return XCMV2FungibilityFungible(units: BigintUtils.parse(json["units"]));
  }
  factory XCMV2FungibilityFungible.fromJson(Map<String, dynamic> json) {
    return XCMV2FungibilityFungible(
        units: json.valueAs(XCMFungibilityType.fungible.type));
  }
}

class XCMV2FungibilityNonFungible extends XCMV2Fungibility
    with XCMFungibilityNonFungible {
  @override
  final XCMV2AssetInstance instance;

  XCMV2FungibilityNonFungible({required this.instance});

  factory XCMV2FungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2FungibilityNonFungible(
        instance: XCMV2AssetInstance.deserializeJson(json["instance"]));
  }
  factory XCMV2FungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    return XCMV2FungibilityNonFungible(
        instance: XCMV2AssetInstance.fromJson(
            json.valueAs(XCMFungibilityType.nonFungible.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV2AssetInstance.layout_(property: "instance")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }
}

abstract class XCMV2WildFungibility extends SubstrateVariantSerialization
    with XCMWildFungibility, Equality {
  const XCMV2WildFungibility();
  factory XCMV2WildFungibility.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildFungibilityType.fromName(decode.variantName);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV2WildFungibilityFungible.deserializeJson(decode.value),
      XCMWildFungibilityType.nonFungible =>
        XCMV2WildFungibilityNonFungible.deserializeJson(decode.value)
    };
  }
  factory XCMV2WildFungibility.fromJson(Map<String, dynamic> json) {
    final type = XCMWildFungibilityType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildFungibilityType.fungible =>
        XCMV2WildFungibilityFungible.fromJson(json),
      XCMWildFungibilityType.nonFungible =>
        XCMV2WildFungibilityNonFungible.deserializeJson(json)
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2WildFungibilityFungible.layout_(property: property),
        property: XCMWildFungibilityType.fungible.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2WildFungibilityNonFungible.layout_(property: property),
        property: XCMWildFungibilityType.nonFungible.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;

  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2WildFungibilityFungible extends XCMV2WildFungibility
    with XCMWildFungibilityFungible {
  XCMV2WildFungibilityFungible();

  factory XCMV2WildFungibilityFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2WildFungibilityFungible();
  }
  factory XCMV2WildFungibilityFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.fungible.type);
    return XCMV2WildFungibilityFungible();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}

class XCMV2WildFungibilityNonFungible extends XCMV2WildFungibility
    with XCMWildFungibilityNonFungible {
  XCMV2WildFungibilityNonFungible();

  factory XCMV2WildFungibilityNonFungible.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2WildFungibilityNonFungible();
  }
  factory XCMV2WildFungibilityNonFungible.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildFungibilityType.nonFungible.type);
    return XCMV2WildFungibilityNonFungible();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}

class XCMV2MultiLocation extends XCMMultiLocation with Equality {
  @override
  final int parents;
  @override
  final XCMV2Junctions interior;

  XCMV2MultiLocation({required int parents, required this.interior})
      : parents = parents.asUint8;
  factory XCMV2MultiLocation.deserialize(List<int> bytes) {
    final json =
        SubstrateSerialization.deserialize(bytes: bytes, layout: layout_());
    return XCMV2MultiLocation.deserializeJson(json.value);
  }
  factory XCMV2MultiLocation.deserializeJson(Map<String, dynamic> json) {
    return XCMV2MultiLocation(
        parents: IntUtils.parse(json["parents"]),
        interior: XCMV2Junctions.deserializeJson(json["interior"]));
  }
  factory XCMV2MultiLocation.from(XCMMultiLocation location) {
    if (location is XCMV2MultiLocation) return location;
    return XCMV2MultiLocation(
        parents: location.parents,
        interior: XCMV2Junctions.from(location.interior));
  }
  factory XCMV2MultiLocation.fromJson(Map<String, dynamic> json) {
    return XCMV2MultiLocation(
        parents: json.valueAs("parents"),
        interior: XCMV2Junctions.fromJson(json.valueAs("interior")));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "parents"),
      XCMV2Junctions.layout_(property: "interior")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"parents": parents, "interior": interior.serializeJsonVariant()};
  }

  @override
  XCMVersion get version => XCMVersion.v2;

  @override
  Map<String, dynamic> toJson() {
    return {"parents": parents, "interior": interior.toJson()};
  }
}

enum XCMV2AssetIdType {
  concrete("Concrete"),
  abtract("Abtract");

  final String type;
  const XCMV2AssetIdType(this.type);
  static XCMV2AssetIdType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw ItemNotFoundException(value: name));
  }

  static XCMV2AssetIdType fromType(String? type) {
    return values.firstWhere((e) => e.type == type,
        orElse: () => throw ItemNotFoundException(value: type));
  }
}

abstract class XCMV2AssetId extends SubstrateVariantSerialization
    with XCMAssetId, Equality {
  final XCMV2AssetIdType type;
  const XCMV2AssetId({required this.type});
  factory XCMV2AssetId.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMV2AssetIdType.fromName(decode.variantName);
    return switch (type) {
      XCMV2AssetIdType.concrete =>
        XCMV2AssetIdConcrete.deserializeJson(decode.value),
      XCMV2AssetIdType.abtract =>
        XCMV2AssetIdAbstract.deserializeJson(decode.value)
    };
  }
  factory XCMV2AssetId.fromJson(Map<String, dynamic> json) {
    final type = XCMV2AssetIdType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMV2AssetIdType.concrete => XCMV2AssetIdConcrete.fromJson(json),
      XCMV2AssetIdType.abtract => XCMV2AssetIdAbstract.fromJson(json)
    };
  }
  factory XCMV2AssetId.from(XCMAssetId id) {
    return switch (id) {
      final XCMV2AssetId assetId => assetId,
      final XCMV3AssetId assetId => switch (assetId.type) {
          XCMV3AssetIdType.abtract =>
            XCMV2AssetIdAbstract(id: assetId.cast<XCMV3AssetIdAbstract>().id),
          XCMV3AssetIdType.concrete => XCMV2AssetIdConcrete(
              location: assetId
                  .cast<XCMV3AssetIdConcrete>()
                  .location
                  .asVersion(XCMVersion.v2)),
        },
      final XCMV4AssetId assetId => XCMV2AssetIdConcrete(
          location: assetId.location.asVersion(XCMVersion.v2)),
      final XCMV5AssetId assetId => XCMV2AssetIdConcrete(
          location: assetId.location.asVersion(XCMVersion.v2)),
      _ => throw DartSubstratePluginException("Unknow asset id.")
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2AssetIdConcrete.layout_(property: property),
        property: XCMV2AssetIdType.concrete.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2AssetIdAbstract.layout_(property: property),
        property: XCMV2AssetIdType.abtract.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  XCMVersion get version => XCMVersion.v2;
  @override
  String get variantName => type.name;
}

class XCMV2AssetIdConcrete extends XCMV2AssetId {
  @override
  final XCMV2MultiLocation location;
  XCMV2AssetIdConcrete({required this.location})
      : super(type: XCMV2AssetIdType.concrete);

  factory XCMV2AssetIdConcrete.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetIdConcrete(
        location: XCMV2MultiLocation.deserializeJson(json["location"]));
  }
  factory XCMV2AssetIdConcrete.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetIdConcrete(
        location: XCMV2MultiLocation.fromJson(
            json.valueAs(XCMV2AssetIdType.concrete.type)));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct(
        [XCMV2MultiLocation.layout_(property: "location")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"location": location.serializeJson()};
  }

  @override
  Map<String, dynamic> toJson() {
    return {type.type: location.toJson()};
  }

  @override
  List get variabels => [type, location];
}

class XCMV2AssetIdAbstract extends XCMV2AssetId {
  final List<int> id;
  XCMV2AssetIdAbstract({required List<int> id})
      : id = id.asImmutableBytes,
        super(type: XCMV2AssetIdType.abtract);

  factory XCMV2AssetIdAbstract.deserializeJson(Map<String, dynamic> json) {
    return XCMV2AssetIdAbstract(id: (json["id"] as List).cast());
  }
  factory XCMV2AssetIdAbstract.fromJson(Map<String, dynamic> json) {
    return XCMV2AssetIdAbstract(
        id: json.valueAsBytes(XCMV2AssetIdType.abtract.type));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([LayoutConst.bytes(property: "id")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id};
  }

  @override
  XCMMultiLocation? get location => null;
  @override
  Map<String, dynamic> toJson() {
    return {type.type: id};
  }

  @override
  List get variabels => [type, id];
}

class XCMV2MultiAsset extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAsset, Equality {
  @override
  final XCMV2AssetId id;
  @override
  final XCMV2Fungibility fun;

  XCMV2MultiAsset({required this.id, required this.fun});

  factory XCMV2MultiAsset.deserializeJson(Map<String, dynamic> json) {
    return XCMV2MultiAsset(
        id: XCMV2AssetId.deserializeJson(json["id"]),
        fun: XCMV2Fungibility.deserializeJson(json["fun"]));
  }
  factory XCMV2MultiAsset.fromJson(Map<String, dynamic> json) {
    return XCMV2MultiAsset(
        id: XCMV2AssetId.fromJson(json.valueAs("id")),
        fun: XCMV2Fungibility.fromJson(json["fun"]));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2AssetId.layout_(property: "id"),
      XCMV2Fungibility.layout_(property: "fun")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJsonVariant(), "fun": fun.serializeJsonVariant()};
  }

  @override
  XCMVersion get version => XCMVersion.v2;

  @override
  Map<String, dynamic> toJson() {
    return {"id": id.toJson(), "fun": fun.toJson()};
  }
}

class XCMV2MultiAssets extends SubstrateSerialization<Map<String, dynamic>>
    with XCMAssets<XCMV2MultiAsset>, Equality {
  @override
  final List<XCMV2MultiAsset> assets;

  XCMV2MultiAssets({required List<XCMV2MultiAsset> assets})
      : assets = assets.immutable;

  factory XCMV2MultiAssets.deserializeJson(Map<String, dynamic> json) {
    return XCMV2MultiAssets(
        assets: (json["assets"] as List)
            .map((e) => XCMV2MultiAsset.deserializeJson(e))
            .toList());
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactArray(XCMV2MultiAsset.layout_(), property: "assets")
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.map((e) => e.serializeJson()).toList()};
  }

  @override
  XCMVersion get version => XCMVersion.v2;
}

abstract class XCMV2WildMultiAsset extends SubstrateVariantSerialization
    with XCMWildMultiAsset, Equality {
  const XCMV2WildMultiAsset();
  factory XCMV2WildMultiAsset.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMWildAssetType.fromName(decode.variantName);
    return switch (type) {
      XCMWildAssetType.all =>
        XCMV2WildMultiAssetAll.deserializeJson(decode.value),
      XCMWildAssetType.allOf =>
        XCMV2WildMultiAssetAllOf.deserializeJson(decode.value),
      _ => throw DartSubstratePluginException(
          "Unsupported XCMWildAssetType by version 2.",
          details: {"type": type.name})
    };
  }
  factory XCMV2WildMultiAsset.fromJson(Map<String, dynamic> json) {
    final type = XCMWildAssetType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMWildAssetType.all => XCMV2WildMultiAssetAll.fromJson(json),
      XCMWildAssetType.allOf => XCMV2WildMultiAssetAllOf.fromJson(json),
      _ => throw DartSubstratePluginException(
          "Unsupported XCMWildAssetType by version 2.",
          details: {"type": type.name})
    };
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2WildMultiAssetAll.layout_(property: property),
        property: XCMWildAssetType.all.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2WildMultiAssetAllOf.layout_(property: property),
        property: XCMWildAssetType.allOf.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2WildMultiAssetAll extends XCMV2WildMultiAsset
    with XCMWildMultiAssetAll {
  XCMV2WildMultiAssetAll();

  factory XCMV2WildMultiAssetAll.deserializeJson(Map<String, dynamic> json) {
    return XCMV2WildMultiAssetAll();
  }
  factory XCMV2WildMultiAssetAll.fromJson(Map<String, dynamic> json) {
    json.ensureKeyExists(XCMWildAssetType.all.type);
    return XCMV2WildMultiAssetAll();
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.noArgs(property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {};
  }
}

class XCMV2WildMultiAssetAllOf extends XCMV2WildMultiAsset
    with XCMWildMultiAssetAllOf {
  @override
  final XCMV2AssetId id;
  @override
  final XCMV2WildFungibility fun;
  XCMV2WildMultiAssetAllOf({required this.id, required this.fun});

  factory XCMV2WildMultiAssetAllOf.deserializeJson(Map<String, dynamic> json) {
    return XCMV2WildMultiAssetAllOf(
        id: XCMV2AssetId.deserializeJson(json["id"]),
        fun: XCMV2WildFungibility.deserializeJson(json["fun"]));
  }
  factory XCMV2WildMultiAssetAllOf.fromJson(Map<String, dynamic> json) {
    final allOf =
        json.valueEnsureAsMap<String, dynamic>(XCMWildAssetType.allOf.type);
    return XCMV2WildMultiAssetAllOf(
        id: XCMV2AssetId.fromJson(allOf.valueAs("id")),
        fun: XCMV2WildFungibility.fromJson(allOf.valueAs("fun")));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([
      XCMV2AssetId.layout_(property: "id"),
      XCMV2WildFungibility.layout_(property: "fun"),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"id": id.serializeJsonVariant(), "fun": fun.serializeJsonVariant()};
  }
}

abstract class XCMV2MultiAssetFilter extends SubstrateVariantSerialization
    with XCMMultiAssetFilter, Equality {
  const XCMV2MultiAssetFilter();
  factory XCMV2MultiAssetFilter.deserializeJson(Map<String, dynamic> json) {
    final decode = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final type = XCMMultiAssetFilterType.fromName(decode.variantName);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV2MultiAssetFilterDefinite.deserializeJson(decode.value),
      XCMMultiAssetFilterType.wild =>
        XCMV2MultiAssetFilterWild.deserializeJson(decode.value)
    };
  }
  factory XCMV2MultiAssetFilter.fromJson(Map<String, dynamic> json) {
    final type = XCMMultiAssetFilterType.fromType(json.keys.firstOrNull);
    return switch (type) {
      XCMMultiAssetFilterType.definite =>
        XCMV2MultiAssetFilterDefinite.fromJson(json),
      XCMMultiAssetFilterType.wild => XCMV2MultiAssetFilterWild.fromJson(json)
    };
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.lazyEnum([
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2MultiAssetFilterDefinite.layout_(property: property),
        property: XCMMultiAssetFilterType.definite.name,
        index: 0,
      ),
      LazyVariantModel(
        layout: ({property}) =>
            XCMV2MultiAssetFilterWild.layout_(property: property),
        property: XCMMultiAssetFilterType.wild.name,
        index: 1,
      ),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> createVariantLayout({String? property}) {
    return layout_(property: property);
  }

  @override
  String get variantName => type.name;
  @override
  XCMVersion get version => XCMVersion.v2;
}

class XCMV2MultiAssetFilterDefinite extends XCMV2MultiAssetFilter
    with XCMMultiAssetFilterDefinite {
  @override
  final XCMV2MultiAssets assets;
  XCMV2MultiAssetFilterDefinite({required this.assets}) : super();

  factory XCMV2MultiAssetFilterDefinite.deserializeJson(
      Map<String, dynamic> json) {
    return XCMV2MultiAssetFilterDefinite(
        assets: XCMV2MultiAssets.deserializeJson(json.valueAs("assets")));
  }
  factory XCMV2MultiAssetFilterDefinite.fromJson(Map<String, dynamic> json) {
    final assets = json.valueEnsureAsList<Map<String, dynamic>>(
        XCMMultiAssetFilterType.definite.type);
    return XCMV2MultiAssetFilterDefinite(
        assets: XCMV2MultiAssets(
            assets: assets.map((e) => XCMV2MultiAsset.fromJson(e)).toList()));
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2MultiAssets.layout_(property: "assets")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"assets": assets.serializeJson()};
  }

  @override
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.definite;
}

class XCMV2MultiAssetFilterWild extends XCMV2MultiAssetFilter
    with XCMMultiAssetFilterWild {
  @override
  final XCMV2WildMultiAsset asset;
  XCMV2MultiAssetFilterWild({required this.asset}) : super();

  factory XCMV2MultiAssetFilterWild.deserializeJson(Map<String, dynamic> json) {
    return XCMV2MultiAssetFilterWild(
        asset: XCMV2WildMultiAsset.deserializeJson(json.valueAs("asset")));
  }
  factory XCMV2MultiAssetFilterWild.fromJson(Map<String, dynamic> json) {
    return XCMV2MultiAssetFilterWild(
        asset: XCMV2WildMultiAsset.fromJson(
            json.valueAs(XCMMultiAssetFilterType.wild.type)));
  }

  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.struct([XCMV2WildMultiAsset.layout_(property: "asset")],
        property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return layout_(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {"asset": asset.serializeJsonVariant()};
  }

  @override
  XCMMultiAssetFilterType get type => XCMMultiAssetFilterType.wild;
}
