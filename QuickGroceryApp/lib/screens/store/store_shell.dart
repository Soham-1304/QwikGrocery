part of '../../ui.dart';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key, required this.session, required this.api});
  final SessionController session;
  final ApiClient api;
  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  final _cart = CartStore();
  int _index = 0;
  int _ordersKey = 0;
  String _activeCategory = '';
  final _titles = const [
    'Your groceries',
    'Browse products',
    'Your orders',
    'Subscriptions',
  ];

  void _openCart() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CartPage(api: widget.api, cart: _cart),
    ),
  );

  void _browseCatalog([String? category]) {
    setState(() {
      _index = 1;
      _activeCategory = category ?? '';
    });
  }

  void _selectTab(int index) {
    setState(() {
      _index = index;
      if (index == 2) _ordersKey++;
    });
  }

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
      SubscriptionsPage(api: widget.api),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) => IconButton(
              onPressed: _openCart,
              tooltip: 'Cart, ${_cart.count} items',
              icon: Badge(
                isLabelVisible: _cart.count > 0,
                label: Text('${_cart.count}'),
                child: const Icon(Icons.shopping_basket_outlined),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'signout') unawaited(widget.session.signOut());
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'email',
                enabled: false,
                child: Text(widget.session.email ?? 'Account'),
              ),
              const PopupMenuItem(value: 'signout', child: Text('Sign out')),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _selectTab,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Browse'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_repeat_outlined),
                  label: Text('Subscriptions'),
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Browse',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_repeat_outlined),
                  label: 'Repeat',
                ),
              ],
            ),
    );
  }
}
