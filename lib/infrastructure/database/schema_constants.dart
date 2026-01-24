class SchemaConstants {
  // Table Names
  static const String tableProducts = 'products';
  static const String tableCategories = 'categories';
  static const String tableProductCategories = 'product_categories';
  static const String tableStockHistory = 'stock_history';

  // Products Columns
  static const String columnProductId = 'id';
  static const String columnProductSku = 'sku';
  static const String columnProductName = 'name';
  static const String columnProductBarcode = 'barcode';
  static const String columnProductQuantity = 'quantity';
  static const String columnProductDescription = 'description';
  static const String columnProductImagePath = 'image_path';
  static const String columnProductCreatedAt = 'created_at';

  // Categories Columns
  static const String columnCategoryId = 'id';
  static const String columnCategoryName = 'name';
  static const String columnCategoryDescription = 'description';

  // ProductCategories Columns
  static const String columnPivotProductId = 'product_id';
  static const String columnPivotCategoryId = 'category_id';

  // StockHistory Columns
  static const String columnHistoryId = 'id';
  static const String columnHistoryProductId = 'product_id';
  static const String columnHistoryQuantityDelta = 'quantity_delta';
  static const String columnHistoryReason = 'reason';
  static const String columnHistoryUserName = 'user_name';
  static const String columnHistoryDate = 'date';
}
