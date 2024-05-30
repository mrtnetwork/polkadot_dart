import 'package:blockchain_utils/binary/utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:test/test.dart';
import 'v14_metadata_hex.dart';

void main() {
  final metadataBytesV14 = BytesUtils.fromHexString(metadataV14).sublist(5);
  final metadata = MetadataApi(MetadataV14.fromBytes(metadataBytesV14));

  group("Metadata v14", () {
    _encodeDecode(metadata);
  });
}

void _encodeDecode(MetadataApi api) {
  test("transfer_allow_death", () {
    final receiver =
        SubstrateAddress("5DZM9wq9xQQwp3HZMVftVGLCsqNJE9KoK8C9VGmaZbJHqyEw");
    final Map<String, dynamic> transferAllowDeath = {
      "transfer_allow_death": {
        "dest": {"Id": receiver.toBytes()},
        "value": BigInt.from(100000000000)
      }
    };
    final encodeCall = api.encodeCall(
        palletNameOrIndex: "Balances",
        value: transferAllowDeath,
        fromTemplate: false);
    expect(BytesUtils.toHexString(encodeCall),
        "0400004214a9208f35732f27e41e7f2f6658082d06b14553a38a646c3c51bddc425e390700e8764817");

    final decodeCall = api.decodeCall(encodeCall);
    expect(transferAllowDeath, decodeCall);
  });
}
