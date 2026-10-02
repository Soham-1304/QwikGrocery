part of '../../ui.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  late Future<List<GrocerySubscription>> _subscriptions;
  @override
  void initState() {
    super.initState();
    _subscriptions = widget.api.subscriptions();
  }

  void _reload() => setState(() => _subscriptions = widget.api.subscriptions());
  Future<void> _edit([GrocerySubscription? subscription]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SubscriptionFormPage(api: widget.api, existing: subscription),
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _toggle(GrocerySubscription sub) async {
    try {
      await widget.api.setSubscriptionActive(sub.id, !sub.active);
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Schedule order'),
    ),
    body: FutureBuilder<List<GrocerySubscription>>(
      future: _subscriptions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _Problem(
            message: 'Subscriptions couldn’t load.',
            onRetry: _reload,
          );
        }
        final values = snapshot.data ?? [];
        if (values.isEmpty) {
          return const _EmptyState(
            icon: Icons.event_repeat_outlined,
            title: 'No recurring orders',
            detail: 'Schedule a grocery delivery to get started.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: values
              .map(
                (sub) => Card(
                  child: ListTile(
                    leading: Icon(
                      sub.active
                          ? Icons.event_repeat
                          : Icons.pause_circle_outline,
                      color: sub.active ? _green : _muted,
                    ),
                    title: Text(
                      '${sub.quantity} × ${sub.productName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${sub.frequency} · ${sub.startDate.toLocal().toString().split(' ').first} · ${sub.deliveryTime} · ${sub.active ? 'Active' : 'Paused'}',
                    ),
                    onTap: () => _edit(sub),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _edit(sub);
                        if (value == 'toggle') _toggle(sub);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(sub.active ? 'Pause' : 'Reactivate'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
