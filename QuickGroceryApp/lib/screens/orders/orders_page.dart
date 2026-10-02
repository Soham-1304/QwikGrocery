part of '../../ui.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<GroceryOrder>> _orders;
  @override
  void initState() {
    super.initState();
    _orders = widget.api.orders();
  }

  void _retry() => setState(() => _orders = widget.api.orders());
  @override
  Widget build(BuildContext context) => FutureBuilder<List<GroceryOrder>>(
    future: _orders,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _Problem(message: 'Orders couldn’t load.', onRetry: _retry);
      }
      final orders = snapshot.data ?? [];
      if (orders.isEmpty) {
        return const _EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No orders yet',
          detail: 'Orders you place will appear here.',
        );
      }
      return ListView(
        padding: const EdgeInsets.all(18),
        children: orders
            .map(
              (order) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: _paleGreen,
                    child: Icon(
                      Icons.local_grocery_store_outlined,
                      color: _green,
                    ),
                  ),
                  title: Text(
                    'Order ${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${_statusLabel(order.status)} · ${order.createdAt.toLocal().toString().split('.').first}',
                  ),
                  trailing: Text(
                    money(order.totalCents),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrackingPage(order: order, api: widget.api),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}
