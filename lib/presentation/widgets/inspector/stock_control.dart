import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/stock_adjustment_reason.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_layout.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../inputs/stock_stepper.dart';

class StockControl extends StatefulWidget {
  final Product product;

  const StockControl({super.key, required this.product});

  @override
  State<StockControl> createState() => _StockControlState();
}

class _StockControlState extends State<StockControl> {
  late int _localStock;
  final _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localStock = widget.product.quantity;
    _qtyController.text = _localStock.toString();
  }

  @override
  void didUpdateWidget(StockControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id ||
        widget.product.quantity != oldWidget.product.quantity) {
      _localStock = widget.product.quantity;
      _qtyController.text = _localStock.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _updateStockValue(int newValue) {
    if (newValue < 0) return;
    setState(() {
      _localStock = newValue;
      _qtyController.text = newValue.toString();
    });
  }

  Future<void> _saveStock(BuildContext context) async {
    final delta = _localStock - widget.product.quantity;
    if (delta == 0) return;

    final vm = context.read<ProductViewModel>();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChanges = _localStock != widget.product.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.controlStock,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppLayout.spaceM),

        Container(
          padding: const EdgeInsets.all(AppLayout.spaceM),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppLayout.radiusM),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Stock actual", style: theme.textTheme.bodyMedium),
                  Text(
                    widget.product.quantity.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: AppLayout.spaceXL),
              StockStepper(
                currentStock: widget.product.quantity,
                controller: _qtyController,
                onUpdate: _updateStockValue,
                onSave: () => _saveStock(context),
                hasChanges: hasChanges,
                delta: _localStock - widget.product.quantity,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
