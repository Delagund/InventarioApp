import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../domain/models/product.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos (watch) al ViewModel para redibujar cuando cambie la selección
    final productVM = context.watch<ProductViewModel>();
    final product = productVM.selectedProduct;
    final theme = Theme.of(context);

    // ESTADO 1: No hay selección
    if (product == null) {
      return Container(
        color: theme.colorScheme.surfaceContainerLow,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                "Selecciona un producto\npara ver detalles",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ESTADO 2: Producto seleccionado
    return Container(
      color: theme.colorScheme.surface, // Fondo blanco/oscuro según tema
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A. Imagen Grande
          Expanded(
            flex: 2,
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: product.imagePath != null && File(product.imagePath!).existsSync()
                  ? Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
            ),
          ),

          // B. Información y Controles
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y SKU
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "SKU: ${product.sku}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Categorías
                  Text("Categorías", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (product.categories != null && product.categories!.isNotEmpty)
                        ? product.categories!.map((cat) {
                            return Chip(
                              label: Text(cat.name),
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                            );
                          }).toList()
                        : [
                            Chip(
                              label: const Text("Sin categoría"),
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            )
                          ],
                  ),

                  const SizedBox(height: 24),

                  // Control de Stock (Preliminar)
                  Text("Control de Stock", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {
                            // TODO: Implementar lógica de resta
                            debugPrint("Disminuir stock");
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          "${product.quantity}",
                          style: theme.textTheme.displaySmall,
                        ),
                        IconButton.filled(
                          onPressed: () {
                             // TODO: Implementar lógica de suma
                             debugPrint("Aumentar stock");
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  
                  if (product.description != null && product.description!.isNotEmpty) ...[
                     const SizedBox(height: 24),
                     Text("Descripción", style: theme.textTheme.labelLarge),
                     const SizedBox(height: 8),
                     Text(product.description!, style: theme.textTheme.bodyMedium),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}