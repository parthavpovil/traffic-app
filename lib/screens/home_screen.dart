import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../services/contract_service.dart';
import '../constants/contract_constants.dart';
import '../services/wallet_service.dart';
import '../widgets/report_details_dialog.dart';
import '../widgets/reports_heat_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContractService _contractService;
  List<ReportData>? _visibleReports;
  int _totalReports = 0;

  @override
  void initState() {
    super.initState();
    _contractService = ContractService(
      rpcUrl: WalletService.sepoliaRpcUrl,
      contractAddress: ContractConstants.contractAddress,
      contractAbi: ContractConstants.abi,
    );
    _fetchVisibleReports();
    _fetchReportCount();
  }

  Future<void> _fetchVisibleReports() async {
    try {
      final reports = await _contractService.getVisibleReports();
      if (mounted) {
        setState(() {
          _visibleReports = reports;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching reports: $e')),
        );
      }
    }
  }

  Future<void> _fetchReportCount() async {
    try {
      final count = await _contractService.getReportCount();
      if (mounted) {
        setState(() {
          _totalReports = count;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching report count: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Reports',
                        value: _totalReports.toString(),
                        icon: Icons.description,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: _StatCard(
                        title: 'Verified',
                        value: '0',
                        icon: Icons.verified,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Reports Section
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _RecentReportsList(reports: _visibleReports),

                // Nearby Reports Map
                const SizedBox(height: 24),
                Text(
                  'Nearby Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _visibleReports == null
                      ? const Center(child: CircularProgressIndicator())
                      : _visibleReports!.isEmpty
                          ? const Center(child: Text('No reports available'))
                          : ReportsHeatMap(reports: _visibleReports!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

// Recent Reports List Widget
class _RecentReportsList extends StatelessWidget {
  final List<ReportData>? reports;

  const _RecentReportsList({this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports!.isEmpty) {
      return const Center(child: Text('No reports available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports!.length,
      itemBuilder: (context, index) {
        final report = reports![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ReportDetailsDialog(report: report),
              );
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: 'https://ipfs.io/ipfs/${report.evidenceLink}',
                  placeholder: (context, url) => const Icon(
                    Icons.report_problem,
                    color: AppColors.orange,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.report_problem,
                    color: AppColors.orange,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(report.description),
            subtitle: Text(
              'Location • ${DateTime.now().difference(
                    DateTime.fromMillisecondsSinceEpoch(
                        report.timestamp * 1000),
                  ).inMinutes}m ago',
              style: TextStyle(color: AppColors.darkBlue.withOpacity(0.6)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: report.verified
                    ? AppColors.darkBlue.withOpacity(0.1)
                    : AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.verified ? 'Verified' : 'Pending',
                style: TextStyle(
                  color: report.verified
                      ? AppColors.darkBlue
                      : AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
