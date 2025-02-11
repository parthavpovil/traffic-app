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

  Future<List<ReportData>> getReportsByAddress(Credentials credentials) async {
    final function = _contract.function('getReportsByAddress');
    final address = await credentials.extractAddress();

    try {
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [address],
      );

      if (result.isEmpty) return [];

      final reports = (result[0] as List<dynamic>).map((report) {
        return ReportData(
          id: (report[0] as BigInt).toInt(),
          reporter: report[1].toString(),
          description: report[2].toString(),
          location: report[3].toString(),
          evidenceLink: report[4].toString(),
          verified: report[5] as bool,
          reward: (report[6] as BigInt).toInt(),
          timestamp: (report[7] as BigInt).toInt(),
        );
      }).toList();

      return reports;
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  void dispose() {
    _client.dispose();
  }
}

class ReportData {
  final int id;
  final String reporter;
  final String description;
  final String location;
  final String evidenceLink;
  final bool verified;
  final int reward;
  final int timestamp;

  ReportData({
    required this.id,
    required this.reporter,
    required this.description,
    required this.location,
    required this.evidenceLink,
    required this.verified,
    required this.reward,
    required this.timestamp,
  });
}
