import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/session.dart';
import '../../state/cart_controller.dart';
import '../../state/cart_scope.dart';
import '../cart/cart_page.dart';
import '../catalog/catalog_page.dart';
import '../home/home_page.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';
import '../subscriptions/subscriptions_page.dart';
import '../wallet/wallet_page.dart';

/// Root shell: bottom nav / nav-rail, cart badge, and global CartScope.
class StoreShell extends StatefulWidget {
  const StoreShell({super.key, required this.session, required this.api});
  final SessionController session;
  final ApiClient api;

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  final _cart = CartController();
  int _index = 0;
  int _ordersKey = 0;
  int _subscriptionsKey = 0;
  String _activeCategory = '';
  bool _profileChecked = false;

  static const _titles = [
    'QwikGrocery',
    'Browse',
    'My Orders',
    'Schedule Orders',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptAddress());
  }

  Future<void> _promptAddress() async {
    if (_profileChecked || !mounted) return;
    _profileChecked = true;
    try {
      final profile = await widget.api.profile();
      if (!mounted || profile.addresses.isNotEmpty) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(api: widget.api, onboarding: true),
        ),
      );
    } catch (_) {}
  }

  void _openCart() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CartScope(
        controller: _cart,
        child: CartPage(api: widget.api, cart: _cart),
      ),
    ),
  );

  void _browseCatalog([String? category]) => setState(() {
    _index = 1;
    _activeCategory = category ?? '';
  });

  void _selectTab(int index) => setState(() {
    _index = index;
    if (index == 2) _ordersKey++;
    if (index == 3) _subscriptionsKey++;
  });

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(api: widget.api, cart: _cart, onBrowse: _browseCatalog),
      CatalogPage(
        key: ValueKey(_activeCategory),
        api: widget.api,
        cart: _cart,
        initialCategory: _activeCategory,
      ),
      OrdersPage(key: ValueKey(_ordersKey), api: widget.api),
      SubscriptionsPage(key: ValueKey(_subscriptionsKey), api: widget.api),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return CartScope(
      controller: _cart,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: _AppBarTitle(index: _index, titles: _titles),
          actions: [
            _CartBadge(cart: _cart, onTap: _openCart),
            _AccountMenu(
              session: widget.session,
              api: widget.api,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            if (wide)
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.emeraldLight,
                selectedIconTheme: const IconThemeData(
                  color: AppColors.emeraldPrimary,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search),
                    label: Text('Browse'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: Text('Orders'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.event_repeat_outlined),
                    selectedIcon: Icon(Icons.event_repeat),
                    label: Text('Schedule'),
                  ),
                ],
              ),
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.emeraldLight,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search),
                    label: 'Browse',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'Orders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.event_repeat_outlined),
                    selectedIcon: Icon(Icons.event_repeat),
                    label: 'Schedule',
                  ),
                ],
              ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({required this.index, required this.titles});
  final int index;
  final List<String> titles;

  @override
  Widget build(BuildContext context) => Text(
    titles[index],
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 19,
      color: AppColors.textPrimary,
    ),
  );
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.cart, required this.onTap});
  final CartController cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: cart,
    builder: (_, __) => IconButton(
      onPressed: onTap,
      tooltip: 'Cart · ${cart.totalQuantity} items',
      icon: Badge(
        isLabelVisible: cart.totalQuantity > 0,
        label: Text('${cart.totalQuantity}'),
        backgroundColor: AppColors.emeraldPrimary,
        child: const Icon(Icons.shopping_basket_outlined),
      ),
    ),
  );
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.session, required this.api});
  final SessionController session;
  final ApiClient api;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Account',
    icon: const Icon(Icons.account_circle_outlined),
    onSelected: (value) {
      switch (value) {
        case 'signout':
          unawaited(session.signOut());
        case 'profile':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage(api: api)),
          );
        case 'wallet':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WalletPage(api: api)),
          );
      }
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'email',
        enabled: false,
        child: Text(session.email ?? 'Account'),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem(value: 'profile', child: Text('Profile & Addresses')),
      const PopupMenuItem(value: 'wallet', child: Text('QwikWallet')),
      const PopupMenuItem(value: 'signout', child: Text('Sign out')),
    ],
  );
}
