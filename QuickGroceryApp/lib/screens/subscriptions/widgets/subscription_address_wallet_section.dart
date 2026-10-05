import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models.dart';

/// Delivery address selector and wallet auto-pay notice for subscriptions.
class SubscriptionAddressWalletSection extends StatelessWidget {
  const SubscriptionAddressWalletSection({
    super.key,
    required this.addresses,
    required this.addressId,
    required this.walletBalanceCents,
    required this.estimatedTotalCents,
    required this.onSelectAddress,
    required this.onManageAddresses,
  });

  final List<SavedAddress> addresses;
  final String? addressId;
  final int walletBalanceCents;
  final int estimatedTotalCents;
  final ValueChanged<String?> onSelectAddress;
  final VoidCallback onManageAddresses;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Delivery address',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      if (addresses.isEmpty)
        OutlinedButton.icon(
          onPressed: onManageAddresses,
          icon: const Icon(Icons.add),
          label: const Text('Add a saved address'),
        )
      else
        DropdownButtonFormField<String>(
          initialValue: addresses.any((a) => a.id == addressId)
              ? addressId
              : addresses.first.id,
          decoration: const InputDecoration(labelText: 'Deliver to'),
          items: addresses
              .map(
                (a) => DropdownMenuItem(
                  value: a.id,
                  child: Text(
                    '${a.label} · ${a.formatted}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onSelectAddress,
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onManageAddresses,
          icon: const Icon(Icons.edit_location_alt_outlined),
          label: const Text('Manage saved addresses'),
        ),
      ),
      Card(
        color: AppColors.paleGreen,
        child: ListTile(
          leading: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.emeraldPrimary,
          ),
          title: const Text('Pay automatically with QwikWallet'),
          subtitle: Text(
            'Current balance: ${money(walletBalanceCents)} · Estimated next order: ${money(estimatedTotalCents)}',
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          'The backend places the order at the selected time (India time). Keep enough demo credits and product stock available.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}
