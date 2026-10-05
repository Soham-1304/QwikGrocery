import 'package:flutter/material.dart';

import '../../components/delivery_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_client.dart';
import '../../state/cart_controller.dart';
import '../../state/cart_scope.dart';
import '../checkout/checkout_page.dart';
import 'widgets/cart_bill_card.dart';
import 'widgets/cart_item_row.dart';

/// Full cart page with item list, free-delivery meter, delivery instructions,
/// and transparent bill breakdown.
class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartController cart;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Set<String> _instructions = {};

  static const _instructionOptions = [
    '🚪 Leave at door',
    '🔔 Don\'t ring bell',
    '📵 Avoid calling',
    '🐕 Beware of dog',
  ];

  @override
  Widget build(BuildContext context) {
    return CartScope(
      controller: widget.cart,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Your Cart'),
          backgroundColor: AppColors.surface,
        ),
        body: ListenableBuilder(
          listenable: widget.cart,
          builder: (ctx, _) {
            final items = widget.cart.itemsList;
            if (items.isEmpty) return const _EmptyCart();
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const DeliveryMeter(),
                      const SizedBox(height: 16),
                      ...items.map((item) => CartItemRow(
                        item: item,
                        cart: widget.cart,
                      )),
                      const SizedBox(height: 16),
                      _InstructionChips(
                        selected: _instructions,
                        options: _instructionOptions,
                        onToggle: (val) => setState(() {
                          _instructions.contains(val)
                              ? _instructions.remove(val)
                              : _instructions.add(val);
                        }),
                      ),
                      const SizedBox(height: 16),
                      CartBillCard(cart: widget.cart),
                    ],
                  ),
                ),
                _CheckoutBar(
                  cart: widget.cart,
                  api: widget.api,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.shopping_basket_outlined,
          size: 64,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 16),
        const Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Browse the catalog to add groceries.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continue shopping'),
        ),
      ],
    ),
  );
}

class _InstructionChips extends StatelessWidget {
  const _InstructionChips({
    required this.selected,
    required this.options,
    required this.onToggle,
  });
  final Set<String> selected;
  final List<String> options;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Delivery Instructions',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isOn = selected.contains(opt);
          return FilterChip(
            label: Text(opt),
            selected: isOn,
            onSelected: (_) => onToggle(opt),
            selectedColor: AppColors.emeraldLight,
            checkmarkColor: AppColors.emeraldPrimary,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isOn ? AppColors.emeraldDark : AppColors.textPrimary,
              fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        }).toList(),
      ),
    ],
  );
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart, required this.api});
  final CartController cart;
  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    final total = cart.total;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${cart.totalQuantity} item${cart.totalQuantity != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScope(
                      controller: cart,
                      child: CheckoutPage(api: api, cart: cart),
                    ),
                  ),
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
