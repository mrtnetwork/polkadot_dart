typedef ONEVMCALLRESPONSE<RESPONSE extends Object?> = RESPONSE Function(
    List<Object> response);

class EvmFunctionAbi<RESPONSE extends Object?> {
  final String name;
  final Map<String, dynamic> abi;
  final ONEVMCALLRESPONSE<RESPONSE> parser;

  const EvmFunctionAbi(
      {required this.name, required this.abi, required this.parser});
}
