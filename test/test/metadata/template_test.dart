import 'package:blockchain_utils/binary/utils.dart';
import 'package:polkadot_dart/substrate.dart';
import 'package:test/test.dart';
import 'v14_metadata_hex.dart';

void main() {
  final VersionedMetadata<MetadataV14> metadata =
      VersionedMetadata.fromBytes(BytesUtils.fromHexString(metadataV14));

  group("Template", () {
    _test(metadata.metadata.registry);
  });
}

void _test(PortableRegistry registry) {
  test("loookup-8", () {
    const lookupId = 8;
    final typeTemplate = registry.typeTemplate(lookupId);
    final Map<String, dynamic> template = {"type": "Bool", "value": null};
    expect(template, typeTemplate.buildJsonTemplate());
    template["value"] = false;
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, false);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: false, fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("loookup-0", () {
    const lookupId = 0;
    final typeTemplate = registry.typeTemplate(lookupId);
    final Map<String, dynamic> template = {"type": "[U8;32]", "value": null};
    expect(template, typeTemplate.buildJsonTemplate());
    final bytes = List<int>.filled(32, 0);
    template["value"] = BytesUtils.toHexString(bytes);
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, bytes);
    final withoutTemplate = registry.getValue(
        id: lookupId,
        value: BytesUtils.toHexString(bytes),
        fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("loookup-3", () {
    const lookupId = 3;
    final typeTemplate = registry.typeTemplate(lookupId);
    Map<String, dynamic> template = {
      "type": "Map",
      "value": {
        "nonce": {"type": "U32", "value": null},
        "consumers": {"type": "U32", "value": null},
        "providers": {"type": "U32", "value": null},
        "sufficients": {"type": "U32", "value": null},
        "data": {
          "type": "Map",
          "value": {
            "free": {"type": "U128", "value": null},
            "reserved": {"type": "U128", "value": null},
            "frozen": {"type": "U128", "value": null},
            "flags": {"type": "U128", "value": null}
          }
        }
      }
    };
    expect(template, typeTemplate.buildJsonTemplate());
    template = {
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
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, {
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
    final withoutTemplate = registry.getValue(
        id: lookupId,
        value: {
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
        },
        fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("lookup-8", () {
    const int lookupId = 9;
    Map<String, dynamic> template = {
      "type": "Map",
      "value": {
        "normal": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 1},
            "proof_size": {"type": "U64", "value": 2}
          }
        },
        "operational": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 3},
            "proof_size": {"type": "U64", "value": 4}
          }
        },
        "mandatory": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": 5},
            "proof_size": {"type": "U64", "value": 6}
          }
        }
      }
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, {
      "normal": {"ref_time": BigInt.one, "proof_size": BigInt.two},
      "operational": {"ref_time": BigInt.from(3), "proof_size": BigInt.from(4)},
      "mandatory": {"ref_time": BigInt.from(5), "proof_size": BigInt.from(6)}
    });
    final withoutTemplate = registry.getValue(
        id: lookupId,
        value: {
          "normal": {"ref_time": BigInt.one, "proof_size": BigInt.two},
          "operational": {
            "ref_time": BigInt.from(3),
            "proof_size": BigInt.from(4)
          },
          "mandatory": {
            "ref_time": BigInt.from(5),
            "proof_size": BigInt.from(6)
          }
        },
        fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-14", () {
    const int lookupId = 14;
    Map<String, dynamic> template = {
      "type": "Vec<U8>",
      "value": List<int>.filled(38, 12)
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, List<int>.filled(38, 12));
    final withoutTemplate = registry.getValue(
        id: lookupId, value: List<int>.filled(38, 12), fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-17", () {
    const int lookupId = 17;
    Map<String, dynamic> template = {
      "type": "Enum",
      "key": "RuntimeEnvironmentUpdated",
      "value": null
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    expect(value, {"RuntimeEnvironmentUpdated": null});
    final withoutTemplate = registry.getValue(
        id: lookupId,
        value: {"RuntimeEnvironmentUpdated": null},
        fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-17_2", () {
    const int lookupId = 17;
    Map<String, dynamic> template = {
      "type": "Enum",
      "key": "PreRuntime",
      "value": {
        "type": "Tuple",
        "value": [
          {"type": "[U8;4]", "value": List<int>.filled(4, 5)},
          {"type": "Vec<U8>", "value": List<int>.filled(25, 2)}
        ]
      }
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "PreRuntime": [
        [5, 5, 5, 5],
        [
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2
        ]
      ]
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("lookup-17_3", () {
    const int lookupId = 17;
    Map<String, dynamic> template = {
      "type": "Enum",
      "key": "Other",
      "value": {
        "value": [33, 33, 33, 33, 33, 33]
      }
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "Other": [33, 33, 33, 33, 33, 33]
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-16", () {
    const int lookupId = 16;
    Map<String, dynamic> template = {
      "type": "Vec<T>",
      "value": [
        {
          "type": "Enum",
          "key": "RuntimeEnvironmentUpdated",
          "value": null,
        },
        {
          "type": "Enum",
          "key": "RuntimeEnvironmentUpdated",
          "value": null,
        },
        {
          "type": "Enum",
          "key": "PreRuntime",
          "value": {
            "value": [
              {"value": List<int>.filled(4, 2)},
              {"value": List<int>.filled(10, 2)}
            ]
          },
        },
        {
          "type": "Enum",
          "key": "Other",
          "value": {"value": List<int>.filled(10, 2)},
        },
      ]
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = [
      {"RuntimeEnvironmentUpdated": null},
      {"RuntimeEnvironmentUpdated": null},
      {
        "PreRuntime": [
          [2, 2, 2, 2],
          [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        ]
      },
      {
        "Other": [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      }
    ];
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-15", () {
    const int lookupId = 15;
    final template = {
      "type": "Map",
      "value": {
        "logs": {
          "type": "Vec<DigestItem>",
          "value": [
            {"type": "Enum", "key": "RuntimeEnvironmentUpdated", "value": null},
            {
              "type": "Enum",
              "key": "RuntimeEnvironmentUpdated",
              "value": null,
            },
            {
              "type": "Enum",
              "key": "PreRuntime",
              "value": {
                "value": [
                  {"value": List<int>.filled(4, 2)},
                  {"value": List<int>.filled(10, 2)}
                ]
              },
            },
            {
              "type": "Enum",
              "key": "Other",
              "value": {"value": List<int>.filled(10, 2)},
            },
          ]
        }
      }
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "logs": [
        {"RuntimeEnvironmentUpdated": null},
        {"RuntimeEnvironmentUpdated": null},
        {
          "PreRuntime": [
            [2, 2, 2, 2],
            [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
          ]
        },
        {
          "Other": [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        }
      ]
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("lookup-22", () {
    const int lookupId = 22;
    final template = {
      "type": "Enum",
      "key": "ExtrinsicSuccess",
      "value": {
        "type": "Map",
        "value": {
          "weight": {
            "type": "Map",
            "value": {
              "ref_time": {"type": "U64", "value": 12},
              "proof_size": {"type": "U64", "value": 13}
            }
          },
          "class": {
            "type": "Enum",
            "key": "Normal",
            "value": null,
          },
          "pays_fee": {
            "type": "Enum",
            "key": "Yes",
            "value": null,
          }
        }
      },
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "ExtrinsicSuccess": {
        "weight": {"ref_time": BigInt.from(12), "proof_size": BigInt.from(13)},
        "class": {"Normal": null},
        "pays_fee": {"Yes": null}
      }
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("lookup-23", () {
    const int lookupId = 23;
    final template = {
      "type": "Map",
      "value": {
        "weight": {
          "type": "Map",
          "value": {
            "ref_time": {"type": "U64", "value": BigInt.from(123123123)},
            "proof_size": {"type": "U64", "value": 123123123123}
          }
        },
        "class": {
          "type": "Enum",
          "key": "Operational",
          "value": null,
          "variants": {"Normal": null, "Operational": null, "Mandatory": null}
        },
        "pays_fee": {
          "type": "Enum",
          "key": "No",
          "value": null,
          "variants": {"Yes": null, "No": null}
        }
      }
    };

    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "weight": {
        "ref_time": BigInt.from(123123123),
        "proof_size": BigInt.from(123123123123)
      },
      "class": {"Operational": null},
      "pays_fee": {"No": null}
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("lookup-100", () {
    const int lookupId = 100;
    Map<String, dynamic> template = {
      "type": "Enum",
      "key": "transfer",
      "value": {
        "type": "Map",
        "value": {
          "new": {
            "type": "Enum",
            "key": "Id",
            "value": {"type": "[U8;32]", "value": List<int>.filled(32, 0)},
          },
          "index": {"type": "U32", "value": 11111}
        }
      },
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = {
      "transfer": {
        "new": {
          "Id": [
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0
          ]
        },
        "index": 11111
      }
    };
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("loookup-46", () {
    const lookupId = 46;
    final Map<String, dynamic> template = {
      "type": "Tuple",
      "value": [
        {"type": "[U8;32]", "value": List<int>.filled(32, 12)},
        {"type": "U64", "value": BigInt.from(123123)}
      ]
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = [
      [
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12
      ],
      BigInt.from(123123)
    ];
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });
  test("loookup-200", () {
    const lookupId = 200;
    final template = {
      "type": "Tuple",
      "value": [
        {"type": "[U8;32]", "value": List<int>.filled(32, 1)},
        {
          "type": "Enum",
          "key": "Keccak256",
          "value": {"type": "[U8;32]", "value": List<int>.filled(32, 2)},
          "variants": {
            "None": null,
            "Raw0": {"type": "[U8;0]", "value": null},
            "Raw1": {"type": "[U8;1]", "value": null},
            "Raw2": {"type": "[U8;2]", "value": null},
            "Raw3": {"type": "[U8;3]", "value": null},
            "Raw4": {"type": "[U8;4]", "value": null},
            "Raw5": {"type": "[U8;5]", "value": null},
            "Raw6": {"type": "[U8;6]", "value": null},
            "Raw7": {"type": "[U8;7]", "value": null},
            "Raw8": {"type": "[U8;8]", "value": null},
            "Raw9": {"type": "[U8;9]", "value": null},
            "Raw10": {"type": "[U8;10]", "value": null},
            "Raw11": {"type": "[U8;11]", "value": null},
            "Raw12": {"type": "[U8;12]", "value": null},
            "Raw13": {"type": "[U8;13]", "value": null},
            "Raw14": {"type": "[U8;14]", "value": null},
            "Raw15": {"type": "[U8;15]", "value": null},
            "Raw16": {"type": "[U8;16]", "value": null},
            "Raw17": {"type": "[U8;17]", "value": null},
            "Raw18": {"type": "[U8;18]", "value": null},
            "Raw19": {"type": "[U8;19]", "value": null},
            "Raw20": {"type": "[U8;20]", "value": null},
            "Raw21": {"type": "[U8;21]", "value": null},
            "Raw22": {"type": "[U8;22]", "value": null},
            "Raw23": {"type": "[U8;23]", "value": null},
            "Raw24": {"type": "[U8;24]", "value": null},
            "Raw25": {"type": "[U8;25]", "value": null},
            "Raw26": {"type": "[U8;26]", "value": null},
            "Raw27": {"type": "[U8;27]", "value": null},
            "Raw28": {"type": "[U8;28]", "value": null},
            "Raw29": {"type": "[U8;29]", "value": null},
            "Raw30": {"type": "[U8;30]", "value": null},
            "Raw31": {"type": "[U8;31]", "value": null},
            "Raw32": {"type": "[U8;32]", "value": null},
            "BlakeTwo256": {"type": "[U8;32]", "value": null},
            "Sha256": {"type": "[U8;32]", "value": null},
            "Keccak256": {"type": "[U8;32]", "value": null},
            "ShaThree256": {"type": "[U8;32]", "value": null}
          }
        }
      ]
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = [
      [
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1
      ],
      {
        "Keccak256": [
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2,
          2
        ]
      }
    ];
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });

  test("loookup-57", () {
    const lookupId = 57;
    final Map<String, dynamic> template = {
      "type": "Option<[U8;32]>",
      "value": List<int>.filled(32, 12)
    };
    final value =
        registry.getValue(id: lookupId, value: template, fromTemplate: true);
    final result = [
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12,
      12
    ];
    expect(value, result);
    final withoutTemplate =
        registry.getValue(id: lookupId, value: result, fromTemplate: false);
    expect(value, withoutTemplate);
  });
}
