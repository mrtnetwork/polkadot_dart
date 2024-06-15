import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';
import '../repository/westend_v14.dart';

void main() {
  final metadata = VersionedMetadata<MetadataV15>.fromBytes(
          BytesUtils.fromHexString(westendV15))
      .metadata;
  final api = MetadataApi(metadata);
  group("serialization", () {
    _test(api);
  });
}

void _test(MetadataApi api) {
  test("Balances-transfer_allow_death", () {
    final destination =
        SubstrateAddress("5EepAwmzpwn2PK45i3og3emvXs4NFnqzHu4T2VbUGhvkU4yB");
    final template = {
      "type": "Enum",
      "key": "transfer_allow_death",
      "value": {
        "type": "Map",
        "value": {
          "dest": {
            "key": "Id",
            "value": {"type": "[U8;32]", "value": destination.toBytes()},
          },
          "value": {"type": "U128", "value": SubstrateHelper.toWSD("0.1")}
        }
      },
    };
    final encode = api.encodeCall(
        palletNameOrIndex: "balances", value: template, fromTemplate: true);
    expect(BytesUtils.toHexString(encode),
        "040000727c11b81421f65f7d1a7f2e9b251b960caa94c6a55f7da9920384740f432abe0700e8764817");
  });
  test("System_account", () {
    final List<int> data = BytesUtils.fromHexString(
        "04000000020000000100000000000000e0624a6fc408000000000000000000000000000000000000000000000000000000204aa9d1010000000000000000000000000000000000000000000000000080");
    final decode = api.decodeStorageResponse(
        palletNameOrIndex: "system",
        methodName: "account",
        queryResponse: data);
    expect(decode, {
      "nonce": 4,
      "consumers": 2,
      "providers": 1,
      "sufficients": 0,
      "data": {
        "free": BigInt.from(9639773758176),
        "reserved": BigInt.zero,
        "frozen": BigInt.from(2000000000000),
        "flags": BigInt.parse("170141183460469231731687303715884105728")
      }
    });
  });
  test("System_account-2", () {
    final List<int> data = BytesUtils.fromHexString(
        "000000000000000001000000000000000058d7275e0900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080");
    final decode = api.decodeStorageResponse(
        palletNameOrIndex: "system",
        methodName: "account",
        queryResponse: data);
    expect(decode, {
      "nonce": 0,
      "consumers": 0,
      "providers": 1,
      "sufficients": 0,
      "data": {
        "free": BigInt.from(10300000000000),
        "reserved": BigInt.zero,
        "frozen": BigInt.zero,
        "flags": BigInt.parse("170141183460469231731687303715884105728")
      }
    });
  });

  test("system_version", () {
    final List<int> data = BytesUtils.fromHexString(
        "0x1c77657374656e64387061726974792d77657374656e6402000000386d0f000000000050df6acb689907609b0500000037e397fc7c91f5e40200000040fe3ad401f8959a06000000d2bc9897eed08f1503000000f78b278be53f454c02000000af2c0297a23e6d3d0b00000049eaaf1b548a0cb00300000091d5df18b0d2cf58020000002a5e924655399e6001000000ed99c5acb25eedf503000000cbca25e39f14238702000000687ad44ad37f03c201000000ab3c0572291feb8b01000000bc9d89904f5b923f0100000037c8bb1350a9a2a804000000f3ff14d5ab527059030000006ff52ee858e6c5bd0100000017a6bc0d0062aeb30100000018ef58a3b67ba77001000000fbc577b9d747efd6010000001900000001");
    final Map<String, dynamic> decode = api.decodeLookup(521, data);
    expect(decode["transaction_version"], 25);
    expect(decode["state_version"], 1);
    expect(decode["spec_name"], "westend");
    expect(decode["impl_name"], "parity-westend");
    expect(decode["spec_version"], 1011000);
  });
  test("account_nonce", () {
    final List<int> data = BytesUtils.fromHexString("0x05000000");
    final int decode = api.decodeLookup(4, data);
    expect(decode, 5);
    final addr =
        SubstrateAddress("5GjQNXpyZoyYiQ8GdB5fgjRkZdh3EgELwGdEmPP44YDnMx43");
    final encode = api.encodeLookup(
        id: 0,
        value: {"type": "[U8;32]", "value": addr.toBytes()},
        fromTemplate: true);
    expect(
        encode,
        BytesUtils.fromHexString(
            "ce74a4facc6eba97f01d694688311e590565bbd4d301f03e11c1ae7c35e71865"));
  });
}
