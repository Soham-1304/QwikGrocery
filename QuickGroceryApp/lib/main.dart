import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/api_client.dart';
import 'services/session.dart';
import 'ui.dart';

const _green = Color(0xFF2E6B45);
const _deepGreen = Color(0xFF17452B);
const _yellow = Color(0xFFF2C84B);
const _black = Color(0xFF171A17);
const _paper = Color(0xFFFAFBF8);
const _paleGreen = Color(0xFFE9F1E9);
const _paleYellow = Color(0xFFFFF4CF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const QuickGroceryApp());
}

class QuickGroceryApp extends StatefulWidget {
  const QuickGroceryApp({super.key});

  @override
  State<QuickGroceryApp> createState() => _QuickGroceryAppState();
}

class _QuickGroceryAppState extends State<QuickGroceryApp> {
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
    title: 'QuickGrocery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _green,
            surface: Colors.white,
          ).copyWith(
            primary: _green,
            onPrimary: Colors.white,
            primaryContainer: _paleGreen,
            onPrimaryContainer: _deepGreen,
            secondary: _yellow,
            onSecondary: _black,
            secondaryContainer: _paleYellow,
            onSecondaryContainer: _black,
            surface: Colors.white,
            onSurface: _black,
            outline: const Color(0xFFDCE4DC),
          ),
      scaffoldBackgroundColor: _paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: _paper,
        foregroundColor: _black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFDCE4DC)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellow,
        foregroundColor: _black,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _paleYellow,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _paleGreen,
        selectedColor: _yellow,
        side: BorderSide.none,
        labelStyle: const TextStyle(color: _deepGreen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      visualDensity: VisualDensity.standard,
    ),
    home: AnimatedBuilder(
      animation: session,
      builder: (context, _) => session.signedIn
          ? StoreShell(session: session, api: api)
          : AuthPage(session: session),
    ),
  );
}
