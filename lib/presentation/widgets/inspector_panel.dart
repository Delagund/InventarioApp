import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_adjustment_reason.dart';
import '../../presentation/viewmodels/product_viewmodel.dart';
import '../../infrastructure/services/image_picker_service.dart';
import 'dialogs/edit_name_dialog.dart';
import 'inputs/stock_stepper.dart';

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

  // Sincroniza el estado local si cambiamos de producto
  void _syncProduct(Product product) {
    if (_lastProductId != product.id) {
      _lastProductId = product.id;
      _localStock = product.quantity;
      _qtyController.text = _localStock.toString();
    }
  }

  // Actualiza el valor visual del stock (sin guardar aún)
  void _updateStockValue(int newValue) {
    if (newValue < 0) return;
    setState(() {
      _localStock = newValue;
      _qtyController.text = newValue.toString();
    });
  }

  // --- Acciones de Usuario ---
  // 1. Guardar stock
  Future<void> _saveStock(BuildContext context, Product product) async {
    FocusScope.of(context).unfocus(); // Cerramos teclado

    final vm = context.read<ProductViewModel>();

    // Calculamos el delta
    final delta = _localStock - product.quantity;

    // Llamamos al método con el delta y razón (por defecto Manual)
    final success = await vm.adjustStockFromInspector(
      delta,
      StockAdjustmentReason.manualAdjustment,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inventario actualizado correctamente")),
      );
    }
  }

  // 2. Editar Imagen (usa el servicio image_picker_service.dart)
  void _onEditImage(BuildContext context, Product product) async {
    // Llamada al servicio reutilizable (file_selector)
    final newPath = await ImagePickerService.selectAndSaveImage();

    if (newPath != null && context.mounted) {
      final productVM = context.read<ProductViewModel>();

      // No necesitamos crear un objeto Product aquí,
      // el ViewModel se encarga de aplicar el cambio al producto seleccionado.
      await productVM.updateProductDetails(imagePath: newPath);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Imagen actualizada")));
      }
    }
  }

  // 3. Editar Nombre
  void _showEditNameDialog(BuildContext context, Product product) {
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

  // 4. Eliminar Producto
  void _showDeleteConfirm(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar Producto?"),
        content: Text(
          "Estás a punto de eliminar '${product.name}'. Esta acción es irreversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ProductViewModel>().deleteProduct(product.id!);
              // Al eliminar, limpiamos la selección
              if (context.mounted) {
                context.read<ProductViewModel>().selectProduct(null);
              }
            },
            child: const Text("Eliminar"),
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

    // Caso sin selección
    if (product == null) {
      _lastProductId = null;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              "Selecciona un producto",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child:
                      product.imagePath != null &&
                          File(product.imagePath!).existsSync()
                      ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                      : Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton.small(
                    heroTag: "editImageBtn",
                    onPressed: () => _onEditImage(context, product),
                    tooltip: "Cambiar imagen",
                    child: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),

          // 2. Contenido Scrollable
          Expanded(
            flex: 5,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEditNameDialog(context, product),
                      tooltip: "Renombrar",
                    ),
                  ],
                ),
                Text(
                  "SKU: ${product.sku}",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 24),

                // --- STEPPER DE STOCK ---
                Text("Control de Stock", style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                StockStepper(
                  currentStock: product.quantity,
                  controller: _qtyController,
                  delta: _localStock - product.quantity,
                  hasChanges: hasChanges,
                  onUpdate: _updateStockValue,
                  onSave: () => _saveStock(context, product),
                ),

                // ------------------------
                const SizedBox(height: 24),
                // Chips de categorías (Visualización)
                if (product.categories != null &&
                    product.categories!.isNotEmpty) ...[
                  Text("Categorías", style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.categories!
                        .map(
                          (c) => Chip(
                            label: Text(c.name),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                const Divider(),

                // 3. Historial de Stock
                Text("Historial Reciente", style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),

                if (productVM.history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "No hay movimientos registrados",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap:
                        true, // Importante para estar dentro de otro Scroll
                    physics:
                        const NeverScrollableScrollPhysics(), // Evita conflicto de scroll
                    padding: EdgeInsets.zero,
                    itemCount: productVM.history.length,
                    itemBuilder: (context, index) {
                      final tx = productVM.history[index];
                      final isPos = tx.quantityDelta > 0;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        dense: true,
                        leading: Icon(
                          isPos
                              ? Icons.arrow_circle_up
                              : Icons.arrow_circle_down,
                          color: isPos ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        title: Text(
                          tx.reason,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          "${tx.date.day}/${tx.date.month}/${tx.date.year} ${tx.date.hour}:${tx.date.minute}",
                          // DateFormat('dd MMM HH:mm').format(tx.date) + (tx.userName != null ? " • ${tx.userName}" : ""),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          "${isPos ? '+' : ''}${tx.quantityDelta}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPos ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // 4. Botón Eliminar Producto
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _showDeleteConfirm(context, product),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("ELIMINAR PRODUCTO"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
