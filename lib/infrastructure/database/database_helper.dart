import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'schemas/product_table_schema.dart';
import 'schemas/category_table_schema.dart';
import 'schemas/product_category_table_schema.dart';
import 'schemas/stock_history_table_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Localiza la carpeta de documentos en macOS
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "inventory_master.db");

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Lista de esquemas a crear
    final schemas = [
      ProductTableSchema(),
      CategoryTableSchema(),
      ProductCategoryTableSchema(),
      StockHistoryTableSchema(),
    ];

    for (final schema in schemas) {
      await schema.create(db);
    }

    debugPrint("Tablas creadas exitosamente usando SRP con TableSchema.");
  }

  @visibleForTesting
  static void setDatabase(Database db) {
    _database = db;
  }
}
