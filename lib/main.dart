import 'package:flutter/material.dart';
import 'package:APK_TRAYA/views/auth_pages.dart';
import 'package:APK_TRAYA/utils/session_manager.dart';
import 'package:APK_TRAYA/components.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: () => SessionManager(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TRaya - Thrift Marketplace',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: orangeTraya,
            secondary: brownTraya,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: brownTraya),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: orangeTraya),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// ============ PROVIDER IMPLEMENTATION ============

class ChangeNotifierProvider extends StatefulWidget {
  final Widget child;
  final ChangeNotifier Function() create;

  const ChangeNotifierProvider({
    super.key,
    required this.child,
    required this.create,
  });

  @override
  State<ChangeNotifierProvider> createState() => _ChangeNotifierProviderState();
}

class _ChangeNotifierProviderState extends State<ChangeNotifierProvider> {
  late ChangeNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ProviderScope(
      value: _notifier,
      child: widget.child,
    );
  }
}

class _ProviderScope extends InheritedWidget {
  final ChangeNotifier value;

  const _ProviderScope({
    required this.value,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ProviderScope oldWidget) {
    return value != oldWidget.value;
  }

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ProviderScope>();
    if (scope != null) {
      return scope.value as T;
    }
    throw Exception('Provider not found');
  }
}

extension ProviderExtension on BuildContext {
  T watch<T extends ChangeNotifier>() {
    return _ProviderScope.of<T>(this);
  }
}