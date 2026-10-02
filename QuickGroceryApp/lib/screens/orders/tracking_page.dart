part of '../../ui.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.order, required this.api});
  final GroceryOrder order;
  final ApiClient api;
  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late Future<GroceryOrder> _order;
  static const _statuses = [
    'placed',
    'confirmed',
    'preparing',
    'out_for_delivery',
    'delivered',
  ];
  @override
  void initState() {
    super.initState();
    _order = widget.api.order(widget.order.id);
  }

  void _refresh() => setState(() => _order = widget.api.order(widget.order.id));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Delivery tracking'),
      actions: [
        IconButton(
          onPressed: _refresh,
          tooltip: 'Refresh status',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<GroceryOrder>(
      future: _order,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Problem(
            message: 'Delivery status couldn’t load.',
            onRetry: _refresh,
          );
        }
        final order = snapshot.data!;
        final current = _statuses.indexOf(order.status);
        return ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              'Order ${order.id}',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              money(order.totalCents),
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 8),
            Text(
              'Current status: ${_statusLabel(order.status)}',
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: List.generate(
                    _statuses.length,
                    (i) => _StatusStep(
                      label: _statusLabel(_statuses[i]),
                      active: i <= current,
                      last: i == _statuses.length - 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: _green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery address',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(order.address),
                          const SizedBox(height: 14),
                          const Text(
                            'Live location is not available for this order yet.',
                            style: TextStyle(color: _muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.label,
    required this.active,
    required this.last,
  });
  final String label;
  final bool active;
  final bool last;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? _green : Colors.white,
                  border: Border.all(
                    color: active ? _green : const Color(0xFFBEC8BE),
                  ),
                ),
                child: active
                    ? const Icon(Icons.check, size: 11, color: Colors.white)
                    : null,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    color: active ? _green : const Color(0xFFDCE3DB),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 18),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                color: active ? Colors.black87 : _muted,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
