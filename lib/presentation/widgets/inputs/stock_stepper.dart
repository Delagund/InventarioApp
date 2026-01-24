import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockStepper extends StatelessWidget {
  final int currentStock;
  final TextEditingController controller;
  final Function(int) onUpdate;
  final VoidCallback onSave;
  final bool hasChanges;
  final int delta;

  const StockStepper({
    super.key,
    required this.currentStock,
    required this.controller,
    required this.onUpdate,
    required this.onSave,
    this.hasChanges = false,
    this.delta = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: hasChanges
            ? Border.all(color: theme.colorScheme.primary)
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: () => onUpdate(int.tryParse(controller.text)! - 1),
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                  decoration: const InputDecoration(border: InputBorder.none),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    final n = int.tryParse(val);
                    if (n != null) onUpdate(n);
                  },
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => onUpdate(int.tryParse(controller.text)! + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (hasChanges) ...[
            const Divider(height: 24),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_alt),
              label: Text("Guardar cambio (${delta > 0 ? '+' : ''}$delta)"),
            ),
          ],
        ],
      ),
    );
  }
}
