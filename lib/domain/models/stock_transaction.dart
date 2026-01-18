class StockTransaction {
  final int? id;
  final int productId;
  final int quantityDelta; // Puede ser positivo (+5) o negativo (-2)
  final String reason;     // Ej: "Compra", "Venta", "Ajuste", "Merma"
  final DateTime date;

  StockTransaction({
    this.id,
    required this.productId,
    required this.quantityDelta,
    required this.reason,
    required this.date,
  });
}