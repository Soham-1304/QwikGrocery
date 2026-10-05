import 'package:flutter/material.dart';

import '../../../models.dart';

/// Delivery address picker and contact details form for CheckoutPage.
class CheckoutDeliveryForm extends StatelessWidget {
  const CheckoutDeliveryForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.profile,
    required this.selectedAddress,
    required this.onSelectAddress,
    required this.onManageAddresses,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final CustomerProfile? profile;
  final SavedAddress? selectedAddress;
  final ValueChanged<SavedAddress?> onSelectAddress;
  final VoidCallback onManageAddresses;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Delivery details',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: 16),
      if (profile != null && profile!.addresses.isNotEmpty) ...[
        DropdownButtonFormField<SavedAddress>(
          value: selectedAddress,
          decoration: const InputDecoration(
            labelText: 'Saved delivery address',
          ),
          items: profile!.addresses
              .map(
                (address) => DropdownMenuItem(
                  value: address,
                  child: Text(
                    '${address.label} · ${address.formatted}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onSelectAddress,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onManageAddresses,
            icon: const Icon(Icons.add),
            label: const Text('Manage saved addresses'),
          ),
        ),
      ],
      Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  v == null || v.trim().length < 2 ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: (v) =>
                  v == null || v.replaceAll(RegExp(r'\D'), '').length < 8
                      ? 'Enter a valid phone number'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: addressController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Delivery address'),
              validator: (v) =>
                  v == null || v.trim().length < 8
                      ? 'Enter a complete delivery address'
                      : null,
            ),
          ],
        ),
      ),
    ],
  );
}
