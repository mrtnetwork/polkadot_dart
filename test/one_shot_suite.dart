import 'utils.dart';
import 'backend_identity_test.dart' as f17;
import 'encoding/address_test.dart' as f0;
import 'encoding/encodable_request_params_test.dart' as f1;
import 'encoding/encoding_test.dart' as f2;
import 'encoding/exception_test.dart' as f3;
import 'encoding/lookup_spec_1011000_metadata_test.dart' as f4;
import 'encoding/lookup_test.dart' as f5;
import 'metadata/metadata_call_test.dart' as f6;
import 'metadata/metadata_lookup_test.dart' as f7;
import 'metadata/metadata_test.dart' as f8;
import 'metadata/template_test.dart' as f9;
import 'networks/controller_finder_test.dart' as f10;
import 'networks/runtime_layouts_test.dart' as f11;
import 'provider/quick_client_test.dart' as f12;
import 'xcm/xcm_v2_test.dart' as f13;
import 'xcm/xcm_v3_test.dart' as f14;
import 'xcm/xcm_v4_test.dart' as f15;
import 'xcm/xcm_v5_test.dart' as f16;

Future<void> runOneShotSuite() async {
  PolkadotDartUtilsTestApi.runTest(() {
    f17.backendIdentityTest();
    f0.addressTest();
    f1.encodableRequestParamsTest();
    f2.encodingTest();
    f3.exceptionTest();
    f4.lookupSpec1011000MetadataTest();
    f5.lookupTest();
    f6.metadataCallTest();
    f7.metadataLookupTest();
    f8.metadataTest();
    f9.templateTest();
    f10.controllerFinderTest();
    f11.runtimeLayoutsTest();
    f12.quickClientTest();
    f13.xcmV2Test();
    f14.xcmV3Test();
    f15.xcmV4Test();
    f16.xcmV5Test();
  }, 'Polkadot One Shot');
}
