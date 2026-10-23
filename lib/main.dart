import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/activity_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()..init()),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();

    Widget child;
    if (provider.isLoading) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (provider.error != null) {
      child = Scaffold(
        key: const ValueKey('error'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(provider.error!, textAlign: TextAlign.center),
          ),
        ),
      );
    } else {
      child = const HomeShell(key: ValueKey('home'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: child,
    );
  }
}
