import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/substrate.dart';
import 'package:test/test.dart';

import '../repository/westend_v14.dart';

extension _ToHex on List<int> {
  String toHex() => BytesUtils.toHexString(this);
}

void main() {
  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
          BytesUtils.fromHexString(westendV15))
      .metadata;
  _test(metadata);
}

void _test(MetadataV15 api) {
  test("ID-200", () {
    const lookupid = 200;
    final templateValue = {
      "type": "Tuple([U8;32], Enum)",
      "value": [
        {"type": "[U8;32]", "value": List<int>.filled(32, 2)},
        {
          "type": "Enum",
          "key": "Raw11",
          "value": {"type": "[U8;11]", "value": List<int>.filled(11, 2)},
          "variants": {
            "None": null,

            /// ...
            "Raw11": {"type": "[U8;11]", "value": null},

            /// ...
          }
        }
      ]
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      List<int>.filled(32, 2),
      {"Raw11": List<int>.filled(11, 2)}
    ]);
    expect(encodeSimple.toHex(),
        "02020202020202020202020202020202020202020202020202020202020202020c0202020202020202020202");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              List<int>.filled(32, 2),
              // 12 bytes for tyoe [u8;11]
              {"Raw11": List<int>.filled(12, 2)}
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              List<int>.filled(32, 2),
              // invalid variant key
              {"Raw111": List<int>.filled(11, 2)}
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-300", () {
    const lookupid = 300;
    final templateValue = {
      "type": "Enum",
      "key": "Plurality",
      "value": {
        "type": "Map",
        "value": {
          "id": {
            "type": "Enum",
            "key": "Moniker",
            "value": {
              "type": "[U8;4]",
              "value": [1, 2, 3, 4].toHex()
            },
          },
          "part": {
            "type": "Enum",
            "key": "AtLeastProportion",
            "value": {
              "type": "Map",
              "value": {
                "nom": {"type": "U32", "value": BigInt.from(444)},
                "denom": {"type": "U32", "value": BigInt.from(555)}
              }
            },
          }
        }
      },
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
      "Plurality": {
        "id": {
          "Moniker": [1, 2, 3, 4]
        },
        "part": {
          "AtLeastProportion": {"nom": 444, "denom": 555}
        }
      }
    });
    expect(encodeSimple.toHex(), "08010102030403f106ad08");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: {
              "id": {
                /// not [u8;4]
                "Moniker": [1, 2, 3].toHex()
              },
              "part": {
                "AtLeastProportion": {"nom": 444, "denom": 555}
              }
            },
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });
  test("ID-421", () {
    const lookupid = 421;
    final templateValue = {
      "type": "Vec<Asset>",
      "value": [
        {
          "type": "Map",
          "value": {
            "id": {
              "type": "Map",
              "value": {
                "parents": {"type": "U8", "value": 0},
                "interior": {
                  "type": "Enum",
                  "key": "X3",
                  "value": {
                    "type": "[Enum;3]",
                    "value": [
                      {
                        "type": "Enum",
                        "key": "AccountId32",
                        "value": {
                          "type": "Map",
                          "value": {
                            "network": {
                              "type": "Option<Enum>",
                              "key": "ByFork",
                              "value": {
                                "type": "Map",
                                "value": {
                                  "block_number": {
                                    "type": "U64",
                                    "value": 1213123123
                                  },
                                  "block_hash": {
                                    "type": "[U8;32]",
                                    "value": List<int>.filled(32, 10)
                                  }
                                }
                              },
                            },
                            "id": {
                              "type": "[U8;32]",
                              "value": List<int>.filled(32, 10)
                            }
                          }
                        },
                        "variants": {}
                      },
                      {
                        "type": "Enum",
                        "key": "AccountId32",
                        "value": {
                          "type": "Map",
                          "value": {
                            "network": {
                              "type": "Option<Enum>",
                              "key": "ByFork",
                              "value": {
                                "type": "Map",
                                "value": {
                                  "block_number": {
                                    "type": "U64",
                                    "value": 123123
                                  },
                                  "block_hash": {
                                    "type": "[U8;32]",
                                    "value": List<int>.filled(32, 10)
                                  }
                                }
                              },
                            },
                            "id": {
                              "type": "[U8;32]",
                              "value": List<int>.filled(32, 10)
                            }
                          }
                        },
                      },
                      {
                        "type": "Enum",
                        "key": "AccountId32",
                        "value": {
                          "type": "Map",
                          "value": {
                            "network": {
                              "type": "Option<Enum>",
                              "key": "ByFork",
                              "value": {
                                "type": "Map",
                                "value": {
                                  "block_number": {
                                    "type": "U64",
                                    "value": 123123123123
                                  },
                                  "block_hash": {
                                    "type": "[U8;32]",
                                    "value": List<int>.filled(32, 12)
                                  }
                                }
                              },
                            },
                            "id": {
                              "type": "[U8;32]",
                              "value": List<int>.filled(32, 15)
                            }
                          }
                        },
                        "variants": {}
                      }
                    ]
                  },
                }
              }
            },
            "fun": {
              "type": "Enum",
              "key": "NonFungible",
              "value": {
                "type": "Enum",
                "key": "Array4",
                "value": {"type": "[U8;4]", "value": List<int>.filled(4, 12)},
              },
            }
          }
        }
      ]
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      {
        "id": {
          "parents": 0,
          "interior": {
            "X3": [
              {
                "AccountId32": {
                  "network": {
                    "ByFork": {
                      "block_number": BigInt.from(1213123123),
                      "block_hash": List<int>.filled(32, 10)
                    }
                  },
                  "id": List<int>.filled(32, 10)
                }
              },
              {
                "AccountId32": {
                  "network": {
                    "ByFork": {
                      "block_number": BigInt.from(123123),
                      "block_hash": List<int>.filled(32, 10)
                    }
                  },
                  "id": List<int>.filled(32, 10)
                }
              },
              {
                "AccountId32": {
                  "network": {
                    "ByFork": {
                      "block_number": BigInt.from(123123123123),
                      "block_hash": List<int>.filled(32, 12)
                    }
                  },
                  "id": List<int>.filled(32, 15)
                }
              }
            ]
          }
        },
        "fun": {
          "NonFungible": {"Array4": List<int>.filled(4, 12)}
        }
      }
    ]);
    expect(encodeSimple.toHex(),
        "04000301010133ca4e48000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a010101f3e00100000000000a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a010101b3c3b5aa1c0000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f01020c0c0c0c");
  });
  test("ID-522", () {
    const lookupid = 522;
    final templateValue = {
      "type": "Vec<T>",
      "value": [
        {
          "type": "Tuple([U8;8], U32)",
          "value": [
            {"type": "[U8;8]", "value": List<int>.filled(8, 8)},
            {"type": "U32", "value": 1111}
          ]
        },
        {
          "type": "Tuple([U8;8], U32)",
          "value": [
            {"type": "[U8;8]", "value": List<int>.filled(8, 10)},
            {"type": "U32", "value": 1}
          ]
        }
      ]
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      [
        [8, 8, 8, 8, 8, 8, 8, 8],
        1111
      ],
      [
        [10, 10, 10, 10, 10, 10, 10, 10],
        1
      ]
    ]);
    expect(encodeSimple.toHex(),
        "080808080808080808570400000a0a0a0a0a0a0a0a01000000");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              [
                /// incorrect length
                [8, 8, 8, 8, 8, 8, 8, 8, 8],
                1111
              ],
              [
                [10, 10, 10, 10, 10, 10, 10, 10],
                1
              ]
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              [
                /// incorrect length
                [8, 8, 8, 8, 8, 8, 8, 8],
                1111
              ],
              [
                [10, 10, 10, 10, 10, 10, 10, 10],

                /// Invalid u32
                -1
              ]
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-609", () {
    const lookupid = 609;
    final templateValue = {"type": "Option<Vec<U8>>", "value": null};
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, null);
    expect(encodeSimple.toHex(), "00");
  });
  test("ID-609_2", () {
    const lookupid = 609;
    final templateValue = {
      "type": "Option<Vec<U8>>",
      "value": List<int>.filled(8, 12).toHex()
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, List<int>.filled(8, 12));
    expect(encodeSimple.toHex(), "01200c0c0c0c0c0c0c0c");
    expect(
        () => api.encodeLookup(
            id: lookupid,

            /// Incorrect template
            value: {
              "type": "Option<Vec<U8>>",
              "value": {"type": "Map", "value": List<int>.filled(8, 12).toHex()}
            },
            fromTemplate: true),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,

            /// Incorrect [U8]
            value: <int>[1, 2, 3, -1],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-650", () {
    const lookupid = 650;
    final templateValue = {
      "type": "Vec<T>",
      "value": [
        {
          "type": "Map",
          "value": {
            "real": {"type": "[U8;32]", "value": List<int>.filled(32, 1)},
            "call_hash": {"type": "[U8;32]", "value": List<int>.filled(32, 2)},
            "height": {"type": "U32", "value": 0}
          }
        },
        {
          "type": "Map",
          "value": {
            "real": {"type": "[U8;32]", "value": List<int>.filled(32, 2)},
            "call_hash": {"type": "[U8;32]", "value": List<int>.filled(32, 3)},
            "height": {"type": "U32", "value": 1}
          }
        }
      ]
    };

    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      {
        "real": List<int>.filled(32, 1),
        "call_hash": List<int>.filled(32, 2),
        "height": 0
      },
      {
        "real": List<int>.filled(32, 2),
        "call_hash": List<int>.filled(32, 3),
        "height": 1
      }
    ]);
    expect(encodeSimple.toHex(),
        "0801010101010101010101010101010101010101010101010101010101010101010202020202020202020202020202020202020202020202020202020202020202000000000202020202020202020202020202020202020202020202020202020202020202030303030303030303030303030303030303030303030303030303030303030301000000");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              {
                /// incorret length
                "real": List<int>.filled(33, 1),
                "call_hash": List<int>.filled(32, 2),
                "height": 0
              },
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,

            /// invalid value
            value: {
              /// incorret length
              "real": List<int>.filled(33, 1),
              "call_hash": List<int>.filled(32, 2),
              "height": 0
            },
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-700", () {
    const lookupid = 700;
    final templateValue = {
      "type": "Tuple(U32, Enum)",
      "value": [
        {"type": "U32", "value": 1},
        {
          "type": "Enum",
          "key": "SplitAbstain",
          "value": {
            "type": "Map",
            "value": {
              "aye": {"type": "U128", "value": 1},
              "nay": {"type": "U128", "value": BigInt.parse("1" * 15)},
              "abstain": {"type": "U128", "value": BigInt.parse("1" * 13)}
            }
          },
        }
      ]
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      1,
      {
        "SplitAbstain": {
          "aye": BigInt.one,
          "nay": BigInt.parse("111111111111111"),
          "abstain": BigInt.parse("1111111111111")
        }
      }
    ]);
    expect(encodeSimple.toHex(),
        "010000000201000000000000000000000000000000c7f14e120e6500000000000000000000c71162b3020100000000000000000000");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              1,
              {
                "SplitAbstain": {
                  "aye": 1,

                  /// invalid u128 (134 bitLength)
                  "nay":
                      BigInt.parse("11111111111111111111111111111111111111111"),
                  "abstain": BigInt.parse("1111111111111")
                }
              }
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              1,
              {
                /// invalid enum key
                "SplitAbstainn": {
                  "aye": 1,
                  "nay": BigInt.parse("111111111111111"),
                  "abstain": BigInt.parse("1111111111111")
                }
              }
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-750", () {
    const lookupid = 750;
    final templateValue = {
      "type": "Vec<T>",
      "value": [
        {
          "type": "Vec<T>",
          "value": [
            {"type": "U32", "value": 123},
            {"type": "U32", "value": 123},
            {"type": "U32", "value": 123},
            {"type": "U32", "value": 123},
            {"type": "U32", "value": 123}
          ]
        }
      ]
    };
    final simpleValue = api.registry
        .getValue(id: lookupid, value: templateValue, fromTemplate: true);
    final encodeSimple =
        api.encodeLookup(id: lookupid, value: simpleValue, fromTemplate: false);

    final encodeTemplate = api.encodeLookup(
        id: lookupid, value: templateValue, fromTemplate: true);
    expect(encodeSimple.toHex(), encodeTemplate.toHex());
    final decode = api.decodeLookup(lookupid, encodeTemplate);
    expect(decode, [
      [123, 123, 123, 123, 123]
    ]);
    expect(
        encodeSimple.toHex(), "04147b0000007b0000007b0000007b0000007b000000");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: [
              /// incorrect u32
              [-1, 123, 123, 123, 123]
            ],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,

            /// incorrec template
            value: [123, 123, 123, 123, 123],
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });

  test("ID-800", () {
    const lookupid = 800;
    final templateValue = {
      "type": "Map",
      "value": {
        "traffic": {"type": "U128", "value": BigInt.parse("1" * 14)},
        "next_index": {"type": "U32", "value": 22222},
        "smallest_index": {"type": "U32", "value": 33333},
        "freed_indices": {
          "type": "Vec<T>",
          "value": [
            {"type": "U32", "value": 123123},
            {"type": "U32", "value": 3232},
            {"type": "U32", "value": 111111}
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
      "traffic": BigInt.parse("11111111111111"),
      "next_index": 22222,
      "smallest_index": 33333,
      "freed_indices": [123123, 3232, 111111]
    });
    expect(encodeSimple.toHex(),
        "c7b1d4011b0a00000000000000000000ce560000358200000cf3e00100a00c000007b20100");
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: {
              /// worng key
              "trafficc": BigInt.parse("11111111111111"),
              "next_index": 22222,
              "smallest_index": 33333,
              "freed_indices": [123123, 3232, 111111]
            },
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
    expect(
        () => api.encodeLookup(
            id: lookupid,
            value: {
              "traffic": BigInt.parse("11111111111111"),

              /// worng u32 (35 bitLength)
              "next_index": 22222222222,
              "smallest_index": 33333,
              "freed_indices": [123123, 3232, 111111]
            },
            fromTemplate: false),
        throwsA(isA<MetadataException>()));
  });
}
