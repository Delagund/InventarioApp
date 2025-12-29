import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área de Imagen
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: product.imagePath != null && File(product.imagePath!).existsSync()
                    ? Image.file(
                        File(product.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
              ),
            ),
            // Área de Datos
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "SKU: ${product.sku}",
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Badge(
                        label: Text("${product.quantity} un."),
                        backgroundColor: product.quantity > 0 
                            ? theme.colorScheme.primaryContainer 
                            : theme.colorScheme.errorContainer,
                        textColor: product.quantity > 0 
                            ? theme.colorScheme.onPrimaryContainer 
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}