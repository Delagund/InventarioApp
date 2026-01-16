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
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              // Aquí irán filtros de ordenamiento en el futuro
              IconButton(onPressed: () {},
              icon: const Icon(Icons.sort)),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () { showDialog(
                  context: context,
                  builder: (context) => const AddProductDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Nuevo Producto"),
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
                        return ProductCard(
                          product: product,
                          onTap: () {
                            // TODO: Seleccionar producto para el Inspector
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}