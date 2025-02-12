import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import '../constants/colors.dart';
import '../services/wallet_service.dart';
import '../services/contract_service.dart';
import '../constants/contract_constants.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'capture_screen.dart';
import '../constants/theme.dart';

class MainScreen extends StatefulWidget {
  final Credentials credentials;
  final WalletService walletService;

  const MainScreen({
    super.key,
    required this.credentials,
    required this.walletService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  late final ContractService _contractService;

  @override
  void initState() {
    super.initState();
    _contractService = ContractService(
      rpcUrl: WalletService.sepoliaRpcUrl,
      contractAddress: ContractConstants.contractAddress,
      contractAbi: ContractConstants.abi,
    );
    _screens = [
      const HomeScreen(),
      ProfileScreen(
        credentials: widget.credentials,
        walletService: widget.walletService,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaptureScreen(
                credentials: widget.credentials,
                contractService: _contractService,
              ),
            ),
          );
        },
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: BottomAppBar(
          height: 60,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(0, Icons.home, 'Home')),
              const Expanded(child: SizedBox()), // Space for FAB
              Expanded(child: _buildNavItem(1, Icons.person, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return MaterialButton(
      onPressed: () => setState(() => _selectedIndex = index),
      minWidth: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.darkBlue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkBlue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
