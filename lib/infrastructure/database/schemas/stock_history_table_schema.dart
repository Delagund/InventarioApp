import 'package:sqflite/sqflite.dart';
import '../base_table_schema.dart';
import '../schema_constants.dart';

class StockHistoryTableSchema implements TableSchema {
  @override
  Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${SchemaConstants.tableStockHistory} (
        ${SchemaConstants.columnHistoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SchemaConstants.columnHistoryProductId} INTEGER NOT NULL,
        ${SchemaConstants.columnHistoryQuantityDelta} INTEGER NOT NULL,
        ${SchemaConstants.columnHistoryReason} TEXT,
        ${SchemaConstants.columnHistoryUserName} TEXT,
        ${SchemaConstants.columnHistoryDate} TEXT,
        FOREIGN KEY (${SchemaConstants.columnHistoryProductId}) REFERENCES ${SchemaConstants.tableProducts} (${SchemaConstants.columnProductId}) ON DELETE CASCADE
      )
    ''');
  }
}
