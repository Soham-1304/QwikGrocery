import 'package:flutter/material.dart';

import '../../models.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../state/cart_controller.dart';
import '../../widgets/common_widgets.dart';
import '../profile/profile_page.dart';
import '../wallet/wallet_page.dart';
import 'order_confirmation_page.dart';
import 'widgets/checkout_delivery_form.dart';
import 'widgets/payment_method_selector.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartController cart;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  CustomerProfile? _profile;
  WalletSummary? _wallet;
  SavedAddress? _selectedAddress;
  String? _selectedPaymentId = 'wallet';
  bool _busy = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await Future.wait([
        widget.api.profile(),
        widget.api.wallet(),
      ]);
      final profile = data[0] as CustomerProfile;
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _wallet = data[1] as WalletSummary;
        if (profile.addresses.isNotEmpty) {
          _selectedAddress = profile.addresses.first;
          _name.text = profile.addresses.first.recipientName;
          _phone.text = profile.addresses.first.phone;
          _address.text = profile.addresses.first.formatted;
        } else {
          _name.text = profile.name;
        }
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load your saved details. Open Profile and retry.';
        });
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await widget.api.createOrder(
        items: widget.cart.cartLines,
        name: _name.text,
        phone: _phone.text,
        address: _address.text,
        paymentMethodId: _selectedPaymentId,
        addressId: _selectedAddress?.id,
      );
      widget.cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationPage(order: order, api: widget.api),
        ),
      );
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () => _error =
            'The order could not be placed. Check your connection and retry.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checkout')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const LinearProgressIndicator(),
            CheckoutDeliveryForm(
              formKey: _form,
              nameController: _name,
              phoneController: _phone,
              addressController: _address,
              profile: _profile,
              selectedAddress: _selectedAddress,
              onSelectAddress: (address) => setState(() {
                _selectedAddress = address;
                if (address != null) {
                  _name.text = address.recipientName;
                  _phone.text = address.phone;
                  _address.text = address.formatted;
                }
              }),
              onManageAddresses: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage(api: widget.api)),
                );
                await _loadProfile();
              },
            ),
            const SizedBox(height: 22),
            PaymentMethodSelector(
              selectedPaymentId: _selectedPaymentId,
              wallet: _wallet,
              paymentMethods: _profile?.paymentMethods ?? const [],
              onChanged: (value) => setState(() => _selectedPaymentId = value),
              onOpenWallet: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WalletPage(api: widget.api)),
              ),
              onAddPayment: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage(api: widget.api)),
                );
                await _loadProfile();
              },
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Order summary',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...widget.cart.itemsList.map(
                      (line) => MoneyRow(
                        label: '${line.quantity} × ${line.product.name}',
                        cents: line.totalCents,
                      ),
                    ),
                    const Divider(height: 22),
                    MoneyRow(
                      label: 'Total payable',
                      cents: widget.cart.subtotalCents,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _placeOrder,
                child: _busy
                    ? const CircularProgressIndicator()
                    : const Text('Place order'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
