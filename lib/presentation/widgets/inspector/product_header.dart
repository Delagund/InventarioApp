import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/models/product.dart';
import '../../../core/constants/app_layout.dart';
import '../dialogs/edit_name_dialog.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../../infrastructure/services/image_picker_service.dart';

class ProductHeader extends StatelessWidget {
  final Product product;

  const ProductHeader({super.key, required this.product});

  void _onEditImage(BuildContext context) async {
    final newPath = await ImagePickerService.selectAndSaveImage();
    if (newPath != null && context.mounted) {
      await context.read<ProductViewModel>().updateProductDetails(
        imagePath: newPath,
      );
    }
  }

  void _showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => EditNameDialog(
        initialName: product.name,
        onSave: (newName) {
          context.read<ProductViewModel>().updateProductDetails(name: newName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Imagen del producto
        Center(
          child: Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppLayout.radiusL),
                  image: product.imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(product.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imagePath == null
                    ? Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton.filled(
                  onPressed: () => _onEditImage(context),
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppLayout.spaceL),

        // Nombre y SKU
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () => _showEditNameDialog(context),
              icon: const Icon(Icons.edit_outlined, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spaceXS),
        Text(
          "SKU: ${product.sku}",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 1.1,
          ),
        ),
        if (product.barcode != null && product.barcode!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "Barcode: ${product.barcode}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}
