const mt = {
  "type": "Enum",
  "key": null,
  "value": null,
  "variants": {
    "LiquidityDepositAddressReady": {
      "type": "Map",
      "value": {
        "channel_id": {"type": "U64", "value": null},
        "asset": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": null,
            "Flip": null,
            "Usdc": null,
            "Usdt": null,
            "Dot": null,
            "Btc": null,
            "ArbEth": null,
            "ArbUsdc": null,
            "Sol": null,
            "SolUsdc": null
          }
        },
        "deposit_address": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": {"type": "[U8;20]", "value": null},
            "Dot": {"type": "[U8;32]", "value": null},
            "Btc": {"type": "Vec<U8>", "value": null},
            "Arb": {"type": "[U8;20]", "value": null},
            "Sol": {"type": "[U8;32]", "value": null}
          }
        },
        "account_id": {"type": "[U8;32]", "value": null},
        "deposit_chain_expiry_block": {"type": "U64", "value": null},
        "boost_fee": {"type": "U16", "value": null},
        "channel_opening_fee": {"type": "U128", "value": null}
      }
    },
    "WithdrawalEgressScheduled": {
      "type": "Map",
      "value": {
        "egress_id": {
          "type": "Tuple(Enum, U64)",
          "value": [
            {
              "type": "Enum",
              "key": null,
              "value": null,
              "variants": {
                "Ethereum": null,
                "Polkadot": null,
                "Bitcoin": null,
                "Arbitrum": null,
                "Solana": null
              }
            },
            {"type": "U64", "value": null}
          ]
        },
        "asset": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": null,
            "Flip": null,
            "Usdc": null,
            "Usdt": null,
            "Dot": null,
            "Btc": null,
            "ArbEth": null,
            "ArbUsdc": null,
            "Sol": null,
            "SolUsdc": null
          }
        },
        "amount": {"type": "U128", "value": null},
        "destination_address": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": {"type": "[U8;20]", "value": null},
            "Dot": {"type": "[U8;32]", "value": null},
            "Btc": {"type": "Vec<U8>", "value": null},
            "Arb": {"type": "[U8;20]", "value": null},
            "Sol": {"type": "[U8;32]", "value": null}
          }
        },
        "fee": {"type": "U128", "value": null}
      }
    },
    "LiquidityRefundAddressRegistered": {
      "type": "Map",
      "value": {
        "account_id": {"type": "[U8;32]", "value": null},
        "chain": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Ethereum": null,
            "Polkadot": null,
            "Bitcoin": null,
            "Arbitrum": null,
            "Solana": null
          }
        },
        "address": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": {"type": "[U8;20]", "value": null},
            "Dot": {"type": "[U8;32]", "value": null},
            "Btc": {
              "type": "Enum",
              "key": null,
              "value": null,
              "variants": {
                "P2PKH": {"type": "[U8;20]", "value": null},
                "P2SH": {"type": "[U8;20]", "value": null},
                "P2WPKH": {"type": "[U8;20]", "value": null},
                "P2WSH": {"type": "[U8;32]", "value": null},
                "Taproot": {"type": "[U8;32]", "value": null},
                "OtherSegwit": {
                  "type": "Map",
                  "value": {
                    "version": {"type": "U8", "value": null},
                    "program": {"type": "Vec<U8>", "value": null}
                  }
                }
              }
            },
            "Arb": {"type": "[U8;20]", "value": null},
            "Sol": {"type": "[U8;32]", "value": null}
          }
        }
      }
    },
    "AssetTransferred": {
      "type": "Map",
      "value": {
        "from": {"type": "[U8;32]", "value": null},
        "to": {"type": "[U8;32]", "value": null},
        "asset": {
          "type": "Enum",
          "key": null,
          "value": null,
          "variants": {
            "Eth": null,
            "Flip": null,
            "Usdc": null,
            "Usdt": null,
            "Dot": null,
            "Btc": null,
            "ArbEth": null,
            "ArbUsdc": null,
            "Sol": null,
            "SolUsdc": null
          }
        },
        "amount": {"type": "U128", "value": null}
      }
    }
  }
};
