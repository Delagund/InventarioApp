import '../../domain/models/category.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../database/schema_constants.dart';
import '../../core/exceptions/app_exceptions.dart';
import 'package:sqflite/sqflite.dart';

/// Implementación del repositorio de categorías utilizando SQLite.
/// Sigue los principios de Clean Architecture al manejar la lógica de persistencia
/// y el mapeo de datos específicos de la infraestructura.
class SQLiteCategoryRepository implements ICategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Obtiene todas las categorías con un conteo dinámico de productos asociados.
  /// Utiliza un LEFT JOIN con la tabla pivot para garantizar eficiencia y veracidad.
  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;

    try {
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT 
          c.*, 
          COUNT(pc.${SchemaConstants.columnPivotProductId}) as productCount
        FROM ${SchemaConstants.tableCategories} c
        LEFT JOIN ${SchemaConstants.tableProductCategories} pc ON c.${SchemaConstants.columnCategoryId} = pc.${SchemaConstants.columnPivotCategoryId}
        GROUP BY c.${SchemaConstants.columnCategoryId}
      ''');

      return results.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException("Error al obtener categorías: $e");
    }
  }

  /// Crea una nueva categoría en la base de datos.
  @override
  Future<void> createCategory(Category category) async {
    final db = await _dbHelper.database;

    try {
      // Creamos un CategoryModel a partir de la Category (entidad)
      final model = CategoryModel(
        id: category.id,
        name: category.name,
        description: category.description,
      );
      // El productCount no se guarda ya que es calculado.
      // El productCount no se guarda ya que es calculado.
      await db.insert(
        SchemaConstants.tableCategories,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppDatabaseException("Error al crear categoría: $e");
    }
  }

  /// Elimina una categoría por su ID.
  /// Gracias a ON DELETE CASCADE en la tabla pivot, se desvinculan los productos automáticamente.
  @override
  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    try {
      await db.delete(
        SchemaConstants.tableCategories,
        where: '${SchemaConstants.columnCategoryId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException("Error al eliminar categoría: $e");
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (category.id == null) return;

    final db = await _dbHelper.database;

    try {
      final model = CategoryModel(
        id: category.id,
        name: category.name,
        description: category.description,
      );

      await db.update(
        SchemaConstants.tableCategories,
        model.toMap(),
        where: '${SchemaConstants.columnCategoryId} = ?',
        whereArgs: [category.id],
      );
    } catch (e) {
      throw AppDatabaseException("Error al actualizar categoría: $e");
    }
  }
}
