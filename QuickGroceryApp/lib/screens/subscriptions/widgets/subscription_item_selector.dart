import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../models.dart';

/// Product selection list with search and quantity steppers for subscriptions.
class SubscriptionItemSelector extends StatefulWidget {
  const SubscriptionItemSelector({
    super.key,
    required this.products,
    required this.quantities,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<Product> products;
  final Map<String, int> quantities;
  final void Function(Product product, bool selected) onToggle;
  final void Function(Product product) onIncrement;
  final void Function(Product product) onDecrement;

  @override
  State<SubscriptionItemSelector> createState() =>
      _SubscriptionItemSelectorState();
}

class _SubscriptionItemSelectorState extends State<SubscriptionItemSelector> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.products
        .where(
          (product) => '${product.name} ${product.category}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we deliver?',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Find groceries',
          ),
        ),
        const SizedBox(height: 8),
        ...visible.map(
          (product) => Card(
            child: ListTile(
              leading: Checkbox(
                value: widget.quantities.containsKey(product.id),
                onChanged: (selected) =>
                    widget.onToggle(product, selected == true),
              ),
              title: Text(product.name),
              subtitle: Text(
                '${product.category} · ${money(product.priceCents)}',
              ),
              trailing: widget.quantities.containsKey(product.id)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => widget.onDecrement(product),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${widget.quantities[product.id]}'),
                        IconButton(
                          onPressed: () => widget.onIncrement(product),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
