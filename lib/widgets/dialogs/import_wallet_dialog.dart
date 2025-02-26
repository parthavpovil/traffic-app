import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ImportWalletDialog extends StatefulWidget {
  final Function(String) onImport;

  const ImportWalletDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportWalletDialog> createState() => _ImportWalletDialogState();
}

class _ImportWalletDialogState extends State<ImportWalletDialog> {
  final _privateKeyController = TextEditingController();
  bool _isPrivateKeyValid = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Wallet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _privateKeyController,
            decoration: InputDecoration(
              labelText: 'Private Key',
              errorText: _isPrivateKeyValid ? null : 'Invalid private key',
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your Sepolia testnet wallet private key',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final privateKey = _privateKeyController.text.trim();
            if (privateKey.length == 64 || privateKey.length == 66) {
              widget.onImport(privateKey);
              Navigator.pop(context);
            } else {
              setState(() => _isPrivateKeyValid = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
          ),
          child: const Text('Import'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }
}
