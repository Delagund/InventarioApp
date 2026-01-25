import 'package:flutter/material.dart';
import '../../../domain/models/stock_transaction.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_layout.dart';

class MovementHistoryList extends StatelessWidget {
  final List<StockTransaction> history;

  const MovementHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.historialReciente,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppLayout.spaceM),

        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppLayout.spaceXL),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 40,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.noMovimientos,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length > 5 ? 5 : history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = history[index];
              final isPositive = tx.quantityDelta > 0;

              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(AppLayout.spaceS),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.add : Icons.remove,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  tx.reason,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(
                  "${isPositive ? '+' : ''}${tx.quantityDelta}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
