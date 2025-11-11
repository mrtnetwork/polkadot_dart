// SubstrateProvider createLocalProvider(int ip) =>
//     SubstrateProvider(SubstrateWebsocketService(url: "ws://localhost:$ip"));
// ignore_for_file: avoid_print

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:example/examples/websocket_rpc_example.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

SubstrateProvider createLocalProvider(int ip) =>
    SubstrateProvider(SubstrateWebsocketService(url: "ws://localhost:$ip"));

BaseSubstratePrivateKey createOwnerKeyPair(BaseSubstrateNetwork network,
    {int addressIndex = 0}) {
  const mnemonic =
      "link stand brass velvet hobby jelly hundred auto soap certain way kingdom";
  final seedBytes =
      Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate();
  final bip44 = Bip44.fromSeed(
      seedBytes,
      switch (network.chainType) {
        SubstrateChainType.substrate => Bip44Coins.polkadotEd25519Slip,
        SubstrateChainType.ethereum => Bip44Coins.ethereum
      });
  final wallet = bip44.purpose.coin
      .account(0)
      .change(Bip44Changes.chainExt)
      .addressIndex(addressIndex);
  final keyBytes = wallet.privateKey.raw;
  if (network.chainType == SubstrateChainType.ethereum) {
    return SubstrateEthereumPrivateKey.fromBytes(wallet.privateKey.raw);
  }
  return SubstratePrivateKey.fromPrivateKey(
      keyBytes: keyBytes, algorithm: SubstrateKeyAlgorithm.ed25519);
}

BaseSubstrateAddress createAccount(BaseSubstrateNetwork network,
    {int addressIndex = 0}) {
  final key = createOwnerKeyPair(network, addressIndex: addressIndex);
  final address = key.toAddress();
  if (address is SubstrateAddress) return address.toSS58(network.ss58);
  return address;
}
