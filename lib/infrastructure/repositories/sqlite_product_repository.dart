import '../../domain/models/product.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';



class SQLiteProductRepository implements IProductRepository {
  // Obtenemos la instancia del DatabaseHelper que creamos antes
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<Product>> getProducts({required ProductFilter filter}) async {
    final db = await _dbHelper.database;
    
    // 1. Construcción Dinámica del WHERE
    List<String> whereClauses = [];
    List<dynamic> args = [];

    // Si hay filtro de categoría, buscamos en la tabla intermedia 'product_categories'.
    // Usamos "id IN (...)" para obtener solo los productos que tengan esa relación.
    if (filter.categoryId != null) {
      whereClauses.add(
        'id IN (SELECT product_id FROM product_categories WHERE category_id = ?)'
      );
      args.add(filter.categoryId);
    }

    // Filtro por Texto (Nombre o SKU)
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      whereClauses.add('(name LIKE ? OR sku LIKE ?)');
      args.add('%${filter.searchQuery}%');
      args.add('%${filter.searchQuery}%');
    }

    // Unimos todas las condiciones con "AND"
    String? whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    // 2. Definir Ordenamiento (ORDER BY)
    // Preparamos la lógica para los botones de ordenamiento del Sprint 3
    String orderBy = 'name ASC'; // Default: Alfabético

    if (filter.orderByStockAsc) {
      orderBy = 'quantity ASC';
    } else if (filter.orderByDateDesc) {
      orderBy = 'created_at DESC'; // Más recientes primero
    }

    // 3. Ejecutar la Query Principal
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereString,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: orderBy,
    );

    // 4. Mapear a Objetos
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
      // Nota: Aquí el producto viene sin sus categorías cargadas (lazy loading).
      // Si necesitas mostrar las etiquetas en la Grid, necesitarías hacer un fetch extra
      // o un JOIN, pero para listados rápidos esto es lo más eficiente.
    });
  }
  
  
  /*
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

  */

  @override
  Future<void> saveProduct(Product product) async {
    final db = await _dbHelper.database;
    int productId;

    if (product.id != null) {
      // Si ya tiene ID, actualizamos el existente: UPDATE
      productId = product.id!;
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [productId],
      );
      // Limpiamos categorías anteriores para evitar duplicados o datos viejos
      await db.delete('product_categories', where: 'product_id = ?', whereArgs: [productId]);
    } else {
      // Si no tiene ID, es un producto nuevo: INSERT
      productId = await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // Guardar las relaciones en la tabla pivot
    if (product.categories != null) {
      for (final category in product.categories!) {
        if (category.id != null) {
          await addCategoryToProduct(productId, category.id!);
        }
      }
    }
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
}