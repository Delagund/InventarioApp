import 'package:sqflite/sqflite.dart';
import '../base_table_schema.dart';
import '../schema_constants.dart';

class ProductTableSchema implements TableSchema {
  @override
  Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${SchemaConstants.tableProducts} (
        ${SchemaConstants.columnProductId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SchemaConstants.columnProductSku} TEXT UNIQUE NOT NULL,
        ${SchemaConstants.columnProductName} TEXT NOT NULL,
        ${SchemaConstants.columnProductBarcode} TEXT,
        ${SchemaConstants.columnProductQuantity} INTEGER DEFAULT 0 CHECK(${SchemaConstants.columnProductQuantity} >= 0),
        ${SchemaConstants.columnProductDescription} TEXT,
        ${SchemaConstants.columnProductImagePath} TEXT,
        ${SchemaConstants.columnProductCreatedAt} TEXT
      )
    ''');
  }
}
