import 'dart:convert';
import 'dart:io';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:polkadot_dart/src/api/runtime/runtime/layouts/layouts.dart';
import 'package:test/test.dart';

import '../repository/polkadot_v15.dart';
import '../repository/kusama_v15.dart';
import '../utils.dart';

/// Layout-resolution guard: every runtime-API method layout in
/// [SubstrateRuntimeApiConstants] must resolve its SCALE types against real
/// chain metadata. A missing type here means the fallback `state_call` path
/// would throw at runtime on that chain.
///
/// Versions mirror [SubstrateRuntimeApis] supported versions.
void runtimeLayoutsTest() {
  const versions = <String, List<int>>{
    'dry_run_call': [1, 2],
    'dry_run_xcm': [1, 2],
    'query_acceptable_payment_assets': [1, 2],
    'query_xcm_weight': [1, 2],
    'query_weight_to_asset_fee': [1, 2],
    'query_delivery_fees': [1, 2],
    'quote_price_exact_tokens_for_tokens': [1],
    'quote_price_tokens_for_exact_tokens': [1],
    'call': [6],
  };
  MetadataApi apiOf(String hex) {
    final vm = VersionedMetadata.fromBytes(BytesUtils.fromHexString(hex));
    return MetadataApi(vm.metadata as LatestMetadataInterface);
  }

  group('runtime-layouts', () {
    test('all builders resolve on relay V15 metadata', () {
      for (final entry
          in {'polkadot': polkadotV15, 'kusama': kusamaV15}.entries) {
        final api = apiOf(entry.value);
        for (final kv in SubstrateRuntimeApiConstants.apis.entries) {
          final vs = versions[kv.key];
          expect(vs, isNotNull, reason: 'no versions mapped for ${kv.key}');
          for (final v in vs!) {
            kv.value.inputBuilder(api, v);
            kv.value.outputBuilder(api, v);
          }
        }
      }
    });

    // V14 JSON round-trip over the SDK-native mt_mythos dump (captured via
    // serializeJson, so shapes match the codec). Foreign-format dumps
    // (mt_moonbeam etc., with addressType/callType keys) are intentionally
    // not loaded: they were not produced by this SDK.
    test(
      'V14 JSON dump round-trips losslessly',
      skip: !native ? 'filesystem fixtures unavailable' : null,
      () {
        final raw = jsonDecode(
          File('test/metadatas/mt_mythos.json').readAsStringSync(),
        );
        final md = MetadataV14.deserializeJson(raw as Map<String, dynamic>);
        final back = md.serializeJson();
        final raw2 = (back['lookup'] as Map)['types'] as List;
        final raw1 = (raw['lookup'] as Map)['types'] as List;
        expect(raw2.length, raw1.length);
        expect(back['pallets'], (raw['pallets'] as List));
        expect(back['extrinsic'], raw['extrinsic']);
      },
    );

    test(
      'every stored SCALE fixture byte round-trips',
      skip: !native ? 'filesystem fixtures unavailable' : null,
      () {
        final manifest =
            jsonDecode(
                  File('test/metadatas/mt_manifest.json').readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect(manifest, isNotEmpty);
        for (final entry in manifest.entries) {
          final file = entry.key;
          if (!file.endsWith('.hex')) continue;
          final hex = File('test/metadatas/$file').readAsStringSync().trim();
          final bytes = BytesUtils.fromHexString(hex);
          final vm = VersionedMetadata.fromBytes(bytes);
          expect(vm.serialize(), bytes, reason: 'round-trip $file');
          expect(
            vm.version,
            (entry.value as Map)['version'],
            reason: 'manifest version $file',
          );
        }
      },
    );

    test(
      'every stored V14 JSON fixture round-trips',
      skip: !native ? 'filesystem fixtures unavailable' : null,
      () {
        final manifest =
            jsonDecode(
                  File('test/metadatas/mt_manifest.json').readAsStringSync(),
                )
                as Map<String, dynamic>;
        for (final entry in manifest.entries) {
          final file = entry.key;
          if (!file.endsWith('.json')) continue;
          if ((entry.value as Map)['version'] != 14) continue;
          final raw = jsonDecode(
            File('test/metadatas/$file').readAsStringSync(),
          );
          // Only SDK-native dumps load (extrinsic {type, version,
          // signedExtensions}); foreign dumps (addressType/callType keys) are
          // skipped until regenerated (see mt_manifest notes).
          final ext = (raw as Map)['extrinsic'];
          if (ext is! Map || ext.containsKey('addressType')) continue;
          final md = MetadataV14.deserializeJson(raw as Map<String, dynamic>);
          final back = md.serializeJson();
          expect(
            (back['lookup'] as Map)['types'],
            (raw['lookup'] as Map)['types'],
            reason: 'lookup $file',
          );
          expect(
            back['extrinsic'],
            raw['extrinsic'],
            reason: 'extrinsic $file',
          );
        }
      },
    );
  });
}

void main() {
  PolkadotDartUtilsTestApi.runTest(runtimeLayoutsTest, 'Runtime Layouts');
}
