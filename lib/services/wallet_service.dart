import 'package:web3dart/web3dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WalletService {
  static const String _privateKeyKey = 'private_key';
  static const String sepoliaRpcUrl =
      'https://sepolia.infura.io/v3/8daf643dc55444bc8a73d8b854318094';

  final Web3Client _client = Web3Client(sepoliaRpcUrl, http.Client());
  final SharedPreferences _prefs;

  WalletService(this._prefs);

  Future<Credentials> importWallet(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      // Save private key securely
      await _prefs.setString(_privateKeyKey, privateKey);

      return credentials;
    } catch (e) {
      throw Exception('Invalid private key');
    }
  }

  Future<String?> getStoredPrivateKey() async {
    return _prefs.getString(_privateKeyKey);
  }

  Future<EtherAmount> getBalance(String address) async {
    final ethAddress = EthereumAddress.fromHex(address);
    return await _client.getBalance(ethAddress);
  }
}
