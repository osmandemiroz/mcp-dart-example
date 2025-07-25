import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcp_dart_example/core/theme/app_theme.dart';
import 'package:mcp_dart_example/presentation/pages/home_page.dart';
import 'package:mcp_dart_example/presentation/providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: MCPDartProApp(),
    ),
  );
}

/// Enhanced MCP Dart Pro application with modern architecture
class MCPDartProApp extends ConsumerWidget {
  /// MCPDartProApp constructor
  const MCPDartProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'MCP Dart Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
