import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

// Importa el contenedor de inyección
import 'injection_container.dart' as di;

import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/viewmodels/category_viewmodel.dart';
import 'presentation/screens/main_layout.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Aseguramos que los widgets estén vinculados antes de inicializar cosas async
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SQLite para escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Inicializar Window Manager para límites de ventana
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(1000, 700),
      center: true,
      title: 'Inventario App',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // --- INICIALIZAMOS LA INYECCIÓN DE DEPENDENCIAS ---
  await di.init();
  // --------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inyectamos los ViewModels usando GetIt
        ChangeNotifierProvider(create: (_) => di.getIt<ProductViewModel>()),
        ChangeNotifierProvider(create: (_) => di.getIt<CategoryViewModel>()),
      ],
      child: MaterialApp(
        title: 'Inventario Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainLayout(),
      ),
    );
  }
}
