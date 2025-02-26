import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/wallet_service.dart';
import '../widgets/dialogs/import_wallet_dialog.dart';
import 'main_screen.dart';
import '../utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasWallet = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    
    // Add this to check wallet and navigate
    _checkWalletAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkWalletAndNavigate() async {
    try {
      print('Checking wallet status...');
      final prefs = await SharedPreferences.getInstance();
      final walletService = WalletService(prefs);
      final privateKey = await walletService.getStoredPrivateKey();
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        if (privateKey != null) {
          final credentials = await walletService.importWallet(privateKey);
          Navigator.pushReplacement(
            context,
            FadePageRoute(
              page: MainScreen(
                credentials: credentials,
                walletService: walletService,
              ),
            ),
          );
        } else {
          setState(() {
            _hasWallet = false;
            _isLoading = false;
          });
          _showImportWalletDialog();
        }
      }
    } catch (e) {
      print('Error in _checkWalletAndNavigate: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to initialize: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showImportWalletDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImportWalletDialog(
        onImport: (privateKey) async {
          try {
            setState(() => _isLoading = true);
            final prefs = await SharedPreferences.getInstance();
            final walletService = WalletService(prefs);
            final credentials = await walletService.importWallet(privateKey);
            
            if (mounted) {
              Navigator.pushReplacement(
                context,
                FadePageRoute(
                  page: MainScreen(
                    credentials: credentials,
                    walletService: walletService,
                  ),
                ),
              );
            }
          } catch (e) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/traffic.gif',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TRAFFI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'X',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE74425), // Specific red color
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
