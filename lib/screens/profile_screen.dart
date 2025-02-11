import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/wallet_service.dart';
import 'package:web3dart/web3dart.dart';

class ProfileScreen extends StatefulWidget {
  final Credentials credentials;
  final WalletService walletService;

  const ProfileScreen({
    super.key,
    required this.credentials,
    required this.walletService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<EthereumAddress> _address;
  Future<EtherAmount>? _balance;

  @override
  void initState() {
    super.initState();
    _address = widget.credentials.extractAddress();
    _initBalance();
  }

  Future<void> _initBalance() async {
    final address = await _address;
    if (mounted) {
      setState(() {
        _balance = widget.walletService.getBalance(address.hex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _initBalance,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildWalletCard(),
            const SizedBox(height: 24),
            _buildBalanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: AppColors.orange,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Wallet Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<EthereumAddress>(
              future: _address,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return InkWell(
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data!.hex,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const Icon(Icons.copy, color: AppColors.darkBlue),
                        ],
                      ),
                    ),
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                IconButton(
                  onPressed: _initBalance,
                  icon: const Icon(Icons.refresh, color: AppColors.darkBlue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<EtherAmount>(
              future: _balance,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data!.getValueInUnit(EtherUnit.ether)} ETH',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Text(
                    'Error loading balance',
                    style: TextStyle(color: Colors.red),
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
