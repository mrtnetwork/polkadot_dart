class SubstrateRPCMethods {
  final String value;
  final String summery;

  /// The string value of the method.
  const SubstrateRPCMethods._(this.value, this.summery);

  /// author
  static const SubstrateRPCMethods hasKey = SubstrateRPCMethods._(
      "author_hasKey",
      "Returns true if the keystore has private keys for the given public key and key type.");
  static const SubstrateRPCMethods hasSessionKeys = SubstrateRPCMethods._(
      "author_hasSessionKeys",
      "Returns true if the keystore has private keys for the given session public keys.");
  static const SubstrateRPCMethods insertKey = SubstrateRPCMethods._(
      "author_insertKey", " Insert a key into the keystore.");
  static const SubstrateRPCMethods pendingExtrinsics = SubstrateRPCMethods._(
      "author_pendingExtrinsics",
      "Returns all pending extrinsics, potentially grouped by sender");
  static const SubstrateRPCMethods removeExtrinsic = SubstrateRPCMethods._(
      "author_removeExtrinsic",
      "Remove given extrinsic from the pool and temporarily ban it to prevent reimporting");
  static const SubstrateRPCMethods rotateKeys = SubstrateRPCMethods._(
      "author_rotateKeys",
      "Generate new session keys and returns the corresponding public keys");
  static const SubstrateRPCMethods submitAndWatchExtrinsic =
      SubstrateRPCMethods._("author_submitAndWatchExtrinsic",
          "Submit and subscribe to watch an extrinsic until unsubscribed");
  static const SubstrateRPCMethods submitExtrinsic = SubstrateRPCMethods._(
      "author_submitExtrinsic",
      "Submit a fully formatted extrinsic for block inclusion");

  /// babe
  static const SubstrateRPCMethods epochAuthorship = SubstrateRPCMethods._(
      "babe_epochAuthorship",
      "Returns data about which slots (primary or secondary) can be claimed in the current epoch with the keys in the keystore");

  /// beefy
  static const SubstrateRPCMethods getFinalizedHead = SubstrateRPCMethods._(
      "beefy_getFinalizedHead",
      "Returns hash of the latest BEEFY finalized block as seen by this client.");
  static const SubstrateRPCMethods subscribeJustifications = SubstrateRPCMethods._(
      "beefy_subscribeJustifications",
      "Returns the block most recently finalized by BEEFY, alongside its justification.");

  /// chain
  static const SubstrateRPCMethods getBlock = SubstrateRPCMethods._(
      "chain_getBlock", "Get header and body of a relay chain block");
  static const SubstrateRPCMethods getBlockHash = SubstrateRPCMethods._(
      "chain_getBlockHash", "Get the block hash for a specific block");
  static const SubstrateRPCMethods chainGetFinalizedHead =
      SubstrateRPCMethods._("chain_getFinalizedHead",
          "Get hash of the last finalized block in the canon chain");
  static const SubstrateRPCMethods getHeader = SubstrateRPCMethods._(
      "chain_getHeader", "Retrieves the header for a specific block");
  static const SubstrateRPCMethods subscribeAllHeads = SubstrateRPCMethods._(
      "chain_subscribeAllHeads",
      "Retrieves the newest header via subscription");
  static const SubstrateRPCMethods subscribeFinalizedHeads =
      SubstrateRPCMethods._("chain_subscribeFinalizedHeads",
          "Retrieves the best finalized header via subscription");
  static const SubstrateRPCMethods subscribeNewHeads = SubstrateRPCMethods._(
      "chain_subscribeNewHeads", "Retrieves the best header via subscription");

  /// childstate
  static const SubstrateRPCMethods getKeys = SubstrateRPCMethods._(
      "childstate_getKeys",
      "Returns the keys with prefix from a child storage, leave empty to get all the keys");
  static const SubstrateRPCMethods getKeysPaged = SubstrateRPCMethods._(
      "childstate_getKeysPaged",
      "Returns the keys with prefix from a child storage with pagination support");
  static const SubstrateRPCMethods getStorage = SubstrateRPCMethods._(
      "childstate_getStorage",
      "Returns a child storage entry at a specific block state");
  static const SubstrateRPCMethods getStorageEntries = SubstrateRPCMethods._(
      "childstate_getStorageEntries",
      "Returns child storage entries for multiple keys at a specific block state");
  static const SubstrateRPCMethods getStorageHash = SubstrateRPCMethods._(
      "childstate_getStorageHash",
      "Returns the hash of a child storage entry at a block state");
  static const SubstrateRPCMethods getStorageSize = SubstrateRPCMethods._(
      "childstate_getStorageSize",
      "Returns the size of a child storage entry at a block state");

  /// contracts
  static const SubstrateRPCMethods call =
      SubstrateRPCMethods._("contracts_call", "Executes a call to a contract");
  static const SubstrateRPCMethods contractGetStorage = SubstrateRPCMethods._(
      "contracts_getStorage",
      "Returns the value under a specified storage key in a contract");
  static const SubstrateRPCMethods instantiate = SubstrateRPCMethods._(
      "contracts_instantiate", "Instantiate a new contract");
  static const SubstrateRPCMethods rentProjection = SubstrateRPCMethods._(
      "contracts_rentProjection",
      "Returns the projected time a given contract will be able to sustain paying its rent");
  static const SubstrateRPCMethods uploadCode = SubstrateRPCMethods._(
      "contracts_upload_code",
      "Upload new code without instantiating a contract from it");

  /// dev
  static const SubstrateRPCMethods getBlockStats = SubstrateRPCMethods._(
      "dev_getBlockStats",
      "Reexecute the specified block_hash and gather statistics while doing so");

  /// engine
  static const SubstrateRPCMethods createBlock = SubstrateRPCMethods._(
      "engine_createBlock",
      "Instructs the manual-seal authorship task to create a new block");
  static const SubstrateRPCMethods finalizeBlock = SubstrateRPCMethods._(
      "engine_finalizeBlock",
      "Instructs the manual-seal authorship task to finalize a block");

  /// grandpa
  static const SubstrateRPCMethods proveFinality = SubstrateRPCMethods._(
      "grandpa_proveFinality",
      "Prove finality for the given block number, returning the Justification for the last block in the set.");
  static const SubstrateRPCMethods roundState = SubstrateRPCMethods._(
      "grandpa_roundState",
      "Returns the state of the current best round state as well as the ongoing background rounds");
  static const SubstrateRPCMethods grandpaSubscribeJustifications =
      SubstrateRPCMethods._("grandpa_subscribeJustifications",
          "Subscribes to grandpa justifications");

  /// mmr
  static const SubstrateRPCMethods generateProof = SubstrateRPCMethods._(
      "mmr_generateProof", "Generate MMR proof for the given block numbers.");
  static const SubstrateRPCMethods root = SubstrateRPCMethods._(
      "mmr_root", "Get the MMR root hash for the current best block");
  static const SubstrateRPCMethods verifyProof =
      SubstrateRPCMethods._("mmr_verifyProof", "Verify an MMR proof");
  static const SubstrateRPCMethods verifyProofStateless = SubstrateRPCMethods._(
      "mmr_verifyProofStateless",
      "Verify an MMR proof statelessly given an mmr_root");

  /// offchain
  static const SubstrateRPCMethods localStorageGet = SubstrateRPCMethods._(
      "offchain_localStorageGet",
      "Get offchain local storage under given key and prefix");
  static const SubstrateRPCMethods localStorageSet = SubstrateRPCMethods._(
      "offchain_localStorageSet",
      "Set offchain local storage under given key and prefix");

  /// payment
  static const SubstrateRPCMethods queryFeeDetails = SubstrateRPCMethods._(
      "payment_queryFeeDetails",
      "Query the detailed fee of a given encoded extrinsic");
  static const SubstrateRPCMethods queryInfo = SubstrateRPCMethods._(
      "payment_queryInfo",
      "Retrieves the fee information for an encoded extrinsic");

  /// rpc
  static const SubstrateRPCMethods rpc = SubstrateRPCMethods._("rpc_methods",
      "Retrieves the list of RPC methods that are exposed by the node");

  /// state
  static const SubstrateRPCMethods stateCall = SubstrateRPCMethods._(
      "state_call", "Perform a call to a builtin on the chain");
  static const SubstrateRPCMethods getChildKeys = SubstrateRPCMethods._(
      "state_getChildKeys",
      "Retrieves the keys with prefix of a specific child storage");
  static const SubstrateRPCMethods getChildReadProof = SubstrateRPCMethods._(
      "state_getChildReadProof",
      "Returns proof of storage for child key entries at a specific block state");
  static const SubstrateRPCMethods getChildStorage = SubstrateRPCMethods._(
      "state_getChildStorage", "Retrieves the child storage for a key");
  static const SubstrateRPCMethods getChildStorageHash = SubstrateRPCMethods._(
      "state_getChildStorageHash", "Retrieves the child storage hash");
  static const SubstrateRPCMethods getChildStorageSize = SubstrateRPCMethods._(
      "state_getChildStorageSize", "Retrieves the child storage size");
  static const SubstrateRPCMethods stateGetKeys = SubstrateRPCMethods._(
      "state_getKeys", "Retrieves the keys with a certain prefix");
  static const SubstrateRPCMethods stateGetKeysPaged = SubstrateRPCMethods._(
      "state_getKeysPaged",
      "Returns the keys with prefix with pagination support.");
  static const SubstrateRPCMethods getMetadata = SubstrateRPCMethods._(
      "state_getMetadata", "Returns the runtime metadata");
  static const SubstrateRPCMethods getPairs = SubstrateRPCMethods._(
      "state_getPairs",
      "Returns the keys with prefix, leave empty to get all the keys (deprecated: Use getKeysPaged)");
  static const SubstrateRPCMethods getReadProof = SubstrateRPCMethods._(
      "state_getReadProof",
      "Returns proof of storage entries at a specific block state");
  static const SubstrateRPCMethods getRuntimeVersion = SubstrateRPCMethods._(
      "state_getRuntimeVersion", "Get the runtime version");
  static const SubstrateRPCMethods stateGetStorage = SubstrateRPCMethods._(
      "state_getStorage", "Retrieves the storage for a key");
  static const SubstrateRPCMethods stateGetStorageHash = SubstrateRPCMethods._(
      "state_getStorageHash", "Retrieves the storage hash");
  static const SubstrateRPCMethods stateGetStorageSize = SubstrateRPCMethods._(
      "state_getStorageSize", "Retrieves the storage size");
  static const SubstrateRPCMethods queryStorage = SubstrateRPCMethods._(
      "state_queryStorage",
      "Query historical storage entries (by key) starting from a start block");
  static const SubstrateRPCMethods queryStorageAt = SubstrateRPCMethods._(
      "state_queryStorageAt",
      "Query storage entries (by key) starting at block hash given as the second parameter");
  static const SubstrateRPCMethods subscribeRuntimeVersion =
      SubstrateRPCMethods._("state_subscribeRuntimeVersion",
          "Retrieves the runtime version via subscription");
  static const SubstrateRPCMethods subscribeStorage = SubstrateRPCMethods._(
      "state_subscribeStorage",
      "Subscribes to storage changes for the provided keys");
  static const SubstrateRPCMethods traceBlock = SubstrateRPCMethods._(
      "state_traceBlock",
      "Provides a way to trace the re-execution of a single block");
  static const SubstrateRPCMethods trieMigrationStatus = SubstrateRPCMethods._(
      "state_trieMigrationStatus", "Check current migration state");

  /// syncstate
  static const SubstrateRPCMethods genSyncSpec = SubstrateRPCMethods._(
      "sync_state_genSyncSpec",
      "Returns the json-serialized chainspec running the node, with a sync state.");

  /// system
  static const SubstrateRPCMethods systemHealth = SubstrateRPCMethods._(
      "system_health", "Return health status of the node");
  static const SubstrateRPCMethods accountNextIndex = SubstrateRPCMethods._(
      "system_accountNextIndex",
      "Retrieves the next accountIndex as available on the node");
  static const SubstrateRPCMethods addLogFilter = SubstrateRPCMethods._(
      "system_addLogFilter",
      "Adds the supplied directives to the current log filter");
  static const SubstrateRPCMethods addReservedPeer =
      SubstrateRPCMethods._("system_addReservedPeer", "Adds a reserved peer");
  static const SubstrateRPCMethods chain =
      SubstrateRPCMethods._("system_chain", "Retrieves the chain");
  static const SubstrateRPCMethods chainType =
      SubstrateRPCMethods._("system_chainType", "Retrieves the chain type");
  static const SubstrateRPCMethods dryRun = SubstrateRPCMethods._(
      "system_dryRun", "Dry run an extrinsic at a given block");
  static const SubstrateRPCMethods health =
      SubstrateRPCMethods._("health", "Return health status of the node");
  static const SubstrateRPCMethods localListenAddresses = SubstrateRPCMethods._(
      "system_localListenAddresses",
      "The addresses include a trailing /p2p/ with the local PeerId, and are thus suitable to be passed to addReservedPeer or as a bootnode address for example");
  static const SubstrateRPCMethods localPeerId = SubstrateRPCMethods._(
      "system_localPeerId", "Returns the base58-encoded PeerId of the node");
  static const SubstrateRPCMethods name =
      SubstrateRPCMethods._("system_name", "Retrieves the node name");
  static const SubstrateRPCMethods networkState = SubstrateRPCMethods._(
      "system_networkState", "Returns current state of the network");
  static const SubstrateRPCMethods nodeRoles = SubstrateRPCMethods._(
      "system_nodeRoles", "Returns the roles the node is running as");
  static const SubstrateRPCMethods peers = SubstrateRPCMethods._(
      "system_peers", "Returns the currently connected peers");
  static const SubstrateRPCMethods properties = SubstrateRPCMethods._(
      "system_properties",
      "Get a custom set of properties as a JSON object, defined in the chain spec");

  static const SubstrateRPCMethods removeReservedPeer = SubstrateRPCMethods._(
      "system_removeReservedPeer", "Remove a reserved peer");
  static const SubstrateRPCMethods reservedPeers = SubstrateRPCMethods._(
      "system_reservedPeers", "Returns the list of reserved peers");
  static const SubstrateRPCMethods resetLogFilter = SubstrateRPCMethods._(
      "system_resetLogFilter", "Resets the log filter to Substrate defaults");
  static const SubstrateRPCMethods syncState = SubstrateRPCMethods._(
      "system_syncState", "Returns the state of the syncing of the node");
  static const SubstrateRPCMethods version = SubstrateRPCMethods._(
      "system_version", "Retrieves the version of the node");

  static List<SubstrateRPCMethods> values = [
    SubstrateRPCMethods.hasKey,
    SubstrateRPCMethods.hasSessionKeys,
    SubstrateRPCMethods.insertKey,
    SubstrateRPCMethods.pendingExtrinsics,
    SubstrateRPCMethods.removeExtrinsic,
    SubstrateRPCMethods.rotateKeys,
    SubstrateRPCMethods.submitAndWatchExtrinsic,
    SubstrateRPCMethods.submitExtrinsic,
    SubstrateRPCMethods.epochAuthorship,
    SubstrateRPCMethods.getFinalizedHead,
    SubstrateRPCMethods.subscribeJustifications,
    SubstrateRPCMethods.getBlock,
    SubstrateRPCMethods.getBlockHash,
    SubstrateRPCMethods.chainGetFinalizedHead,
    SubstrateRPCMethods.getHeader,
    SubstrateRPCMethods.subscribeAllHeads,
    SubstrateRPCMethods.subscribeFinalizedHeads,
    SubstrateRPCMethods.subscribeNewHeads,
    SubstrateRPCMethods.getKeys,
    SubstrateRPCMethods.getKeysPaged,
    SubstrateRPCMethods.getStorage,
    SubstrateRPCMethods.getStorageEntries,
    SubstrateRPCMethods.getStorageHash,
    SubstrateRPCMethods.getStorageSize,
    SubstrateRPCMethods.call,
    SubstrateRPCMethods.contractGetStorage,
    SubstrateRPCMethods.instantiate,
    SubstrateRPCMethods.rentProjection,
    SubstrateRPCMethods.uploadCode,
    SubstrateRPCMethods.getBlockStats,
    SubstrateRPCMethods.createBlock,
    SubstrateRPCMethods.finalizeBlock,
    SubstrateRPCMethods.proveFinality,
    SubstrateRPCMethods.roundState,
    SubstrateRPCMethods.grandpaSubscribeJustifications,
    SubstrateRPCMethods.generateProof,
    SubstrateRPCMethods.root,
    SubstrateRPCMethods.verifyProof,
    SubstrateRPCMethods.verifyProofStateless,
    SubstrateRPCMethods.localStorageGet,
    SubstrateRPCMethods.localStorageSet,
    SubstrateRPCMethods.queryFeeDetails,
    SubstrateRPCMethods.queryInfo,
    SubstrateRPCMethods.rpc,
    SubstrateRPCMethods.stateCall,
    SubstrateRPCMethods.getChildKeys,
    SubstrateRPCMethods.getChildReadProof,
    SubstrateRPCMethods.getChildStorage,
    SubstrateRPCMethods.getChildStorageHash,
    SubstrateRPCMethods.getChildStorageSize,
    SubstrateRPCMethods.stateGetKeys,
    SubstrateRPCMethods.stateGetKeysPaged,
    SubstrateRPCMethods.getMetadata,
    SubstrateRPCMethods.getPairs,
    SubstrateRPCMethods.getReadProof,
    SubstrateRPCMethods.getRuntimeVersion,
    SubstrateRPCMethods.stateGetStorage,
    SubstrateRPCMethods.stateGetStorageHash,
    SubstrateRPCMethods.stateGetStorageSize,
    SubstrateRPCMethods.queryStorage,
    SubstrateRPCMethods.queryStorageAt,
    SubstrateRPCMethods.subscribeRuntimeVersion,
    SubstrateRPCMethods.subscribeStorage,
    SubstrateRPCMethods.traceBlock,
    SubstrateRPCMethods.trieMigrationStatus,
    SubstrateRPCMethods.genSyncSpec,
    SubstrateRPCMethods.accountNextIndex,
    SubstrateRPCMethods.addLogFilter,
    SubstrateRPCMethods.addReservedPeer,
    SubstrateRPCMethods.chain,
    SubstrateRPCMethods.chainType,
    SubstrateRPCMethods.dryRun,
    SubstrateRPCMethods.health,
    SubstrateRPCMethods.localListenAddresses,
    SubstrateRPCMethods.localPeerId,
    SubstrateRPCMethods.name,
    SubstrateRPCMethods.networkState,
    SubstrateRPCMethods.nodeRoles,
    SubstrateRPCMethods.peers,
    SubstrateRPCMethods.properties,
    SubstrateRPCMethods.removeReservedPeer,
    SubstrateRPCMethods.reservedPeers,
    SubstrateRPCMethods.resetLogFilter,
    SubstrateRPCMethods.syncState,
    SubstrateRPCMethods.version,
  ];
}

// static const SubstrateRPCMethods insertKey = SubstrateRPCMethods._("", "");
