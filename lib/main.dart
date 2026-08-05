import 'package:bea_service_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BEA Sonora — Técnicos',
      //theme: AppTheme.darkTheme, // Usa el tema oscuro definido en AppTheme
      theme: AppTheme.lightTheme, // Usa el tema claro definido en AppTheme
      //theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}