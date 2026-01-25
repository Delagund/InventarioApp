import '../../domain/models/product.dart' as domain;
import '../../domain/models/product_filter.dart' as domain;
import '../../domain/models/stock_transaction.dart' as domain;
import '../models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/models/stock_adjustment_reason.dart' as domain;
import '../../domain/models/category.dart' as domain;
import '../database/database_helper.dart';
import '../database/schema_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteProductRepository implements IProductRepository {
  // Obtenemos la instancia del DatabaseHelper que creamos antes
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<List<domain.Product>> getProducts({
    required domain.ProductFilter filter,
  }) async {
    final db = await _dbHelper.database;

    // 1. Construcción Dinámica del WHERE
    List<String> whereClauses = [];
    List<dynamic> args = [];

    // Si hay filtro de categoría, buscamos en la tabla intermedia 'product_categories'.
    if (filter.categoryId != null) {
      whereClauses.add(
        '${SchemaConstants.columnProductId} IN (SELECT ${SchemaConstants.columnPivotProductId} FROM ${SchemaConstants.tableProductCategories} WHERE ${SchemaConstants.columnPivotCategoryId} = ?)',
      );
      args.add(filter.categoryId);
    }

    // Filtro por Texto (Nombre o SKU)
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      whereClauses.add(
        '(${SchemaConstants.columnProductName} LIKE ? OR ${SchemaConstants.columnProductSku} LIKE ?)',
      );
      args.add('%${filter.searchQuery}%');
      args.add('%${filter.searchQuery}%');
    }

    // Unimos todas las condiciones con "AND"
    String? whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    // 2. Definir Ordenamiento (ORDER BY)
    String orderBy = 'name ASC'; // Default: Alfabético

    if (filter.orderByStockAsc) {
      orderBy = 'quantity ASC';
    } else if (filter.orderByDateDesc) {
      orderBy = 'created_at DESC';
    }

    // 3. Ejecutar la Query Principal
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        SchemaConstants.tableProducts,
        where: whereString,
        whereArgs: args.isNotEmpty ? args : null,
        orderBy: orderBy,
      );

      // 4. Obtener TODAS las categorías asociadas a estos productos para evitar N+1
      final List<Map<String, dynamic>> categoryMaps = await db.rawQuery('''
        SELECT pc.${SchemaConstants.columnPivotProductId}, c.*
        FROM ${SchemaConstants.tableProductCategories} pc
        JOIN ${SchemaConstants.tableCategories} c ON pc.${SchemaConstants.columnPivotCategoryId} = c.${SchemaConstants.columnCategoryId}
      ''');

      // Agrupamos categorías por ID de Producto
      Map<int, List<domain.Category>> productCategoriesMap = {};
      for (var row in categoryMaps) {
        int pid = row[SchemaConstants.columnPivotProductId];
        productCategoriesMap
            .putIfAbsent(pid, () => [])
            .add(
              domain.Category(
                id: row[SchemaConstants.columnCategoryId],
                name: row[SchemaConstants.columnCategoryName],
                description: row[SchemaConstants.columnCategoryDescription],
              ),
            );
      }

      // 5. Mapear a Objetos usando ProductModel e inyectar categorías
      return List.generate(maps.length, (i) {
        final model = ProductModel.fromMap(maps[i]);
        return model.toEntity(categories: productCategoriesMap[model.id] ?? []);
      });
    } catch (e) {
      throw AppDatabaseException("Error al consultar productos: $e");
    }
  }

  @override
  Future<void> saveProduct(domain.Product product) async {
    final db = await _dbHelper.database;
    int productId;

    try {
      if (product.id != null) {
        productId = product.id!;
        await db.update(
          SchemaConstants.tableProducts,
          ProductModel.fromEntity(product).toMap(),
          where: '${SchemaConstants.columnProductId} = ?',
          whereArgs: [productId],
        );
        await db.delete(
          SchemaConstants.tableProductCategories,
          where: '${SchemaConstants.columnPivotProductId} = ?',
          whereArgs: [productId],
        );
      } else {
        productId = await db.insert(
          SchemaConstants.tableProducts,
          ProductModel.fromEntity(product).toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      if (product.categories != null) {
        for (final category in product.categories!) {
          if (category.id != null) {
            await addCategoryToProduct(productId, category.id!);
          }
        }
      }
    } catch (e) {
      throw AppDatabaseException("Error al guardar producto: $e");
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    try {
      await db.delete(
        SchemaConstants.tableProducts,
        where: '${SchemaConstants.columnProductId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException("Error al eliminar producto: $e");
    }
  }

  @override
  Future<List<domain.Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        SchemaConstants.tableProducts,
        where:
            '${SchemaConstants.columnProductName} LIKE ? OR ${SchemaConstants.columnProductSku} LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromMap(maps[i]).toEntity();
      });
    } catch (e) {
      throw AppDatabaseException("Error al buscar productos: $e");
    }
  }

  @override
  Future<void> addCategoryToProduct(int productId, int categoryId) async {
    final db = await _dbHelper.database;
    try {
      await db.insert(
        SchemaConstants.tableProductCategories,
        {
          SchemaConstants.columnPivotProductId: productId,
          SchemaConstants.columnPivotCategoryId: categoryId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw AppDatabaseException("Error al añadir categoría al producto: $e");
    }
  }

  @override
  Future<void> removeCategoryFromProduct(int productId, int categoryId) async {
    final db = await _dbHelper.database;
    try {
      await db.delete(
        SchemaConstants.tableProductCategories,
        where:
            '${SchemaConstants.columnPivotProductId} = ? AND ${SchemaConstants.columnPivotCategoryId} = ?',
        whereArgs: [productId, categoryId],
      );
    } catch (e) {
      throw AppDatabaseException("Error al remover categoría del producto: $e");
    }
  }

  @override
  Future<void> updateStock(
    int productId,
    int quantityDelta,
    domain.StockAdjustmentReason reason, {
    String? user = "Local_user",
  }) async {
    final db = await _dbHelper.database;
    try {
      await db.transaction((txn) async {
        await txn.rawUpdate(
          'UPDATE ${SchemaConstants.tableProducts} SET ${SchemaConstants.columnProductQuantity} = ${SchemaConstants.columnProductQuantity} + ? WHERE ${SchemaConstants.columnProductId} = ?',
          [quantityDelta, productId],
        );

        await txn.insert(SchemaConstants.tableStockHistory, {
          SchemaConstants.columnHistoryProductId: productId,
          SchemaConstants.columnHistoryQuantityDelta: quantityDelta,
          SchemaConstants.columnHistoryReason: reason.toString(),
          SchemaConstants.columnHistoryUserName: user,
          SchemaConstants.columnHistoryDate: DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw AppDatabaseException("Error al actualizar stock: $e");
    }
  }

  @override
  Future<List<domain.StockTransaction>> getStockHistory(int productId) async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        SchemaConstants.tableStockHistory,
        where: '${SchemaConstants.columnHistoryProductId} = ?',
        whereArgs: [productId],
        orderBy: '${SchemaConstants.columnHistoryDate} DESC',
        limit: 5,
      );

      return List.generate(maps.length, (i) {
        return domain.StockTransaction(
          id: maps[i][SchemaConstants.columnHistoryId],
          productId: maps[i][SchemaConstants.columnHistoryProductId],
          quantityDelta: maps[i][SchemaConstants.columnHistoryQuantityDelta],
          reason: maps[i][SchemaConstants.columnHistoryReason],
          date: DateTime.parse(maps[i][SchemaConstants.columnHistoryDate]),
          userName: maps[i][SchemaConstants.columnHistoryUserName],
        );
      });
    } catch (e) {
      throw AppDatabaseException("Error al obtener historial de stock: $e");
    }
  }
}
