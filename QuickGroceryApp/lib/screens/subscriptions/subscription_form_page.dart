import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../widgets/common_widgets.dart';
import '../profile/profile_page.dart';
import 'widgets/subscription_address_wallet_section.dart';
import 'widgets/subscription_item_selector.dart';
import 'widgets/subscription_schedule_picker.dart';

class SubscriptionFormPage extends StatefulWidget {
  const SubscriptionFormPage({super.key, required this.api, this.existing});
  final ApiClient api;
  final GrocerySubscription? existing;

  @override
  State<SubscriptionFormPage> createState() => _SubscriptionFormPageState();
}

class _SubscriptionFormPageState extends State<SubscriptionFormPage> {
  late Future<void> _loading;
  List<Product> _products = [];
  CustomerProfile? _profile;
  WalletSummary? _wallet;
  final Map<String, int> _quantities = {};
  String? _addressId, _error;
  late DateTime _date;
  late TimeOfDay _time;
  late String _frequency;
  bool _busy = false;
  static const _frequencies = ['Daily', 'Weekly', 'Biweekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      for (final item in existing.items) {
        _quantities[item.productId] = item.quantity;
      }
    }
    final now = DateTime.now();
    _date = existing?.startDate ?? now.add(const Duration(days: 1));
    if (_date.isBefore(DateTime(now.year, now.month, now.day))) _date = now;
    final parts = (existing?.deliveryTime ?? '09:00').split(':');
    _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    _frequency = existing?.frequency ?? 'Daily';
    _addressId = existing?.addressId;
    _loading = _load();
  }

  Future<void> _load() async {
    final values = await Future.wait([
      widget.api.products(available: true),
      widget.api.profile(),
      widget.api.wallet(),
    ]);
    if (!mounted) return;
    _products = values[0] as List<Product>;
    _profile = values[1] as CustomerProfile;
    _wallet = values[2] as WalletSummary;
    _addressId ??=
        _profile!.addresses.isNotEmpty ? _profile!.addresses.first.id : null;
    setState(() {});
  }

  void _retryLoad() {
    final loading = _load();
    setState(() => _loading = loading);
  }

  int get _estimatedTotal {
    var sum = 0;
    for (final entry in _quantities.entries) {
      final match = _products.where((p) => p.id == entry.key);
      if (match.isNotEmpty) sum += match.first.priceCents * entry.value;
    }
    return sum;
  }

  Future<void> _save() async {
    if (_quantities.isEmpty) {
      setState(() => _error = 'Choose at least one product.');
      return;
    }
    if (_addressId == null) {
      setState(() => _error = 'Select a delivery address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final itemMaps = _quantities.entries
        .map((e) => {'productId': e.key, 'quantity': e.value})
        .toList();
    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    try {
      await widget.api.saveSubscription(
        id: widget.existing?.id,
        frequency: _frequency,
        deliveryTime: timeStr,
        startDate: _date,
        addressId: _addressId!,
        items: itemMaps,
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Could not save this scheduled order.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage(api: widget.api)),
    );
    await _load();
  }

  void _toggleProduct(Product p, bool selected) =>
      setState(() => selected ? _quantities[p.id] = 1 : _quantities.remove(p.id));

  void _incrementProduct(Product p) =>
      setState(() => _quantities[p.id] = (_quantities[p.id] ?? 0) + 1);

  void _decrementProduct(Product p) => setState(() {
        final n = (_quantities[p.id] ?? 1) - 1;
        n <= 0 ? _quantities.remove(p.id) : _quantities[p.id] = n;
      });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.existing == null
            ? 'Schedule order'
            : 'Edit scheduled order',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: FutureBuilder<void>(
          future: _loading,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Problem(
                message: 'Products and saved details could not load.',
                onRetry: _retryLoad,
              );
            }
            if (_products.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products available',
                detail:
                    'Add products to the catalog before scheduling an order.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SubscriptionItemSelector(
                  products: _products,
                  quantities: _quantities,
                  onToggle: _toggleProduct,
                  onIncrement: _incrementProduct,
                  onDecrement: _decrementProduct,
                ),
                const SizedBox(height: 12),
                SubscriptionSchedulePicker(
                  frequency: _frequency,
                  date: _date,
                  time: _time,
                  frequencies: _frequencies,
                  onFrequencyChanged: (v) =>
                      setState(() => _frequency = v ?? 'Daily'),
                  onPickDate: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  onPickTime: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _time,
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                ),
                const SizedBox(height: 14),
                SubscriptionAddressWalletSection(
                  addresses: _profile?.addresses ?? const [],
                  addressId: _addressId,
                  walletBalanceCents: _wallet?.balanceCents ?? 0,
                  estimatedTotalCents: _estimatedTotal,
                  onSelectAddress: (value) => setState(() => _addressId = value),
                  onManageAddresses: _addAddress,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const CircularProgressIndicator()
                      : const Text('Schedule order'),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
