import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/wallet_service.dart';
import 'package:web3dart/web3dart.dart';

class WalletDetailsScreen extends StatefulWidget {
  final Credentials credentials;
  final WalletService walletService;

  const WalletDetailsScreen({
    super.key,
    required this.credentials,
    required this.walletService,
  });

  @override
  State<WalletDetailsScreen> createState() => _WalletDetailsScreenState();
}

class _WalletDetailsScreenState extends State<WalletDetailsScreen> {
  late Future<EthereumAddress> _address;
  late Future<EtherAmount> _balance;

  @override
  void initState() {
    super.initState();
    _address = widget.credentials.extractAddress();
    _initBalance();
  }

  Future<void> _initBalance() async {
    final address = await _address;
    setState(() {
      _balance = widget.walletService.getBalance(address.hex);
    });
  }

  Future<void> _refreshBalance() async {
    setState(() {
      _initBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Details'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<EthereumAddress>(
              future: _address,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: snapshot.data!.hex));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Address copied to clipboard')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data!.hex,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Icon(Icons.copy, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<EtherAmount>(
              future: _balance,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data!.getValueInUnit(EtherUnit.ether)} ETH',
                    style: const TextStyle(fontSize: 24),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshBalance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Refresh Balance'),
            ),
          ],
        ),
      ),
    );
  }
}
