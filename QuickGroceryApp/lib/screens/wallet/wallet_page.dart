import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../widgets/common_widgets.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Future<WalletSummary> _wallet;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _wallet = widget.api.wallet();
  }

  void _reload() {
    final wallet = widget.api.wallet();
    setState(() => _wallet = wallet);
  }

  Future<void> _topUp(int amount) async {
    setState(() => _busy = true);
    try {
      await widget.api.topUpWallet(amount);
      _reload();
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QwikWallet')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: FutureBuilder<WalletSummary>(
          future: _wallet,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Problem(
                message: 'Wallet could not load.',
                onRetry: _reload,
              );
            final wallet = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: AppColors.emeraldLight,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available demo credits',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          money(wallet.balanceCents),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Credits are simulated for this prototype. No money is charged or withdrawable.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add demo credits',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    for (final amount in [5000, 10000, 25000, 50000])
                      OutlinedButton(
                        onPressed: _busy ? null : () => _topUp(amount),
                        child: Text('+ ${money(amount)}'),
                      ),
                  ],
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Wallet activity',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (wallet.transactions.isEmpty)
                  const ListTile(
                    title: Text('No wallet activity yet.'),
                    subtitle: Text(
                      'Demo top-ups and order payments will appear here.',
                    ),
                  ),
                ...wallet.transactions.map(
                  (entry) => Card(
                    child: ListTile(
                      leading: Icon(
                        entry.amountCents < 0
                            ? Icons.shopping_bag_outlined
                            : Icons.add_circle_outline,
                        color: entry.amountCents < 0
                            ? AppColors.textSecondary
                            : AppColors.emeraldPrimary,
                      ),
                      title: Text(entry.note),
                      subtitle: Text(
                        entry.createdAt
                                ?.toLocal()
                                .toString()
                                .split('.')
                                .first ??
                            'Just now',
                      ),
                      trailing: Text(
                        '${entry.amountCents < 0 ? '−' : '+'}${money(entry.amountCents.abs())}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: entry.amountCents < 0
                              ? AppColors.textPrimary
                              : AppColors.emeraldPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
