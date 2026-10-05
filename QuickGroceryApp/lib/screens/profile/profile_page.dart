import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../widgets/common_widgets.dart';
import 'widgets/address_dialog.dart';
import 'widgets/payment_dialog.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.api, this.onboarding = false});
  final ApiClient api;
  final bool onboarding;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CustomerProfile? _profile;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile = await widget.api.profile();
      if (mounted) setState(() {
        _profile = profile;
        _busy = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _busy = false;
        _error = 'Could not load your profile. Check your connection and retry.';
      });
    }
  }

  Future<void> _addAddress() async {
    final result = await showDialog<SavedAddress>(
      context: context,
      builder: (_) => const AddressDialog(),
    );
    if (result == null) return;
    try {
      await widget.api.addAddress(result);
      await _reload();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _addPayment() async {
    final result = await showDialog<PaymentDraft>(
      context: context,
      builder: (_) => const PaymentDialog(),
    );
    if (result == null) return;
    try {
      await widget.api.addPaymentMethod(
        type: result.type,
        label: result.label,
        lastFour: result.lastFour,
        upiId: result.upiId,
      );
      await _reload();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _removeAddress(SavedAddress address) async {
    await widget.api.deleteAddress(address.id);
    await _reload();
  }

  Future<void> _removePayment(SavedPaymentMethod method) async {
    await widget.api.deletePaymentMethod(method.id);
    await _reload();
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _profile?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      await widget.api.updateProfile(name: name);
      await _reload();
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.onboarding ? 'Delivery Setup' : 'Your Profile'),
    ),
    body: RefreshIndicator(
      onRefresh: _reload,
      child: Center(
        child: _busy && _profile == null
            ? const CircularProgressIndicator()
            : _error != null && _profile == null
            ? Problem(message: _error!, onRetry: _reload)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  ProfileHeaderCard(
                    profile: _profile,
                    onEditName: _editName,
                  ),
                  const SizedBox(height: 16),
                  ProfileSection(
                    title: 'Saved addresses',
                    action: 'Add address',
                    onAdd: _addAddress,
                    children: [
                      if (_profile?.addresses.isEmpty ?? true)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No addresses saved yet.'),
                        )
                      else
                        ..._profile!.addresses.map(
                          (address) => ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.emeraldPrimary,
                            ),
                            title: Text(address.label),
                            subtitle: Text(
                              '${address.recipientName} • ${address.line1}, ${address.city} (${address.postalCode})',
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove address',
                              onPressed: () => _removeAddress(address),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProfileSection(
                    title: 'Saved payment methods',
                    action: 'Add method',
                    onAdd: _addPayment,
                    children: [
                      if (_profile?.paymentMethods.isEmpty ?? true)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No demo payment methods saved.'),
                        )
                      else
                        ..._profile!.paymentMethods.map(
                          (method) => ListTile(
                            leading: Icon(
                              method.type == 'card'
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                              color: AppColors.emeraldPrimary,
                            ),
                            title: Text(method.display),
                            subtitle: const Text('Simulated payment method'),
                            trailing: IconButton(
                              tooltip: 'Remove payment method',
                              onPressed: () => _removePayment(method),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    ),
                  if (widget.onboarding)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          (_profile?.addresses.isNotEmpty ?? false)
                              ? 'Continue to groceries'
                              : 'Add address later',
                        ),
                      ),
                    ),
                ],
              ),
      ),
    ),
  );
}
