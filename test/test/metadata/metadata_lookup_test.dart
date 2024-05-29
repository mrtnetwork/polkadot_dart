import 'package:blockchain_utils/binary/utils.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/substrate.dart';
import 'package:test/test.dart';
import 'v14_metadata_hex.dart';

void main() {
  final metadataBytesV14 = BytesUtils.fromHexString(metadataV14).sublist(5);
  final metadata = MetadataV14.fromBytes(metadataBytesV14);

  group("Metadata v14", () {
    _encodeDecode(metadata.lookup);
  });
}

void _encodeDecode(PortableRegistry registry) {
  test("Encode and Decode", () {
    final layout = SubstrateMetadataLayouts.metadataV14();
    final metadataBytes = BytesUtils.fromHexString(metadataV14).sublist(5);
    final decode = layout.deserialize(metadataBytes);
    final encodBytes = layout.serialize(decode.value);
    expect(encodBytes, metadataBytes);
  });
  test("lockup-6", () {
    const int loockUpId = 6;
    final value = BigInt.from(1233333);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode), "b5d11200000000000000000000000000");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-3", () {
    const int loockUpId = 3;
    final value = {
      "nonce": 1,
      "consumers": 1,
      "providers": 222,
      "sufficients": 1,
      "data": {
        "free": BigInt.one,
        "reserved": BigInt.one,
        "frozen": BigInt.one,
        "flags": BigInt.two
      }
    };
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "0100000001000000de0000000100000001000000000000000000000000000000010000000000000000000000000000000100000000000000000000000000000002000000000000000000000000000000");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-9", () {
    const int loockUpId = 9;
    final value = {
      "normal": {"ref_time": BigInt.one, "proof_size": BigInt.one},
      "operational": {"ref_time": BigInt.one, "proof_size": BigInt.one},
      "mandatory": {"ref_time": BigInt.one, "proof_size": BigInt.one},
    };
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode), "040404040404");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-12", () {
    const int loockUpId = 12;
    final value = BigInt.from(12323);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode), "2330000000000000");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-13", () {
    const int loockUpId = 13;
    final value = List<int>.filled(32, 12);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-14", () {
    const int loockUpId = 14;
    final value = List<int>.filled(32, 12);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "800c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-15_2", () {
    const int loockUpId = 15;
    final value = {
      "logs": [
        {
          "Consensus": [List<int>.filled(4, 2), List<int>.filled(20, 12)]
        }
      ]
    };
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "040402020202500c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-15", () {
    const int loockUpId = 15;
    final value = {
      "logs": [
        {"RuntimeEnvironmentUpdated": null}
      ]
    };
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode), "0408");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-15-3", () {
    const int loockUpId = 15;
    final value = {
      "logs": [
        {"Other": List<int>.filled(20, 12)}
      ]
    };
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "0400500c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-16", () {
    const int loockUpId = 16;
    final value = [
      {"Other": List<int>.filled(20, 12)}
    ];
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "0400500c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-17", () {
    const int loockUpId = 17;
    final value = {"Other": List<int>.filled(20, 12)};
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "00500c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-18", () {
    const int loockUpId = 18;
    final value = List<int>.filled(4, 12);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode), "0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-19", () {
    const int loockUpId = 19;
    final value = [
      {
        "phase": {"ApplyExtrinsic": 12},
        "event": {
          "System": {"CodeUpdated": null}
        },
        "topics": [List<int>.filled(32, 12)]
      }
    ];
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "04000c0000000002040c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-19_2", () {
    const int loockUpId = 19;
    final value = [
      {
        "phase": {"ApplyExtrinsic": 12},
        "event": {
          "System": {"NewAccount": List<int>.filled(32, 1)}
        },
        "topics": [List<int>.filled(32, 12)]
      }
    ];

    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "04000c00000000030101010101010101010101010101010101010101010101010101010101010101040c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-19_3", () {
    const int loockUpId = 19;
    final value = [
      {
        "phase": {"ApplyExtrinsic": 12},
        "event": {
          "Staking": {
            "EraPaid": {
              "era_index": 1,
              "validator_payout": BigInt.from(10000),
              "remainder": BigInt.from(2000)
            }
          }
        },
        "topics": [List<int>.filled(32, 12)]
      }
    ];
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "04000c00000006000100000010270000000000000000000000000000d0070000000000000000000000000000040c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-19_4", () {
    const int loockUpId = 19;
    final value = [
      {
        "phase": {"ApplyExtrinsic": 12},
        "event": {
          "XcmPallet": {"VersionMigrationFinished": 1212}
        },
        "topics": [List<int>.filled(32, 12)]
      }
    ];
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "04000c0000006317bc040000040c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
  test("lockup-57", () {
    const int loockUpId = 57;
    final value = List<int>.filled(32, 2);
    final encode = registry.encode(loockUpId, value);
    expect(BytesUtils.toHexString(encode),
        "010202020202020202020202020202020202020202020202020202020202020202");
    final decode = registry.decode(loockUpId, encode);
    expect(decode, value);
  });
}
