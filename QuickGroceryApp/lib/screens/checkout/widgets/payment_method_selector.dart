import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models.dart';

/// Payment method selection widget supporting QwikWallet, UPI, and Cards.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentId,
    required this.wallet,
    required this.paymentMethods,
    required this.onChanged,
    required this.onOpenWallet,
    required this.onAddPayment,
  });

  final String? selectedPaymentId;
  final WalletSummary? wallet;
  final List<SavedPaymentMethod> paymentMethods;
  final ValueChanged<String?> onChanged;
  final VoidCallback onOpenWallet;
  final VoidCallback onAddPayment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Payment (demo only)',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      RadioListTile<String>(
        value: 'wallet',
        groupValue: selectedPaymentId,
        onChanged: onChanged,
        title: const Text('QwikWallet'),
        subtitle: Text('Demo balance ${money(wallet?.balanceCents ?? 0)}'),
        contentPadding: EdgeInsets.zero,
      ),
      if (paymentMethods.isNotEmpty)
        ...paymentMethods.map(
          (method) => RadioListTile<String>(
            value: method.id,
            groupValue: selectedPaymentId,
            onChanged: onChanged,
            title: Text(method.display),
            subtitle: Text(
              method.type == 'upi' ? 'Simulated UPI' : 'Simulated card',
            ),
            contentPadding: EdgeInsets.zero,
          ),
        )
      else
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No saved demo payment methods. Add one in Profile or pay with QwikWallet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 4,
          children: [
            TextButton.icon(
              onPressed: onOpenWallet,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Wallet'),
            ),
            TextButton.icon(
              onPressed: onAddPayment,
              icon: const Icon(Icons.add),
              label: const Text('Add demo payment'),
            ),
          ],
        ),
      ),
    ],
  );
}
