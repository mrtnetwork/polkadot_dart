// ignore_for_file: avoid_print
// Convert /tmp/meta/<slug>.hex into test fixtures:
//   test/metadatas/mt_<name>.hex   (all versions; byte round-trip source)
//   test/metadatas/mt_<name>.json  (V14 only; JSON codec source)
//   test/metadatas/mt_manifest.json (file -> {version, network})
// Usage: dart run tool/tmp_make_fixtures.dart
import 'dart:convert';
import 'dart:io';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

const names = <String, String>{
  'ajuna': 'mt_ajuna',
  'darwinia2': 'mt_darwinia2',
  'energywebx': 'mt_energy_web_x',
  'jamton': 'mt_jamton',
  'moonbeam': 'mt_moonbeam',
  'phala': 'mt_phala',
  'unique': 'mt_unique',
  'xode': 'mt_xode',
  'polkadot': 'mt_polkadot',
  'polkadot_assethub': 'mt_polkadot_assethub',
  'polkadot_bridgehub': 'mt_polkadot_bridgehub',
  'polkadot_collectives': 'mt_polkadot_collectives',
  'polkadot_people': 'mt_polkadot_people',
  'polkadot_coretime': 'mt_polkadot_coretime',
  'acala': 'mt_acala',
  'hydration': 'mt_hydration',
  'astar': 'mt_astar',
  'bifrost': 'mt_bifrost',
  'centrifuge': 'mt_centrifuge',
  'zeitgeist': 'mt_zeitgeist',
  'manta': 'mt_manta',
  'pendulum': 'mt_pendulum',
  'kilt': 'mt_kilt',
  'frequency': 'mt_frequency',
  'mythos': 'mt_mythos',
  'laos': 'mt_laos_network',
  'neuroweb': 'mt_neuroweb',
};

Future<void> main() async {
  const outDir = 'test/metadatas';
  final manifest = <String, Map<String, Object>>{};
  // seed manifest with pre-existing V14 JSON dumps (foreign shape except mythos)
  for (final f in Directory(outDir).listSync().whereType<File>()) {
    final n = f.uri.pathSegments.last;
    if (n.startsWith('mt_') && n.endsWith('.json')) {
      manifest[n] = {'version': 14, 'network': n};
    }
  }
  for (final e in names.entries) {
    final src = File('/tmp/meta/${e.key}.hex');
    if (!src.existsSync()) continue;
    final hex = src.readAsStringSync().trim();
    if (hex.isEmpty) continue;
    List<int> bytes;
    try {
      bytes = BytesUtils.fromHexString(hex);
      final vm = VersionedMetadata.fromBytes(bytes);
      final v = vm.version;
      File('$outDir/${e.value}.hex').writeAsStringSync(hex);
      manifest['${e.value}.hex'] = {'version': v, 'network': e.key};
      print('${e.key}: version=$v bytes=${bytes.length}');
      if (v == 14) {
        final md = vm.metadata as MetadataV14;
        File('$outDir/${e.value}.json').writeAsStringSync(
          jsonEncode(md.serializeJson()),
        );
        manifest['${e.value}.json'] = {'version': 14, 'network': e.key};
      }
    } catch (err) {
      print('${e.key}: DECODE-FAIL ${'$err'.split('\n').first}');
    }
  }
  // mythos hex from earlier capture
  try {
    final raw =
        jsonDecode(File('/tmp/mythos_meta.json').readAsStringSync()) as Map;
    final hex = (raw['result'] as String).trim();
    File('$outDir/mt_mythos.hex').writeAsStringSync(hex);
    manifest['mt_mythos.hex'] = {'version': 14, 'network': 'mythos'};
    print('mythos: hex saved');
  } catch (err) {
    print('mythos hex: $err');
  }
  manifest['mt_mythos.json'] = {'version': 14, 'network': 'mythos'};
  File('$outDir/mt_manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest),
  );
  print('manifest: ${manifest.length} entries');
  exit(0);
}
