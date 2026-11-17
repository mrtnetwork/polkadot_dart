// Shared helpers for the Polkadot examples (local Chopsticks fork, see README.md).
//
// The fork exposes JSON-RPC on http://127.0.0.1:8001 and is funded with the
// Chopsticks-only `dev_setStorage` RPC. Metadata is built from `extrinsicInfo()`
// because `palletsInfos()` throws on pallets whose name parses as hex.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

/// Local Chopsticks JSON-RPC endpoint.
const String polkadotRpcUrl = 'http://127.0.0.1:8001';

/// SS58 format used by Westend and its parachains.
const int polkadotSs58 = 42;

/// The network the examples fork.
const WestendNetwork polkadotNetwork = WestendNetwork.westendAssetHub;

/// 1 DOT/WND = 1e12 planck.
final BigInt oneUnit = BigInt.from(1000000000000);

/// Sent per transfer (0.01 units).
final BigInt transferAmount = oneUnit ~/ BigInt.from(100);

/// An HTTP service for the local Chopsticks node.
class PolkadotHttpService with SubstrateServiceProvider {
  PolkadotHttpService({String url = polkadotRpcUrl, Duration? timeout})
    : _url = url,
      _timeout = timeout ?? const Duration(seconds: 30);

  final String _url;
  final Duration _timeout;

  @override
  Future<BaseServiceResponse> doRequest(
    SubstrateRequestDetails params, {
    Duration? timeout,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(params.encodeUrl(_url));
      request.headers.contentType = ContentType.json;
      params.headers.forEach(request.headers.set);
      final body = params.encodeBody();
      if (body != null) request.add(body);
      final response = await request.close().timeout(timeout ?? _timeout);
      final bytes = await response.fold<List<int>>(
        <int>[],
        (previous, chunk) => previous..addAll(chunk),
      );
      return params.toResponse(bytes, statusCode: response.statusCode);
    } finally {
      client.close();
    }
  }
}

/// `dev_setStorage` — writes raw storage entries into the forked state.
///
/// The library has no dedicated request for this Chopsticks-only method, so
/// this is a small subclass of [SubstrateRequest]. The params are an array of
/// `[key, value]` hex pairs.
class DevSetStorage extends SubstrateRequest<String?, String?> {
  const DevSetStorage(this.entries);

  final List<List<String>> entries;

  @override
  String get rpcMethod => 'dev_setStorage';

  @override
  List<dynamic> toJson() => [entries];
}

/// Metadata plus the extrinsic layout the transaction builder needs.
///
/// `MetadataWithExtrinsic.fromMetadata` throws on chains with a pallet whose
/// name looks like a hex number; building the layout from `extrinsicInfo()`
/// directly avoids that path (see the file header).
Future<MetadataWithProvider> loadMetadata(
  SubstrateProvider<PolkadotHttpService> provider,
) async {
  final metadata = await provider.request(
    const SubstrateRequestRuntimeMetadataGetMetadataAtVersion(15),
  );
  final api = metadata!.toApi();
  final extrinsic = ExtrinsicBuilderUtils.buildExtrinsicFields(
    api,
    api.metadata.extrinsicInfo().first,
  );
  return MetadataWithProvider(
    provider: provider,
    metadata: MetadataWithExtrinsic(api: api, extrinsic: extrinsic),
  );
}

/// Deterministic account for [index].
///
/// The seed is `sha256("polkadot_dart/example:$index")`; the spend key is
/// derived from it, so the same index always yields the same address.
SubstratePrivateKey polkadotAccount(int index) {
  final seed = QuickCrypto.sha256Hash([
    ...'polkadot_dart/example'.codeUnits,
    ...utf8.encode(':$index'),
  ]);
  return SubstratePrivateKey.fromPrivateKey(
    keyBytes: seed,
    algorithm: SubstrateKeyAlgorithm.ed25519,
  );
}

/// Deterministic account address for [index].
SubstrateAddress polkadotAddress(int index) =>
    polkadotAccount(index).toAddress(ss58Format: polkadotSs58);

/// SCALE-encodes a `System.Account` value giving [free] planck.
///
/// Layout: nonce u32, consumers u32, providers u32, sufficients u32,
/// data { free u128, reserved u128, frozen u128, flags u128 } — all
/// little-endian.
String accountInfoValue({required BigInt free}) {
  final bytes = <int>[
    ...IntUtils.toBytes(0, length: 4, byteOrder: Endian.little), // nonce
    ...IntUtils.toBytes(0, length: 4, byteOrder: Endian.little), // consumers
    ...IntUtils.toBytes(1, length: 4, byteOrder: Endian.little), // providers
    ...IntUtils.toBytes(0, length: 4, byteOrder: Endian.little), // sufficients
    ...BigintUtils.toBytes(free, length: 16, byteOrder: Endian.little),
    ...BigintUtils.toBytes(BigInt.zero, length: 16, byteOrder: Endian.little),
    ...BigintUtils.toBytes(BigInt.zero, length: 16, byteOrder: Endian.little),
    ...BigintUtils.toBytes(BigInt.zero, length: 16, byteOrder: Endian.little),
  ];
  return '0x${BytesUtils.toHexString(bytes)}';
}

