import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_page.dart';
import 'screens/staff/staff_orders_page.dart';
import 'screens/store/store_shell.dart';
import 'services/api_client.dart';
import 'services/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const QwikGroceryApp());
}

class QwikGroceryApp extends StatefulWidget {
  const QwikGroceryApp({super.key});

  @override
  State<QwikGroceryApp> createState() => _QwikGroceryAppState();
}

class _QwikGroceryAppState extends State<QwikGroceryApp> {
  late final SessionController session;
  late final ApiClient api;

  @override
  void initState() {
    super.initState();
    session = SessionController();
    api = ApiClient(session: session);
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'QwikGrocery',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: AnimatedBuilder(
      animation: session,
      builder: (_, __) {
        if (!session.isInitialized) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.emeraldPrimary,
              ),
            ),
          );
        }
        return session.signedIn
            ? _AuthRouter(session: session, api: api, key: ValueKey(session.uid))
            : AuthPage(session: session);
      },
    ),
  );
}

class _AuthRouter extends StatefulWidget {
  const _AuthRouter({
    super.key,
    required this.session,
    required this.api,
  });
  final SessionController session;
  final ApiClient api;

  @override
  State<_AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<_AuthRouter> {
  late Future<bool> _staffCheck;

  @override
  void initState() {
    super.initState();
    _staffCheck = widget.session.isStaff;
  }

  void _retry() => setState(() => _staffCheck = widget.session.isStaff);

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _staffCheck,
    builder: (ctx, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (snap.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('QwikGrocery')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not verify account access.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => widget.session.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      }
      if (snap.data == true) {
        return StaffOrdersPage(api: widget.api, session: widget.session);
      }
      return StoreShell(session: widget.session, api: widget.api);
    },
  );
}
