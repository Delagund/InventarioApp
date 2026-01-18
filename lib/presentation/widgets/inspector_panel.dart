import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../domain/models/product.dart';

class InspectorPanel extends StatefulWidget {
  const InspectorPanel({super.key});

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  late TextEditingController _qtyController;
  int _localStock = 0;
  int? _lastProductId; // Para detectar cambio de selección

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // Actualiza el estado local si cambiamos de producto
  void _syncProduct(Product product) {
    if (_lastProductId != product.id) {
      _lastProductId = product.id;
      _localStock = product.quantity;
      _qtyController.text = _localStock.toString();
    }
  }

  void _updateStockValue(int newValue) {
    if (newValue < 0) return;
    setState(() {
      _localStock = newValue;
      _qtyController.text = newValue.toString();
    });
  }

  Future<void> _saveStock(BuildContext context, Product product) async {
    // Cerramos teclado
    FocusScope.of(context).unfocus();

    final vm = context.read<ProductViewModel>();
    
    // Llamamos al método del ViewModel que calcula el delta
    final success = await vm.adjustStockFromInspector(
      product.id!, 
      product.quantity, // Cantidad original (DB)
      _localStock       // Cantidad deseada (UI)
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inventario actualizado correctamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productVM = context.watch<ProductViewModel>();
    final product = productVM.selectedProduct;
    final theme = Theme.of(context);

    if (product == null) {
      _lastProductId = null; // Reset
      return Center(
        child: Text("Selecciona un producto", style: theme.textTheme.bodyLarge),
      );
    }

    // Sincronizamos solo si es necesario (durante el build para reactividad inmediata)
    if (_lastProductId != product.id) {
      _syncProduct(product);
    }

    // Detectamos si hay cambios pendientes
    final hasChanges = _localStock != product.quantity;

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Imagen y Header
          Expanded(
            flex: 2,
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: product.imagePath != null && File(product.imagePath!).existsSync()
                  ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                  : Icon(Icons.inventory, size: 64, color: theme.colorScheme.outline),
            ),
          ),

          // 2. Contenido Scrollable
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(product.name, style: theme.textTheme.headlineSmall),
                Text("SKU: ${product.sku}", style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                
                const SizedBox(height: 24),
                
                // --- STEPPER DE STOCK ---
                Text("Control de Stock", style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: hasChanges ? Border.all(color: theme.colorScheme.primary) : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => _updateStockValue(_localStock - 1),
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall,
                              decoration: const InputDecoration(border: InputBorder.none),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (val) {
                                final n = int.tryParse(val);
                                if (n != null) setState(() => _localStock = n);
                              },
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => _updateStockValue(_localStock + 1),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      if (hasChanges) ...[
                        const Divider(height: 24),
                        FilledButton.icon(
                          onPressed: () => _saveStock(context, product),
                          icon: const Icon(Icons.save_alt),
                          label: Text("Guardar cambio (${_localStock - product.quantity > 0 ? '+' : ''}${_localStock - product.quantity})"),
                        )
                      ]
                    ],
                  ),
                ),
                // ------------------------
                
                const SizedBox(height: 24),
                // Chips de categorías (Visualización)
                if (product.categories?.isNotEmpty ?? false)
                  Wrap(
                    spacing: 8,
                    children: product.categories!.map((c) => Chip(label: Text(c.name))).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}