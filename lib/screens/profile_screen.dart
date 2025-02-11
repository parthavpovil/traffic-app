import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../services/wallet_service.dart';
import '../services/contract_service.dart';
import '../constants/contract_constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  late final ContractService _contractService;
  Future<List<ReportData>>? _reports;

  @override
  void initState() {
    super.initState();
    _address = widget.credentials.extractAddress();
    _initBalance();
    _contractService = ContractService(
      rpcUrl: WalletService.sepoliaRpcUrl,
      contractAddress: ContractConstants.contractAddress,
      contractAbi: ContractConstants.abi,
    );
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _reports = _contractService.getReportsByAddress(widget.credentials);
    });
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
        onRefresh: () async {
          await _initBalance();
          await _fetchReports();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildTotalReports(),
              const SizedBox(height: 24),
              _buildWalletCard(),
              const SizedBox(height: 24),
              _buildBalanceCard(),
              const SizedBox(height: 24),
              _buildReportsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.orange.withOpacity(0.1),
          child: Text(
            '⟠', // Ethereum symbol
            style: TextStyle(
              fontSize: 48,
              color: AppColors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Card(
      elevation: 4,
      shadowColor: AppColors.darkBlue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wallet, color: AppColors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Wallet Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          content: Text('Address copied to clipboard'),
                          backgroundColor: AppColors.darkBlue,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data!.hex,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                color: AppColors.darkBlue.withOpacity(0.8),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                const Icon(Icons.copy, color: AppColors.orange),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalReports() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            FutureBuilder<List<ReportData>>(
              future: _reports,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${snapshot.data!.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange,
                      ),
                    ),
                  );
                }
                return const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                  ),
                );
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

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Reports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<ReportData>>(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return const Center(
                child: Text('No reports submitted yet'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(
                      report.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Location: ${report.location}'),
                        Text(
                            'Status: ${report.verified ? "Verified" : "Pending"}'),
                        if (report.verified)
                          Text('Reward: ${report.reward} ETH'),
                        Text(
                            'Date: ${DateTime.fromMillisecondsSinceEpoch(report.timestamp * 1000)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _showReportDetails(report),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReportDetails(ReportData report) {
    final ipfsUrl = 'https://ipfs.io/ipfs/${report.evidenceLink}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${report.id}'),
              const SizedBox(height: 8),
              Text('Description: ${report.description}'),
              const SizedBox(height: 8),
              Text('Location: ${report.location}'),
              const SizedBox(height: 8),
              const Text('Evidence:'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(ipfsUrl))) {
                    await launchUrl(Uri.parse(ipfsUrl));
                  }
                },
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ipfsUrl,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Status: ${report.verified ? "Verified" : "Pending"}'),
              if (report.verified) ...[
                const SizedBox(height: 8),
                Text('Reward: ${report.reward} ETH'),
              ],
              const SizedBox(height: 8),
              Text(
                'Date: ${DateTime.fromMillisecondsSinceEpoch(report.timestamp * 1000).toString()}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