/// Funds [address] in the fork if its free balance is below [minimum].
///
/// Writes a `System.Account` entry via `dev_setStorage` (Chopsticks-only).
Future<void> ensureFunded(
  MetadataWithProvider meta,
  BaseSubstrateAddress address, {
  BigInt? minimum,
}) async {
  final min = minimum ?? BigInt.zero;
  final current = await SubstrateQuickStorageApi.system.accountWithDataFrame(
    api: meta.metadata.api,
    rpc: meta.provider,
    address: address,
  );
  if (current.data.free >= min) return;
  final storageKey = meta.metadata.api
      .generateStorageKey(
        palletNameOrIndex: 'System',
        methodName: 'Account',
        value: address.toBytes(),
      )
      .key;
  await meta.provider.request(
    DevSetStorage([
      [storageKey, accountInfoValue(free: min)],
    ]),
  );
}

/// Prints a two-column `name : value` line.
String field(String name, String value) {
  return '  ${name.padRight(20)} $value';
}

/// Returns the free native balance (planck) of [address].
Future<BigInt> freeBalance(
  MetadataWithProvider meta,
  BaseSubstrateAddress address,
) async {
  final account = await SubstrateQuickStorageApi.system.accountWithDataFrame(
    api: meta.metadata.api,
    rpc: meta.provider,
    address: address,
  );
  return account.data.free;
}

/// Formats [amount] planck as a decimal string (12 decimals, like WND/DOT).
String formatUnits(BigInt amount) {
  final digits = amount.toString().padLeft(13, '0');
  final whole = digits.substring(0, digits.length - 12);
  final fraction = digits
      .substring(digits.length - 12)
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? whole : '$whole.$fraction';
}

/// Builds a raw encoded call from a JSON [value].
///
/// For pallets that have no typed call class, `value` is the inner params map
/// (e.g. `{'id': 1337, 'admin': {'Id': ...}}`); it is wrapped as `{method: value}`.
SubstrateEncodedCallParams rawCall(
  MetadataWithProvider meta, {
  required String pallet,
  required String method,
  required Map<String, dynamic> value,
}) {
  return SubstrateEncodedCallParams(
    pallet: pallet,
    method: method,
    bytes: meta.metadata.api.encodeCall(
      palletNameOrIndex: pallet,
      value: {method: value},
    ),
  );
}

/// Signs and submits [call] from [owner], waiting for block inclusion.
///
/// Returns the submission result, or `null` if the transaction failed.
Future<SubstrateTransactionSubmitionResult?> send(
  MetadataWithProvider meta, {
  required BaseSubstrateAddress owner,
  required SubstrateTransactionSigner signer,
  required SubstrateEncodedCallParams call,
}) async {
  final result = await SubstrateTransactionBuilder
      .buildSignAndWatchTransactionStaticAsync(
        owner: owner,
        signer: signer,
        calls: SubstrateTransactionSubmitableParams(calls: [call]),
        provider: meta,
      );
  return result.status.isSuccess ? result : null;
}

/// Returns the free balance of [assetId] held by [address], or `null` when the
/// account has no entry for that asset.
Future<BigInt?> assetBalance(
  MetadataWithProvider meta, {
  required BaseSubstrateAddress address,
  required BigInt assetId,
}) async {
  final entries = await SubstrateQuickStorageApi.assets.account(
    api: meta.metadata.api,
    rpc: meta.provider,
    address: address,
    assetsIdentifier: [assetId],
  );
  if (entries.isEmpty) return null;
  final json = entries.first.$2.response;
  return BigintUtils.parse(json['balance']);
}

/// Returns the next asset id that `Assets.create` will accept.
///
/// Westend Asset Hub configures the Assets pallet with an auto-incrementing
/// `AssetIdAllocator`, so `create` only succeeds when `id` equals the current
/// `NextAssetId` storage value.
Future<BigInt> nextAssetId(MetadataWithProvider meta) async {
  final value = await meta.metadata.api.getStorageRequest(
    request: GetStorageRequest<Object?, Object>(
      palletNameOrIndex: 'Assets',
      methodName: 'NextAssetId',
      onNullResponse: (_) => null,
      onJsonResponse: (response, _, __) => response,
    ),
    rpc: meta.provider,
  );
  return BigintUtils.parse(value);
}