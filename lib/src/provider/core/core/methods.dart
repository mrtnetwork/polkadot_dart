class SubstrateRequestMethods {
  final String value;
  final String summery;

  /// The string value of the method.
  const SubstrateRequestMethods._(this.value, this.summery);

  /// author
  static const SubstrateRequestMethods hasKey = SubstrateRequestMethods._(
      "author_hasKey",
      "Returns true if the keystore has private keys for the given public key and key type.");
  static const SubstrateRequestMethods hasSessionKeys = SubstrateRequestMethods._(
      "author_hasSessionKeys",
      "Returns true if the keystore has private keys for the given session public keys.");
  static const SubstrateRequestMethods insertKey = SubstrateRequestMethods._(
      "author_insertKey", " Insert a key into the keystore.");
  static const SubstrateRequestMethods pendingExtrinsics =
      SubstrateRequestMethods._("author_pendingExtrinsics",
          "Returns all pending extrinsics, potentially grouped by sender");
  static const SubstrateRequestMethods removeExtrinsic = SubstrateRequestMethods._(
      "author_removeExtrinsic",
      "Remove given extrinsic from the pool and temporarily ban it to prevent reimporting");
  static const SubstrateRequestMethods rotateKeys = SubstrateRequestMethods._(
      "author_rotateKeys",
      "Generate new session keys and returns the corresponding public keys");
  static const SubstrateRequestMethods submitAndWatchExtrinsic =
      SubstrateRequestMethods._("author_submitAndWatchExtrinsic",
          "Submit and subscribe to watch an extrinsic until unsubscribed");
  static const SubstrateRequestMethods submitExtrinsic =
      SubstrateRequestMethods._("author_submitExtrinsic",
          "Submit a fully formatted extrinsic for block inclusion");

  /// babe
  static const SubstrateRequestMethods epochAuthorship = SubstrateRequestMethods._(
      "babe_epochAuthorship",
      "Returns data about which slots (primary or secondary) can be claimed in the current epoch with the keys in the keystore");

  /// beefy
  static const SubstrateRequestMethods getFinalizedHead = SubstrateRequestMethods._(
      "beefy_getFinalizedHead",
      "Returns hash of the latest BEEFY finalized block as seen by this client.");
  static const SubstrateRequestMethods subscribeJustifications =
      SubstrateRequestMethods._("beefy_subscribeJustifications",
          "Returns the block most recently finalized by BEEFY, alongside its justification.");

  /// chain
  static const SubstrateRequestMethods getBlock = SubstrateRequestMethods._(
      "chain_getBlock", "Get header and body of a relay chain block");
  static const SubstrateRequestMethods getBlockHash = SubstrateRequestMethods._(
      "chain_getBlockHash", "Get the block hash for a specific block");
  static const SubstrateRequestMethods chainGetFinalizedHead =
      SubstrateRequestMethods._("chain_getFinalizedHead",
          "Get hash of the last finalized block in the canon chain");
  static const SubstrateRequestMethods getHeader = SubstrateRequestMethods._(
      "chain_getHeader", "Retrieves the header for a specific block");
  static const SubstrateRequestMethods subscribeAllHeads =
      SubstrateRequestMethods._("chain_subscribeAllHeads",
          "Retrieves the newest header via subscription");
  static const SubstrateRequestMethods subscribeFinalizedHeads =
      SubstrateRequestMethods._("chain_subscribeFinalizedHeads",
          "Retrieves the best finalized header via subscription");
  static const SubstrateRequestMethods subscribeNewHeads =
      SubstrateRequestMethods._("chain_subscribeNewHeads",
          "Retrieves the best header via subscription");

  /// childstate
  static const SubstrateRequestMethods getKeys = SubstrateRequestMethods._(
      "childstate_getKeys",
      "Returns the keys with prefix from a child storage, leave empty to get all the keys");
  static const SubstrateRequestMethods getKeysPaged = SubstrateRequestMethods._(
      "childstate_getKeysPaged",
      "Returns the keys with prefix from a child storage with pagination support");
  static const SubstrateRequestMethods getStorage = SubstrateRequestMethods._(
      "childstate_getStorage",
      "Returns a child storage entry at a specific block state");
  static const SubstrateRequestMethods getStorageEntries =
      SubstrateRequestMethods._("childstate_getStorageEntries",
          "Returns child storage entries for multiple keys at a specific block state");
  static const SubstrateRequestMethods getStorageHash =
      SubstrateRequestMethods._("childstate_getStorageHash",
          "Returns the hash of a child storage entry at a block state");
  static const SubstrateRequestMethods getStorageSize =
      SubstrateRequestMethods._("childstate_getStorageSize",
          "Returns the size of a child storage entry at a block state");

  /// contracts
  static const SubstrateRequestMethods call = SubstrateRequestMethods._(
      "contracts_call", "Executes a call to a contract");
  static const SubstrateRequestMethods contractGetStorage =
      SubstrateRequestMethods._("contracts_getStorage",
          "Returns the value under a specified storage key in a contract");
  static const SubstrateRequestMethods instantiate = SubstrateRequestMethods._(
      "contracts_instantiate", "Instantiate a new contract");
  static const SubstrateRequestMethods rentProjection = SubstrateRequestMethods._(
      "contracts_rentProjection",
      "Returns the projected time a given contract will be able to sustain paying its rent");
  static const SubstrateRequestMethods uploadCode = SubstrateRequestMethods._(
      "contracts_upload_code",
      "Upload new code without instantiating a contract from it");

  /// dev
  static const SubstrateRequestMethods getBlockStats = SubstrateRequestMethods._(
      "dev_getBlockStats",
      "Reexecute the specified block_hash and gather statistics while doing so");

  /// engine
  static const SubstrateRequestMethods createBlock = SubstrateRequestMethods._(
      "engine_createBlock",
      "Instructs the manual-seal authorship task to create a new block");
  static const SubstrateRequestMethods finalizeBlock =
      SubstrateRequestMethods._("engine_finalizeBlock",
          "Instructs the manual-seal authorship task to finalize a block");

  /// grandpa
  static const SubstrateRequestMethods proveFinality = SubstrateRequestMethods._(
      "grandpa_proveFinality",
      "Prove finality for the given block number, returning the Justification for the last block in the set.");
  static const SubstrateRequestMethods roundState = SubstrateRequestMethods._(
      "grandpa_roundState",
      "Returns the state of the current best round state as well as the ongoing background rounds");
  static const SubstrateRequestMethods grandpaSubscribeJustifications =
      SubstrateRequestMethods._("grandpa_subscribeJustifications",
          "Subscribes to grandpa justifications");

  /// mmr
  static const SubstrateRequestMethods generateProof =
      SubstrateRequestMethods._("mmr_generateProof",
          "Generate MMR proof for the given block numbers.");
  static const SubstrateRequestMethods root = SubstrateRequestMethods._(
      "mmr_root", "Get the MMR root hash for the current best block");
  static const SubstrateRequestMethods verifyProof =
      SubstrateRequestMethods._("mmr_verifyProof", "Verify an MMR proof");
  static const SubstrateRequestMethods verifyProofStateless =
      SubstrateRequestMethods._("mmr_verifyProofStateless",
          "Verify an MMR proof statelessly given an mmr_root");

  /// offchain
  static const SubstrateRequestMethods localStorageGet =
      SubstrateRequestMethods._("offchain_localStorageGet",
          "Get offchain local storage under given key and prefix");
  static const SubstrateRequestMethods localStorageSet =
      SubstrateRequestMethods._("offchain_localStorageSet",
          "Set offchain local storage under given key and prefix");

  /// payment
  static const SubstrateRequestMethods queryFeeDetails =
      SubstrateRequestMethods._("payment_queryFeeDetails",
          "Query the detailed fee of a given encoded extrinsic");
  static const SubstrateRequestMethods queryInfo = SubstrateRequestMethods._(
      "payment_queryInfo",
      "Retrieves the fee information for an encoded extrinsic");

  /// rpc
  static const SubstrateRequestMethods rpc = SubstrateRequestMethods._(
      "rpc_methods",
      "Retrieves the list of RPC methods that are exposed by the node");

  /// state
  static const SubstrateRequestMethods stateCall = SubstrateRequestMethods._(
      "state_call", "Perform a call to a builtin on the chain");
  static const SubstrateRequestMethods getChildKeys = SubstrateRequestMethods._(
      "state_getChildKeys",
      "Retrieves the keys with prefix of a specific child storage");
  static const SubstrateRequestMethods getChildReadProof =
      SubstrateRequestMethods._("state_getChildReadProof",
          "Returns proof of storage for child key entries at a specific block state");
  static const SubstrateRequestMethods getChildStorage =
      SubstrateRequestMethods._(
          "state_getChildStorage", "Retrieves the child storage for a key");
  static const SubstrateRequestMethods getChildStorageHash =
      SubstrateRequestMethods._(
          "state_getChildStorageHash", "Retrieves the child storage hash");
  static const SubstrateRequestMethods getChildStorageSize =
      SubstrateRequestMethods._(
          "state_getChildStorageSize", "Retrieves the child storage size");
  static const SubstrateRequestMethods stateGetKeys = SubstrateRequestMethods._(
      "state_getKeys", "Retrieves the keys with a certain prefix");
  static const SubstrateRequestMethods stateGetKeysPaged =
      SubstrateRequestMethods._("state_getKeysPaged",
          "Returns the keys with prefix with pagination support.");
  static const SubstrateRequestMethods getMetadata = SubstrateRequestMethods._(
      "state_getMetadata", "Returns the runtime metadata");
  static const SubstrateRequestMethods getPairs = SubstrateRequestMethods._(
      "state_getPairs",
      "Returns the keys with prefix, leave empty to get all the keys (deprecated: Use getKeysPaged)");
  static const SubstrateRequestMethods getReadProof = SubstrateRequestMethods._(
      "state_getReadProof",
      "Returns proof of storage entries at a specific block state");
  static const SubstrateRequestMethods getRuntimeVersion =
      SubstrateRequestMethods._(
          "state_getRuntimeVersion", "Get the runtime version");
  static const SubstrateRequestMethods stateGetStorage =
      SubstrateRequestMethods._(
          "state_getStorage", "Retrieves the storage for a key");
  static const SubstrateRequestMethods stateGetStorageHash =
      SubstrateRequestMethods._(
          "state_getStorageHash", "Retrieves the storage hash");
  static const SubstrateRequestMethods stateGetStorageSize =
      SubstrateRequestMethods._(
          "state_getStorageSize", "Retrieves the storage size");
  static const SubstrateRequestMethods queryStorage = SubstrateRequestMethods._(
      "state_queryStorage",
      "Query historical storage entries (by key) starting from a start block");
  static const SubstrateRequestMethods queryStorageAt = SubstrateRequestMethods._(
      "state_queryStorageAt",
      "Query storage entries (by key) starting at block hash given as the second parameter");
  static const SubstrateRequestMethods subscribeRuntimeVersion =
      SubstrateRequestMethods._("state_subscribeRuntimeVersion",
          "Retrieves the runtime version via subscription");
  static const SubstrateRequestMethods subscribeStorage =
      SubstrateRequestMethods._("state_subscribeStorage",
          "Subscribes to storage changes for the provided keys");
  static const SubstrateRequestMethods traceBlock = SubstrateRequestMethods._(
      "state_traceBlock",
      "Provides a way to trace the re-execution of a single block");
  static const SubstrateRequestMethods trieMigrationStatus =
      SubstrateRequestMethods._(
          "state_trieMigrationStatus", "Check current migration state");

  /// syncstate
  static const SubstrateRequestMethods genSyncSpec = SubstrateRequestMethods._(
      "sync_state_genSyncSpec",
      "Returns the json-serialized chainspec running the node, with a sync state.");

  /// system
  static const SubstrateRequestMethods systemHealth = SubstrateRequestMethods._(
      "system_health", "Return health status of the node");
  static const SubstrateRequestMethods accountNextIndex =
      SubstrateRequestMethods._("system_accountNextIndex",
          "Retrieves the next accountIndex as available on the node");
  static const SubstrateRequestMethods addLogFilter = SubstrateRequestMethods._(
      "system_addLogFilter",
      "Adds the supplied directives to the current log filter");
  static const SubstrateRequestMethods addReservedPeer =
      SubstrateRequestMethods._(
          "system_addReservedPeer", "Adds a reserved peer");
  static const SubstrateRequestMethods chain =
      SubstrateRequestMethods._("system_chain", "Retrieves the chain");
  static const SubstrateRequestMethods chainType =
      SubstrateRequestMethods._("system_chainType", "Retrieves the chain type");
  static const SubstrateRequestMethods dryRun = SubstrateRequestMethods._(
      "system_dryRun", "Dry run an extrinsic at a given block");
  static const SubstrateRequestMethods health =
      SubstrateRequestMethods._("health", "Return health status of the node");
  static const SubstrateRequestMethods localListenAddresses =
      SubstrateRequestMethods._("system_localListenAddresses",
          "The addresses include a trailing /p2p/ with the local PeerId, and are thus suitable to be passed to addReservedPeer or as a bootnode address for example");
  static const SubstrateRequestMethods localPeerId = SubstrateRequestMethods._(
      "system_localPeerId", "Returns the base58-encoded PeerId of the node");
  static const SubstrateRequestMethods name =
      SubstrateRequestMethods._("system_name", "Retrieves the node name");
  static const SubstrateRequestMethods networkState = SubstrateRequestMethods._(
      "system_networkState", "Returns current state of the network");
  static const SubstrateRequestMethods nodeRoles = SubstrateRequestMethods._(
      "system_nodeRoles", "Returns the roles the node is running as");
  static const SubstrateRequestMethods peers = SubstrateRequestMethods._(
      "system_peers", "Returns the currently connected peers");
  static const SubstrateRequestMethods properties = SubstrateRequestMethods._(
      "system_properties",
      "Get a custom set of properties as a JSON object, defined in the chain spec");

  static const SubstrateRequestMethods removeReservedPeer =
      SubstrateRequestMethods._(
          "system_removeReservedPeer", "Remove a reserved peer");
  static const SubstrateRequestMethods reservedPeers =
      SubstrateRequestMethods._(
          "system_reservedPeers", "Returns the list of reserved peers");
  static const SubstrateRequestMethods resetLogFilter =
      SubstrateRequestMethods._("system_resetLogFilter",
          "Resets the log filter to Substrate defaults");
  static const SubstrateRequestMethods syncState = SubstrateRequestMethods._(
      "system_syncState", "Returns the state of the syncing of the node");
  static const SubstrateRequestMethods version = SubstrateRequestMethods._(
      "system_version", "Retrieves the version of the node");

  static List<SubstrateRequestMethods> values = [
    SubstrateRequestMethods.hasKey,
    SubstrateRequestMethods.hasSessionKeys,
    SubstrateRequestMethods.insertKey,
    SubstrateRequestMethods.pendingExtrinsics,
    SubstrateRequestMethods.removeExtrinsic,
    SubstrateRequestMethods.rotateKeys,
    SubstrateRequestMethods.submitAndWatchExtrinsic,
    SubstrateRequestMethods.submitExtrinsic,
    SubstrateRequestMethods.epochAuthorship,
    SubstrateRequestMethods.getFinalizedHead,
    SubstrateRequestMethods.subscribeJustifications,
    SubstrateRequestMethods.getBlock,
    SubstrateRequestMethods.getBlockHash,
    SubstrateRequestMethods.chainGetFinalizedHead,
    SubstrateRequestMethods.getHeader,
    SubstrateRequestMethods.subscribeAllHeads,
    SubstrateRequestMethods.subscribeFinalizedHeads,
    SubstrateRequestMethods.subscribeNewHeads,
    SubstrateRequestMethods.getKeys,
    SubstrateRequestMethods.getKeysPaged,
    SubstrateRequestMethods.getStorage,
    SubstrateRequestMethods.getStorageEntries,
    SubstrateRequestMethods.getStorageHash,
    SubstrateRequestMethods.getStorageSize,
    SubstrateRequestMethods.call,
    SubstrateRequestMethods.contractGetStorage,
    SubstrateRequestMethods.instantiate,
    SubstrateRequestMethods.rentProjection,
    SubstrateRequestMethods.uploadCode,
    SubstrateRequestMethods.getBlockStats,
    SubstrateRequestMethods.createBlock,
    SubstrateRequestMethods.finalizeBlock,
    SubstrateRequestMethods.proveFinality,
    SubstrateRequestMethods.roundState,
    SubstrateRequestMethods.grandpaSubscribeJustifications,
    SubstrateRequestMethods.generateProof,
    SubstrateRequestMethods.root,
    SubstrateRequestMethods.verifyProof,
    SubstrateRequestMethods.verifyProofStateless,
    SubstrateRequestMethods.localStorageGet,
    SubstrateRequestMethods.localStorageSet,
    SubstrateRequestMethods.queryFeeDetails,
    SubstrateRequestMethods.queryInfo,
    SubstrateRequestMethods.rpc,
    SubstrateRequestMethods.stateCall,
    SubstrateRequestMethods.getChildKeys,
    SubstrateRequestMethods.getChildReadProof,
    SubstrateRequestMethods.getChildStorage,
    SubstrateRequestMethods.getChildStorageHash,
    SubstrateRequestMethods.getChildStorageSize,
    SubstrateRequestMethods.stateGetKeys,
    SubstrateRequestMethods.stateGetKeysPaged,
    SubstrateRequestMethods.getMetadata,
    SubstrateRequestMethods.getPairs,
    SubstrateRequestMethods.getReadProof,
    SubstrateRequestMethods.getRuntimeVersion,
    SubstrateRequestMethods.stateGetStorage,
    SubstrateRequestMethods.stateGetStorageHash,
    SubstrateRequestMethods.stateGetStorageSize,
    SubstrateRequestMethods.queryStorage,
    SubstrateRequestMethods.queryStorageAt,
    SubstrateRequestMethods.subscribeRuntimeVersion,
    SubstrateRequestMethods.subscribeStorage,
    SubstrateRequestMethods.traceBlock,
    SubstrateRequestMethods.trieMigrationStatus,
    SubstrateRequestMethods.genSyncSpec,
    SubstrateRequestMethods.accountNextIndex,
    SubstrateRequestMethods.addLogFilter,
    SubstrateRequestMethods.addReservedPeer,
    SubstrateRequestMethods.chain,
    SubstrateRequestMethods.chainType,
    SubstrateRequestMethods.dryRun,
    SubstrateRequestMethods.health,
    SubstrateRequestMethods.localListenAddresses,
    SubstrateRequestMethods.localPeerId,
    SubstrateRequestMethods.name,
    SubstrateRequestMethods.networkState,
    SubstrateRequestMethods.nodeRoles,
    SubstrateRequestMethods.peers,
    SubstrateRequestMethods.properties,
    SubstrateRequestMethods.removeReservedPeer,
    SubstrateRequestMethods.reservedPeers,
    SubstrateRequestMethods.resetLogFilter,
    SubstrateRequestMethods.syncState,
    SubstrateRequestMethods.version,
  ];
}

// static const SubstrateRequestMethods insertKey = SubstrateRequestMethods._("", "");
