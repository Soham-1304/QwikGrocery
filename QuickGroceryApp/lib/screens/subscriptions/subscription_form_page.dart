part of '../../ui.dart';

class SubscriptionFormPage extends StatefulWidget {
  const SubscriptionFormPage({super.key, required this.api, this.existing});
  final ApiClient api;
  final GrocerySubscription? existing;
  @override
  State<SubscriptionFormPage> createState() => _SubscriptionFormPageState();
}

class _SubscriptionFormPageState extends State<SubscriptionFormPage> {
  final _form = GlobalKey<FormState>();
  late Future<List<Product>> _products;
  String? _productId;
  late int _quantity;
  late String _frequency;
  late DateTime _date;
  late TimeOfDay _time;
  bool _busy = false;
  String? _error;
  static const _frequencies = ['Daily', 'Weekly', 'Biweekly', 'Monthly'];
  @override
  void initState() {
    super.initState();
    _products = widget.api.products(
      available: widget.existing == null ? true : null,
    );
    final old = widget.existing;
    _productId = old?.productId;
    _quantity = old?.quantity ?? 1;
    _frequency = old?.frequency ?? 'Weekly';
    final today = DateTime.now();
    _date = old == null
        ? today.add(const Duration(days: 1))
        : old.startDate.isBefore(DateTime(today.year, today.month, today.day))
        ? today
        : old.startDate;
    final parts = (old?.deliveryTime ?? '09:00').split(':');
    _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _productId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.saveSubscription(
        id: widget.existing?.id,
        productId: _productId!,
        quantity: _quantity,
        frequency: _frequency,
        startDate: _date,
        deliveryTime:
            '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(
        () => _error =
            'Couldn’t save this schedule. Check your connection and retry.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.existing == null ? 'Schedule an order' : 'Edit schedule',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: FutureBuilder<List<Product>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Problem(
                message: 'Products couldn’t load.',
                onRetry: () => setState(() {
                  _products = widget.api.products(
                    available: widget.existing == null ? true : null,
                  );
                }),
              );
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const _EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products available',
                detail:
                    'Add products to the catalog before scheduling an order.',
              );
            }
            final value = products.any((p) => p.id == _productId)
                ? _productId
                : products.first.id;
            return Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: value,
                    decoration: const InputDecoration(labelText: 'Grocery'),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} · ${money(p.priceCents)}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _productId = v),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _frequency,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: _frequencies
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _frequency = v ?? 'Weekly'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _date.isBefore(DateTime.now())
                                  ? DateTime.now()
                                  : _date,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2),
                              ),
                            );
                            if (date != null) setState(() => _date = date);
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _time,
                            );
                            if (time != null) setState(() => _time = time);
                          },
                          icon: const Icon(Icons.schedule),
                          label: Text(_time.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: '$_quantity',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 ? 'Enter at least one' : null;
                    },
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) _quantity = n;
                    },
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _save,
                      child: _busy
                          ? const CircularProgressIndicator()
                          : const Text('Save schedule'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
