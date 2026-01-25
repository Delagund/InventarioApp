import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/add_product_dialog.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/common/error_view.dart';

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({super.key});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  // Estado local para el modo de selección (AHORA EN VIEWMODEL)

  Future<void> _deleteSelectedProducts() async {
    final productVM = context.read<ProductViewModel>();
    if (productVM.selectedProductIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          AppStrings.eliminarProductos,
        ), // Replaced hardcoded string
        content: Text(
          AppStrings.confirmarEliminarProductos(
            productVM.selectedProductIds.length,
          ), // Replaced hardcoded string
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancelar), // Replaced hardcoded string
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.eliminar), // Replaced hardcoded string
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final count = productVM.selectedProductIds.length;
      await productVM.deleteSelectedProducts();

      // Actualizar los contadores del Sidebar
      if (mounted) context.read<CategoryViewModel>().loadCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.productosEliminados(count))),
        ); // Replaced hardcoded string
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Suscribirse a cambios en la categoría
    final categoryVM = context.read<CategoryViewModel>();
    categoryVM.addListener(_onCategoryChanged);

    // Carga inicial (post frame para evitar errores de construcción)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onCategoryChanged();
    });
  }

  @override
  void dispose() {
    context.read<CategoryViewModel>().removeListener(_onCategoryChanged);
    super.dispose();
  }

  // Cuando la categoría cambia en el Sidebar, recargamos los productos
  Future<void> _onCategoryChanged() {
    if (!mounted) return Future.value();
    final selectedCategory = context.read<CategoryViewModel>().selectedCategory;
    return context.read<ProductViewModel>().filterByCategory(
      selectedCategory?.id,
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header del Dashboard
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
            color: theme.colorScheme.surface,
          ),
          child: Row(
            children: productVM.isSelectionMode
                ? [
                    IconButton(
                      onPressed: () => productVM.toggleSelectionMode(),
                      icon: const Icon(Icons.close),
                      tooltip: AppStrings.cancelarSeleccion,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.productosSeleccionados(
                          productVM.selectedProductIds.length,
                        ),
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: productVM.selectedProductIds.isEmpty
                          ? null
                          : _deleteSelectedProducts,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(AppStrings.eliminar),
                    ),
                  ]
                : [
                    // 1. Buscador Global dinámico
                    Flexible(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: SearchBar(
                          hintText: AppStrings.buscarProductos,
                          leading: const Icon(Icons.search),
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor: WidgetStateProperty.all(
                            theme.colorScheme.surfaceContainerLow,
                          ),
                          onChanged: (value) => productVM.updateSearch(value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Ordenamiento (Compacto)
                    PopupMenuButton<int>(
                      tooltip: AppStrings.ordenarPor,
                      icon: const Icon(Icons.sort),
                      onSelected: (value) {
                        switch (value) {
                          case 0:
                            productVM.updateSort();
                            break;
                          case 1:
                            productVM.updateSort(stockAsc: true);
                            break;
                          case 2:
                            productVM.updateSort(dateDesc: true);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Text(AppStrings.nombreAZ),
                        ),
                        const PopupMenuItem(
                          value: 1,
                          child: Text(AppStrings.stockMinimo),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Text(AppStrings.fechaReciente),
                        ),
                      ],
                    ),

                    // 3. Selección y Añadir
                    IconButton(
                      onPressed: () => productVM.toggleSelectionMode(),
                      icon: const Icon(Icons.checklist),
                      tooltip: AppStrings.seleccionarProductos,
                    ),
                    const SizedBox(width: 4),

                    // Botón con tamaño adaptativo
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = MediaQuery.of(context).size.width;
                        final isCompact = width < 1000;

                        return isCompact
                            ? IconButton.filled(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                                tooltip: AppStrings.nuevoProducto,
                              )
                            : FilledButton.icon(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text(AppStrings.nuevoProducto),
                              );
                      },
                    ),
                  ],
          ),
        ),

        // Grilla de Productos
        Expanded(
          child: productVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productVM.errorMessage != null
              ? ErrorView(
                  message: productVM.errorMessage!,
                  onRetry: () => _onCategoryChanged(),
                )
              : productVM.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings
                            .noProductosEnCategoria, // Replaced hardcoded string
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, gridConstraints) {
                    final crossAxisExtent = gridConstraints.maxWidth;
                    // Evitar el error de crossAxisExtent > 0.0
                    if (crossAxisExtent <= 10) return const SizedBox.shrink();

                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productVM.products.length,
                      itemBuilder: (context, index) {
                        final product = productVM.products[index];
                        final isSelected = productVM.selectedProductIds
                            .contains(product.id);

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ProductCard(
                              product: product,
                              onTap: productVM.isSelectionMode
                                  ? () => productVM.toggleProductSelection(
                                      product.id!,
                                    )
                                  : () {
                                      context
                                          .read<ProductViewModel>()
                                          .selectProduct(product);
                                    },
                            ),
                            if (productVM.isSelectionMode) ...[
                              IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: theme.colorScheme.primary,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => productVM
                                      .toggleProductSelection(product.id!),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
