enum StockAdjustmentReason {
  manualAdjustment("Ajuste Manual"),
  initialStock("Stock Inicial"),
  restock("Reabastecimiento"),
  damaged("Dañado"),
  lost("Perdido"),
  correction("Corrección de error");

  final String label;
  const StockAdjustmentReason(this.label);

  @override
  String toString() => label;
}
