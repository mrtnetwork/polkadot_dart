// import 'package:blockchain_utils/blockchain_utils.dart';
// import 'package:polkadot_dart/polkadot_dart.dart';

// import 'metadata/v15_metadata_hex.dart';

// extension ToHex on List<int> {
//   String toHex() => BytesUtils.toHexString(this);
// }

// void main() {
//   final metadata = VersionedMetadata<MetadataV15>.fromBytes(
//           BytesUtils.fromHexString(metadataV15))
//       .metadata;
//   final api = MetadataApi(metadata);
//   const lookupid = 15;

//   final template = api.getLookupTemplate(lookupid);

//   final templateValue = {
//     "type": "Map",
//     "value": {
//       "logs": {
//         "type": "Vec<DigestItem>",
//         "value": [
//           {
//             "type": "Enum",
//             "key": "Other",
//             "value": {"type": "Vec<U8>", "value": List<int>.filled(12, 1)},
//             "variants": {
//               "PreRuntime": {
//                 "type": "Tuple",
//                 "value": [
//                   {
//                     "type": "[U8;4]",
//                     "value": [1, 2, 3, 4]
//                   },
//                   {"type": "Vec<U8>", "value": List<int>.filled(1, 0)}
//                 ]
//               },
//               "Consensus": {
//                 "type": "Tuple",
//                 "value": [
//                   {"type": "[U8;4]", "value": null},
//                   {"type": "Vec<U8>", "value": null}
//                 ]
//               },
//               "Seal": {
//                 "type": "Tuple",
//                 "value": [
//                   {"type": "[U8;4]", "value": null},
//                   {"type": "Vec<U8>", "value": null}
//                 ]
//               },
//               "Other": {"type": "Vec<U8>", "value": null},
//               "RuntimeEnvironmentUpdated": null
//             }
//           }
//         ]
//       }
//     }
//   };

//   try {
//     final templateResult = api.registry
//         .getValue(id: lookupid, value: templateValue, fromTemplate: true);
//     print(templateResult);

//     final standardResult = api.registry
//         .getValue(id: lookupid, value: templateResult, fromTemplate: false);

//     print(standardResult);
//     final encode = api.encodeLookup(
//         id: lookupid, value: standardResult, fromTemplate: false);
//     print(encode.toHex());
//     // assert(
//     //   encode.toHex(),
//     // );
//   } catch (e, s) {
//     print("has Errror $e $s");
//   }
// }
