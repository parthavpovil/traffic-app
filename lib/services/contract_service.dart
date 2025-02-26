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
    required bool visibility,
  }) async {
    final function = _contract.function('submitReport');

    try {
      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [description, location, evidenceLink, visibility],
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
          visibility: report[8] as bool,
        );
      }).toList();

      return reports;
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<List<ReportData>> getVisibleReports() async {
    final function = _contract.function('getVisibleReports');

    try {
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );

      // Debug log
      print('Visible reports raw result: $result');

      if (result.isEmpty) return [];

      final reports = (result[0] as List<dynamic>).map((report) {
        if (report is! List) {
          print('Invalid report format: $report');
          return null;
        }
        
        try {
          return ReportData(
            id: (report[0] as BigInt).toInt(),
            reporter: report[1].toString(),
            description: report[2].toString(),
            location: report[3].toString(),
            evidenceLink: report[4].toString(),
            verified: report[5] as bool,
            reward: (report[6] as BigInt).toInt(),
            timestamp: (report[7] as BigInt).toInt(),
            visibility: report[8] as bool,
          );
        } catch (e) {
          print('Error parsing report: $e');
          return null;
        }
      }).whereType<ReportData>().toList();

      return reports;
    } catch (e) {
      print('Error in getVisibleReports: $e');
      throw Exception('Failed to fetch visible reports: $e');
    }
  }

  Future<int> getReportCount() async {
    try {
      print('Calling reportCount...');
      
      final result = await _client.call(
        contract: _contract,
        function: _contract.function('reportCount'),
        params: [],
      );
      
      print('Report count raw result: $result');
      
      if (result.isEmpty) {
        print('Empty result from contract');
        return 0;
      }
      
      if (result[0] is BigInt) {
        return (result[0] as BigInt).toInt();
      } else {
        print('Unexpected return type: ${result[0].runtimeType}');
        return 0;
      }
    } catch (e) {
      print('Error in getReportCount: $e');
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to fetch report count: $e');
    }
  }

  Future<double> estimateReportGasFee({
    required Credentials credentials,
    required String description,
    required String location,
    required String evidenceLink,
    required bool visibility,
  }) async {
    final function = _contract.function('submitReport');
    try {
      final gasEstimate = await _client.estimateGas(
        sender: await credentials.extractAddress(),
        to: EthereumAddress.fromHex(_contractAddress),
        data: function
            .encodeCall([description, location, evidenceLink, visibility]),
      );

      final gasPrice = await _client.getGasPrice();
      final gasCost = gasEstimate * gasPrice.getInWei;
      return EtherAmount.fromBigInt(EtherUnit.wei, gasCost)
          .getValueInUnit(EtherUnit.ether);
    } catch (e) {
      throw Exception('Failed to estimate gas: $e');
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
  final bool visibility;

  ReportData({
    required this.id,
    required this.reporter,
    required this.description,
    required this.location,
    required this.evidenceLink,
    required this.verified,
    required this.reward,
    required this.timestamp,
    required this.visibility,
  });
}
