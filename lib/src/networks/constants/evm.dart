import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/networks/types/types/evm.dart';

class SubstrateEVMNetworkUtils {
  static const erc20TransferSignature =
      "ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef";
  static void _ensureResponseLength(List<Object> response, int length) {
    if (response.length != length) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        "ABI function returned unexpected number of items.",
      );
    }
  }

  static final nameAbi = EvmFunctionAbi<String?>(
    name: "name",
    abi: const {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [
        {"name": "", "type": "string"},
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
    },
    parser: (response) {
      _ensureResponseLength(response, 1);
      final result = response.first;
      if (result is! String) {
        throw BuError(
          DefaultErrorType.invalidArgument,
          "ABI function returned invalid type.",
        );
      }
      return result;
    },
  );

  static final symbolAbi = EvmFunctionAbi<String>(
    name: "symbol",
    abi: const {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {"name": "", "type": "string"},
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
    },
    parser: (response) {
      _ensureResponseLength(response, 1);
      final result = response.first;
      if (result is! String) {
        throw BuError(
          DefaultErrorType.invalidArgument,
          "ABI function returned invalid type.",
        );
      }
      return result;
    },
  );

  static final decimalsAbi = EvmFunctionAbi<int>(
    name: "decimals",
    abi: const {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [
        {"name": "", "type": "uint8"},
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
    },
    parser: (response) {
      _ensureResponseLength(response, 1);
      final result = BigintUtils.tryParse(response.first, allowHex: true);
      if (result == null) {
        throw BuError(
          DefaultErrorType.invalidArgument,
          "ABI function returned invalid type.",
        );
      }
      return result.toInt();
    },
  );

  static final balanceOfAbi = EvmFunctionAbi<BigInt>(
    name: "balanceOf",
    abi: const {
      "constant": true,
      "inputs": [
        {"name": "account", "type": "address"},
      ],
      "name": "balanceOf",
      "outputs": [
        {"name": "", "type": "uint256"},
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function",
    },
    parser: (response) {
      _ensureResponseLength(response, 1);
      final result = BigintUtils.tryParse(response.first, allowHex: true);
      if (result == null) {
        throw BuError(
          DefaultErrorType.invalidArgument,
          "ABI function returned invalid type.",
        );
      }
      return result;
    },
  );
}
