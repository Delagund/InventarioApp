import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/add_product_dialog.dart';

class DashboardGrid extends StatefulWidget {
  const DashboardGrid({super.key});

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  // Estado para el modo de selección
  bool _isSelectionMode = false;
  final Set<int> _selectedProductIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedProductIds.clear();
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  Future<void> _deleteSelectedProducts() async {
    if (_selectedProductIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar productos'),
        content: Text('¿Estás seguro de que deseas eliminar ${_selectedProductIds.length} productos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productVM = context.read<ProductViewModel>();
      // Copiamos la lista para iterar
      final idsToDelete = List<int>.from(_selectedProductIds);
      
      for (final id in idsToDelete) {
        await productVM.deleteProduct(id);
      }
      
      // Actualizar los contadores del Sidebar
      if (mounted) context.read<CategoryViewModel>().loadCategories();

      _toggleSelectionMode();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${idsToDelete.length} productos eliminados')),
        );
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
  void _onCategoryChanged() {
    if (!mounted) return;
    final selectedCategory = context.read<CategoryViewModel>().selectedCategory;
    context.read<ProductViewModel>().loadProducts(category: selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    // Encabezado dinámico
    final title = categoryVM.selectedCategory?.name ?? "Todos los productos";

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
            children: _isSelectionMode 
              ? [
                  IconButton(
                    onPressed: _toggleSelectionMode, 
                    icon: const Icon(Icons.close),
                    tooltip: "Cancelar selección",
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${_selectedProductIds.length} seleccionados",
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: _selectedProductIds.isEmpty ? null : _deleteSelectedProducts,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Eliminar"),
                  ),
                ]
              : [
                  // Usamos Expanded para que el texto ocupe el espacio disponible y empuje los botones
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis, // Corta con "..." si es muy largo
                      maxLines: 1,
                    ),
                  ),
                  // Botón para activar modo selección
                  IconButton(
                    onPressed: _toggleSelectionMode,
                    icon: const Icon(Icons.checklist),
                    tooltip: "Seleccionar productos",
                  ),
                  const SizedBox(width: 8),
                  // Aquí irán filtros de ordenamiento en el futuro
                  IconButton(onPressed: () {},
                  icon: const Icon(Icons.sort)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FilledButton.icon(
                      onPressed: () { showDialog(
                        context: context,
                        builder: (context) => const AddProductDialog(),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Nuevo Producto", 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  )
                ],
          ),
        ),

        // Grilla de Productos
        Expanded(
          child: productVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productVM.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "No hay productos en esta categoría",
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250, // Ancho máximo de la tarjeta
                        childAspectRatio: 0.75,  // Relación de aspecto (Alto/Ancho)
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productVM.products.length,
                      itemBuilder: (context, index) {
                        final product = productVM.products[index];
                        final isSelected = _selectedProductIds.contains(product.id);
                        
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ProductCard(
                              product: product,
                              onTap: _isSelectionMode 
                                  ? () => _toggleProductSelection(product.id!)
                                  : () {
                                      // TODO: Seleccionar producto para el Inspector
                                    },
                            ),
                            if (_isSelectionMode) ...[
                              IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected 
                                        ? Border.all(color: theme.colorScheme.primary, width: 3)
                                        : null,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (v) => _toggleProductSelection(product.id!),
                                ),
                              ),
                            ]
                          ],
                        );
                      },
                    ),
        ),
      ],
    );
  }
}