import 'package:sqflite/sqflite.dart';
import '../base_table_schema.dart';
import '../schema_constants.dart';

class CategoryTableSchema implements TableSchema {
  @override
  Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE ${SchemaConstants.tableCategories} (
        ${SchemaConstants.columnCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SchemaConstants.columnCategoryName} TEXT UNIQUE NOT NULL,
        ${SchemaConstants.columnCategoryDescription} TEXT
      )
    ''');
  }
}
