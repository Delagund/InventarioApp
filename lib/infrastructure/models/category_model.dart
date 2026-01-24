import '../../domain/models/category.dart';
import '../database/schema_constants.dart';

class CategoryModel extends Category {
  CategoryModel({
    super.id,
    required super.name,
    super.description,
    super.productCount,
  });

  // Mapeo desde la base de datos
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[SchemaConstants.columnCategoryId] as int?,
      name: map[SchemaConstants.columnCategoryName] as String,
      description: map[SchemaConstants.columnCategoryDescription] as String?,
      // Aquí capturamos el conteo que vendrá del SQL JOIN
      productCount: map['productCount'] != null
          ? map['productCount'] as int
          : 0,
    );
  }

  // Prepara los datos para INSERT/UPDATE (solo campos físicos de la tabla)
  Map<String, dynamic> toMap() {
    return {
      SchemaConstants.columnCategoryId: id,
      SchemaConstants.columnCategoryName: name,
      SchemaConstants.columnCategoryDescription: description,
    };
  }
}
