import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product.dart';
import '../../presentation/viewmodels/product_viewmodel.dart';
import '../../presentation/viewmodels/category_viewmodel.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_layout.dart';

// Componentes atómicos
import 'inspector/product_header.dart';
import 'inspector/stock_control.dart';
import 'inspector/category_editor.dart';
import 'inspector/movement_history_list.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  void _showDeleteConfirm(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.eliminarProducto),
        content: Text(
          "Estás a punto de eliminar '${product.name}'. Esta acción es irreversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancelar),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ProductViewModel>().deleteProduct(product.id!);
              if (context.mounted) {
                context.read<ProductViewModel>().selectProduct(null);
                context.read<CategoryViewModel>().loadCategories();
              }
            },
            child: const Text(AppStrings.eliminar),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final product = productVM.selectedProduct;
    final theme = Theme.of(context);

    if (product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppLayout.spaceM),
            Text(
              AppStrings.seleccionarProducto,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppLayout.spaceL),
              children: [
                ProductHeader(product: product),
                const SizedBox(height: AppLayout.spaceXL),

                const Divider(),
                const SizedBox(height: AppLayout.spaceL),

                StockControl(product: product),
                const SizedBox(height: AppLayout.spaceXL),

                const Divider(),
                const SizedBox(height: AppLayout.spaceL),

                CategoryEditor(product: product),
                const SizedBox(height: AppLayout.spaceXL),

                const Divider(),
                const SizedBox(height: AppLayout.spaceL),

                MovementHistoryList(history: productVM.history),
                const SizedBox(height: AppLayout.spaceXL),
              ],
            ),
          ),

          // Botón Eliminar persistente al final
          Padding(
            padding: const EdgeInsets.all(AppLayout.spaceL),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppLayout.spaceM,
                    horizontal: AppLayout.spaceM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppLayout.radiusM),
                  ),
                ),
                onPressed: () => _showDeleteConfirm(context, product),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  AppStrings.eliminarProducto.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
