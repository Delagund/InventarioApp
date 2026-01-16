import '../../domain/models/product.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../infrastructure/models/category_model.dart';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteProductRepository implements IProductRepository {
  // Obtenemos la instancia del DatabaseHelper que creamos antes
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    // Consultamos todos los registros de la tabla 'products'
    final List<Map<String, dynamic>> maps = await db.query('products');

   List<Product> products = [];
   for (var map in maps) {
     // Obtener categorías asociadas al producto
     final categories = await _getCategoriesForProduct(map['id']);
     products.add(Product.fromMap(map, categories: categories));
   }
   return products;
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    
    // Hacemos JOIN con la tabla intermedia 'product_categories'
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT p.*
      FROM products p
      INNER JOIN product_categories pc ON p.id = pc.product_id
      WHERE pc.category_id = ?
    ''', [categoryId]);

    return results.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Future<void> saveProduct(Product product) async {
    final db = await _dbHelper.database;

    if (product.id != null) {
      // Si ya tiene ID, actualizamos el existente: UPDATE
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      // Si no tiene ID, es un producto nuevo: INSERT
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    // Buscamos coincidencias en nombre o SKU usando el operador LIKE
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR sku LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // --- Métodos para la tabla pivot Producto-Categoría ---
  
  @override
  Future<void> addCategoryToProduct(int productId, int categoryId) async {
    final db = await _dbHelper.database;
    await db.insert('product_categories', {
      'product_id': productId,
      'category_id': categoryId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<void> removeCategoryFromProduct(int productId, int categoryId) async {
    final db = await _dbHelper.database;
    await db.delete('product_categories',
        where: 'product_id = ? AND category_id = ?',
        whereArgs: [productId, categoryId]);
  }

  // --- Métodos auxiliares privados ---

  // Este método hace la "magia" del JOIN para traer las categorías de un producto
  Future<List<Category>> _getCategoriesForProduct(int productId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.* FROM categories c
      INNER JOIN product_categories pc ON c.id = pc.category_id
      WHERE pc.product_id = ?
    ''', [productId]);

    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }
}