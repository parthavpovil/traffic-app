import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class ContractService {
  final Web3Client _client;
  final String _contractAddress;
  final DeployedContract _contract;

  ContractService({
    required String rpcUrl,
    required String contractAddress,
    required String contractAbi,
  })  : _client = Web3Client(rpcUrl, http.Client()),
        _contractAddress = contractAddress,
        _contract = DeployedContract(
          ContractAbi.fromJson(contractAbi, 'ReportAndReward'),
          EthereumAddress.fromHex(contractAddress),
        );

  Future<String> submitReport({
    required Credentials credentials,
    required String description,
    required String location,
    required String evidenceLink,
  }) async {
    final function = _contract.function('submitReport');

    try {
      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [description, location, evidenceLink],
          maxGas: 500000, // Fixed gas limit
        ),
        chainId: 11155111, // Sepolia chain ID
      );

      return result;
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  void dispose() {
    _client.dispose();
  }
}
