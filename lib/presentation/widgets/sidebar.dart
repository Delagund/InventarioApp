import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_viewmodel.dart';
import '../../domain/models/category.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumimos el ViewModel para reaccionar a cambios
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    return Container(
      width: 250, // Ancho fijo típico de sidebar
      color: theme.colorScheme.surfaceContainerLow, // Color de fondo sutil
      child: Column(
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Inventario",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                // Opción "Todos los productos" (Categoría null)
                _SidebarItem(
                  icon: Icons.dashboard,
                  title: "Todos los productos",
                  isSelected: categoryVM.selectedCategory == null,
                  onTap: () => categoryVM.selectCategory(null),
                  // Opcional: Podrías sumar todos los productCounts aquí si quisieras
                ),

                const Divider(height: 20),

                Text(
                  "CATEGORÍAS",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),

                // Lista dinámica desde la BD
                if (categoryVM.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ...categoryVM.categories.map((category) => _SidebarItem(
                        category: category,
                        icon: Icons.folder_open,
                        title: category.name,
                        // Aquí usamos el productCount calculado por SQLite
                        count: category.productCount, 
                        isSelected: categoryVM.selectedCategory?.id == category.id,
                        onTap: () => categoryVM.selectCategory(category),
                      )),
              ],
            ),
          ),

          // Botón Agregar Categoría
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.tonalIcon(
              onPressed: () {
                _showAddCategoryDialog(context, categoryVM);
              },
              icon: const Icon(Icons.add),
              label: const Text("Nueva Categoría"),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva Categoría"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nombre"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.addCategory(controller.text, null);
                Navigator.pop(context);
              }
            },
            child: const Text("Crear"),
          )
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final Category? category;
  final IconData icon;
  final String title;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    this.category,
    required this.icon,
    required this.title,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            // Botón para eliminar la categoría (si existe el objeto)
            if (category != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                tooltip: "Eliminar categoría",
                onPressed: () => context.read<CategoryViewModel>().deleteCategory(category!.id!),
              ),
          ],
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}