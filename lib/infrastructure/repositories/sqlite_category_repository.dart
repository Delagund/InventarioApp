import '../../domain/models/category.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import '../../domain/repositories/i_category_repository.dart';
import 'package:sqflite/sqflite.dart';


/// Implementación del repositorio de categorías utilizando SQLite.
/// Sigue los principios de Clean Architecture al manejar la lógica de persistencia
/// y el mapeo de datos específicos de la infraestructura.
class SQLiteCategoryRepository implements CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Obtiene todas las categorías con un conteo dinámico de productos asociados.
  /// Utiliza un LEFT JOIN con la tabla pivot para garantizar eficiencia y veracidad.
  @override
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;

    // Consulta optimizada: une la tabla de categorías con la tabla pivot
    // y cuenta cuántos productos tiene cada una.
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        c.*, 
        COUNT(pc.product_id) as productCount
      FROM categories c
      LEFT JOIN product_categories pc ON c.id = pc.category_id
      GROUP BY c.id
    ''');

    // Mapeamos los resultados de la DB a objetos de dominio Category.
    // El factory .fromMap ahora procesa el campo calculado 'productCount'.
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Crea una nueva categoría en la base de datos.
  @override
  Future<void> createCategory(Category category) async {
    final db = await _dbHelper.database;
    
    // Creamos un CategoryModel a partir de la Category (entidad)
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
    );
    // El productCount no se guarda ya que es calculado.
    await db.insert(
      'categories',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Elimina una categoría por su ID.
  /// Gracias a ON DELETE CASCADE en la tabla pivot, se desvinculan los productos automáticamente.
  @override
  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Actualiza una categoría existente.
  Future<void> updateCategory(Category category) async {
    if (category.id == null) return;
    
    final db = await _dbHelper.database;

    final model = CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
    );
    
    await db.update(
      'categories',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
}