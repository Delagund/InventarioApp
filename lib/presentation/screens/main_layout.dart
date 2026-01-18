import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/inspector_panel.dart';
import 'dashboard_grid.dart';

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
              child: const DashboardGrid(),
            ),
          ),

          // Divisor vertical
          const VerticalDivider(width: 1, thickness: 1),

          // COLUMNA 3: Inspector (Detalles y Stock)
          SizedBox(
            width: 350, // Ancho fijo para el panel lateral
            child: const InspectorPanel(),
          ),
        ],
      ),
    );
  }
}