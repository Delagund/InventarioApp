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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSidebar = constraints.maxWidth > 800;
          final showInspector = constraints.maxWidth > 1100;

          return Row(
            children: [
              // COLUMNA 1: Sidebar (Navegación)
              if (showSidebar) ...[
                const Sidebar(),
                const VerticalDivider(width: 1, thickness: 1),
              ],

              // COLUMNA 2: Dashboard (Grid de Productos)
              // Usamos Expanded para que ocupe todo el espacio disponible central
              Expanded(
                child: Container(
                  color: theme.colorScheme.surface,
                  child: const DashboardGrid(),
                ),
              ),

              // COLUMNA 3: Inspector (Detalles y Stock)
              if (showInspector) ...[
                const VerticalDivider(width: 1, thickness: 1),
                const SizedBox(width: 350, child: InspectorPanel()),
              ],
            ],
          );
        },
      ),
    );
  }
}
