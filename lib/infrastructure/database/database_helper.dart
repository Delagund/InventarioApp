import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

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
    // 1. Tabla de Productos
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        barcode TEXT,
        quantity INTEGER DEFAULT 0 CHECK(quantity >= 0),
        description TEXT,
        image_path TEXT,
        created_at TEXT
      )
    ''');

    // 2. Tabla de Categorías (Espacios Lógicos)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT
      )
    ''');

    // 3. Tabla Pivot (Muchos a Muchos)
    await db.execute('''
      CREATE TABLE product_categories (
        product_id INTEGER,
        category_id INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        PRIMARY KEY (product_id, category_id)
      )
    ''');

    // 4. Tabla de Historial de Stock
    await db.execute('''
      CREATE TABLE stock_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity_delta INTEGER NOT NULL,
        reason TEXT,
        user_name TEXT,
        date TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
    
    debugPrint("Base de datos creada en $db"); // Log para confirmar la creación
  }

  @visibleForTesting
  static void setDatabase(Database db) {
    _database = db;
  }
}