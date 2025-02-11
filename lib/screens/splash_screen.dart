import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/common/app_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/wallet_service.dart';
import '../widgets/dialogs/import_wallet_dialog.dart';
import 'wallet_details_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _hasWallet = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final walletService = WalletService(prefs);
    final storedKey = await walletService.getStoredPrivateKey();

    if (storedKey != null && mounted) {
      try {
        final credentials = await walletService.importWallet(storedKey);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WalletDetailsScreen(
                credentials: credentials,
                walletService: walletService,
              ),
            ),
          );
        }
      } catch (e) {
        // If stored key is invalid, clear it
        await prefs.remove('private_key');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasWallet = false;
          });
        }
      }
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _hasWallet = false;
      });
    }
  }

  Future<void> _handleWalletImport(BuildContext context) async {
    final privateKey = await showDialog<String>(
      context: context,
      builder: (context) => const ImportWalletDialog(),
    );

    if (privateKey != null) {
      try {
        setState(() => _isLoading = true);
        final prefs = await SharedPreferences.getInstance();
        final walletService = WalletService(prefs);
        final credentials = await walletService.importWallet(privateKey);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WalletDetailsScreen(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TRAFFI',
                  style: TextStyle(
                    fontSize: 48,
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
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
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
            const SizedBox(height: 48),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (!_hasWallet)
              ElevatedButton(
                onPressed: () => _handleWalletImport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Import Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
