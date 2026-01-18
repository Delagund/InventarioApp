import '../../domain/models/product.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/stock_transaction.dart';



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

  @override
  Future<void> updateStock(int productId, int quantityDelta, String reason, {String? user = "Local_user"}) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // 1. Actualizar el stock actual del producto
      // Usamos rawUpdate para sumar/restar directamente en SQL (más seguro ante concurrencia)
      await txn.rawUpdate(
        'UPDATE products SET quantity = quantity + ? WHERE id = ?',
        [quantityDelta, productId]
      );

      // 2. Insertar el registro histórico
      await txn.insert('stock_history', {
        'product_id': productId,
        'quantity_delta': quantityDelta,
        'reason': reason,
        'user_name': user,
        'date': DateTime.now().toIso8601String(),
      });
    });
  }

  // Obtener el historial de stock para un producto específico
  @override
  Future<List<StockTransaction>> getStockHistory(int productId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_history',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'date DESC', // Ordenar del más reciente al más antiguo
      limit: 5,             // LIMITACIÓN de los últimos 5 registros
    );

    return List.generate(maps.length, (i) {
      return StockTransaction(
        id: maps[i]['id'],
        productId: maps[i]['product_id'],
        quantityDelta: maps[i]['quantity_delta'],
        reason: maps[i]['reason'],
        date: DateTime.parse(maps[i]['date']),
        userName: maps[i]['user_name'],
      );
    });
  }
}