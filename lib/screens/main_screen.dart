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
import '../utils/page_transitions.dart';
import '../utils/custom_fab_location.dart';

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: Builder(
        builder: (context) => SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: () {
              final RenderBox fab = context.findRenderObject() as RenderBox;
              final fabPosition = fab.localToGlobal(Offset.zero);

              Navigator.push(
                context,
                FabSlideRoute(
                  page: CaptureScreen(
                    credentials: widget.credentials,
                    contractService: _contractService,
                  ),
                  startOffset: fabPosition,
                ),
              );
            },
            backgroundColor: AppColors.orange,
            elevation: 4,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: CustomFabLocation(),
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
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(0, Icons.home, 'Home')),
              const SizedBox(width: 40),
              Expanded(child: _buildNavItem(1, Icons.person, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.orange : AppColors.darkBlue,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? AppColors.orange : AppColors.darkBlue,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
