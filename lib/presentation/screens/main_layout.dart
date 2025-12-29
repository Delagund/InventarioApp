import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // COLUMNA 1: Sidebar (Navegación)
          // Ya tenemos el widget Sidebar creado
          const Sidebar(),
          
          // Divisor vertical
          const VerticalDivider(width: 1, thickness: 1),

          // COLUMNA 2: Dashboard (Grid de Productos)
          // Usamos Expanded para que ocupe todo el espacio disponible central
          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      "Dashboard Grid",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const Text("Aquí se mostrarán los productos filtrados"),
                  ],
                ),
              ),
            ),
          ),

          // Divisor vertical
          const VerticalDivider(width: 1, thickness: 1),

          // COLUMNA 3: Inspector (Detalles y Stock)
          // Ancho fijo de 300px (típico para paneles de detalles en escritorio)
          Container(
            width: 300,
            color: theme.colorScheme.surfaceContainerLow,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    "Inspector",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Text("Selecciona un producto"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}