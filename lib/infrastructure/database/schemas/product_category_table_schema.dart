import 'package:sqflite/sqflite.dart';
import '../base_table_schema.dart';
import '../schema_constants.dart';

class ProductCategoryTableSchema implements TableSchema {
  @override
  Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${SchemaConstants.tableProductCategories} (
        ${SchemaConstants.columnPivotProductId} INTEGER,
        ${SchemaConstants.columnPivotCategoryId} INTEGER,
        FOREIGN KEY (${SchemaConstants.columnPivotProductId}) REFERENCES ${SchemaConstants.tableProducts} (${SchemaConstants.columnProductId}) ON DELETE CASCADE,
        FOREIGN KEY (${SchemaConstants.columnPivotCategoryId}) REFERENCES ${SchemaConstants.tableCategories} (${SchemaConstants.columnCategoryId}) ON DELETE CASCADE,
        PRIMARY KEY (${SchemaConstants.columnPivotProductId}, ${SchemaConstants.columnPivotCategoryId})
      )
    ''');
  }
}
