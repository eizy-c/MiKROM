import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/views/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set clean system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: MiKromApp(),
    ),
  );
}

/// Root Application Widget for MiKROM.
class MiKromApp extends StatelessWidget {
  const MiKromApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiKROM Network Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}
