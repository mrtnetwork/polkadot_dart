import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart';
import '../metadata/v15_metadata_hex.dart';

extension _ToHex on List<int> {
  String toHex() => BytesUtils.toHexString(this);
}

void main() {
  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
          BytesUtils.fromHexString(metadataV15))
      .metadata;
  _test(metadata);
}

void _test(MetadataV15 api) {
  test("ID-1", () {
    const lookupid = 1;
    final templateValue = {"type": "[U8;32]", "value": List<int>.filled(32, 1)};
    final encodeSimple = api.encodeLookup(
        id: lookupid,
        value: BytesUtils.toHexString(List<int>.filled(32, 1)),
        fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, List<int>.filled(32, 1));
  });
  test("ID-2", () {
    const lookupid = 2;
    final templateValue = {"type": "U8", "value": 1};
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: BigInt.one, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, 1);
    expect(
        () => api.encodeLookup(id: lookupid, value: 257, fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });
  test("ID-3", () {
    const lookupid = 3;
    final templateValue = {
      "type": "Map",
      "value": {
        "nonce": {"type": "U32", "value": 1},
        "consumers": {"type": "U32", "value": 2},
        "providers": {"type": "U32", "value": 3},
        "sufficients": {"type": "U32", "value": 4},
        "data": {
          "type": "Map",
          "value": {
            "free": {"type": "U128", "value": 1},
            "reserved": {"type": "U128", "value": 2},
            "frozen": {"type": "U128", "value": 3},
            "flags": {"type": "U128", "value": 4}
          }
        }
      }
    };
    final value = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: value, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, {
      "nonce": 1,
      "consumers": 2,
      "providers": 3,
      "sufficients": 4,
      "data": {
        "free": BigInt.one,
        "reserved": BigInt.two,
        "frozen": BigInt.from(3),
        "flags": BigInt.from(4)
      }
    });
  });
  test("ID-6", () {
    const lookupid = 6;
    final templateValue = {"type": "U128", "value": BigInt.from(1)};
    final simpleValue = api.registry
        .getValue(id: lookupid, value: BigInt.from(1), fromTemplate: false);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, BigInt.one);
    expect(encodeSimple.toHex(), "01000000000000000000000000000000");
    expect(() => api.encodeLookup(id: lookupid, value: -1, fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });
  test("ID-8", () {
    const lookupid = 8;
    final templateValue = {"type": "Bool", "value": false};
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, false);
    expect(simpleValue, false);
    expect(encodeSimple.toHex(), "00");
    expect(
        () => api.encodeLookup(
            id: lookupid, value: "string", fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-9", () {
    const lookupid = 9;
    final templateValue = {
      "type": "Map",
      "value": {
        "normal": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 1},
            "proof_size": {"type": "U64", "value": BigInt.zero}
          }
        },
        "operational": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 2},
            "proof_size": {"type": "U64", "value": BigInt.one}
          }
        },
        "mandatory": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 3},
            "proof_size": {"type": "U64", "value": BigInt.two}
          }
        }
      }
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    final decodValue = {
      "normal": {"ref_time": BigInt.one, "proof_size": BigInt.zero},
      "operational": {"ref_time": BigInt.two, "proof_size": BigInt.one},
      "mandatory": {"ref_time": BigInt.from(3), "proof_size": BigInt.two}
    };
    expect(decode, decodValue);
    expect(simpleValue, decodValue);
    expect(encodeSimple.toHex(), "040008040c08");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: {
              "normal": {"ref_time": BigInt.one, "proof_size": BigInt.zero},
            },
            fromTemplate: true),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: {
              "normal": {
                "ref_time": BigInt.one,
                "proof_size":
                    BigInt.parse("12123123123123123123123123123123123123")
              },
              "operational": {"ref_time": BigInt.two, "proof_size": BigInt.one},
              "mandatory": {
                "ref_time": BigInt.from(3),
                "proof_size": BigInt.two
              }
            },
            fromTemplate: true),
        throwsA(isA<MetadataException>()));
  });

  test("ID-13", () {
    const lookupid = 13;
    final templateValue = {"type": "[U8;32]", "value": List<int>.filled(32, 1)};
    final hexValue = List<int>.filled(32, 1).toHex();
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);
    final encodeHex =
        api.encodeLookup(id: lookupid, value: hexValue, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, List<int>.filled(32, 1));
    expect(encodeSimple.toHex(),
        "0101010101010101010101010101010101010101010101010101010101010101");
    expect(encodeHex.toHex(),
        "0101010101010101010101010101010101010101010101010101010101010101");
    expect(
        () => api.encodeLookup(
            id: lookupid, value: List<int>.filled(33, 1), fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: BytesUtils.toHexString(List<int>.filled(33, 1)),
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });
  test("ID-14", () {
    const lookupid = 14;
    final templateValue = {"type": "Vec<U8>", "value": List<int>.filled(32, 1)};
    final hexValue = List<int>.filled(32, 1).toHex();
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);
    final encodeHex =
        api.encodeLookup(id: lookupid, value: hexValue, fromTemplate: false);
    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, List<int>.filled(32, 1));
    expect(encodeSimple.toHex(),
        "800101010101010101010101010101010101010101010101010101010101010101");
    expect(encodeHex.toHex(),
        "800101010101010101010101010101010101010101010101010101010101010101");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: List<int>.filled(33, 257),
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: BytesUtils.toHexString(List<int>.filled(33, 1)).substring(1),
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-15", () {
    const lookupid = 15;
    final templateValue = {
      "type": "Map",
      "value": {
        "logs": {
          "type": "Vec<DigestItem>",
          "value": [
            {
              "type": "Enum",
              "key": "RuntimeEnvironmentUpdated",
              "value": null,
            }
          ]
        }
      }
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, {
      "logs": [
        {"RuntimeEnvironmentUpdated": null}
      ]
    });
    expect(encodeSimple.toHex(), "0408");
  });
  test("ID-15_2", () {
    const lookupid = 15;
    final templateValue = {
      "type": "Map",
      "value": {
        "logs": {
          "type": "Vec<DigestItem>",
          "value": [
            {
              "key": "PreRuntime",
              "value": {
                "value": [
                  {
                    "type": "[U8;4]",
                    "value": [1, 2, 3, 4]
                  },
                  {"type": "Vec<U8>", "value": List<int>.filled(1, 0)}
                ]
              },
            }
          ]
        }
      }
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, {
      "logs": [
        {
          "PreRuntime": [
            [1, 2, 3, 4],
            [0]
          ]
        }
      ]
    });
    expect(decode, simpleValue);
    expect(encodeSimple.toHex(), "0406010203040400");
  });
  test("ID-15_3", () {
    const lookupid = 15;
    final templateValue = {
      "type": "Map",
      "value": {
        "logs": {
          "type": "Vec<DigestItem>",
          "value": [
            {
              "key": "Other",
              "value": {"type": "Vec<U8>", "value": List<int>.filled(12, 1)},
            }
          ]
        }
      }
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, {
      "logs": [
        {
          "Other": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        }
      ]
    });
    expect(decode, simpleValue);
    expect(encodeSimple.toHex(), "040030010101010101010101010101");
  });
}
