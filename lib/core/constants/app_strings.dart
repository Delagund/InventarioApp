class AppStrings {
  // General
  static const String appName = 'Inventario App';
  static const String todosLosProductos = 'Todos los productos';
  static const String categorias = 'CATEGORÍAS';
  static const String inventario = 'Inventario';

  // Categories
  static const String nuevaCategoria = 'Nueva Categoría';
  static const String nombreCategoria = 'Nombre';
  static const String crear = 'Crear';
  static const String cancelar = 'Cancelar';
  static const String eliminarCategoria = 'Eliminar categoría';
  static const String errorEliminarCategoria = 'Error al eliminar la categoría';
  static const String eliminarProductos = 'Eliminar productos';
  static String confirmarEliminarProductos(int count) =>
      '¿Estás seguro de que deseas eliminar $count productos? Esta acción no se puede deshacer.';
  static const String eliminar = 'Eliminar';
  static String productosEliminados(int count) => '$count productos eliminados';
  static const String cancelarSeleccion = 'Cancelar selección';
  static String productosSeleccionados(int count) => '$count seleccionados';
  static const String seleccionarProductos = 'Seleccionar productos';
  static const String noProductosEnCategoria =
      'No hay productos en esta categoría';

  // Products
  static const String nuevoProducto = 'Nuevo Producto';
  static const String guardarProducto = 'Guardar Producto';
  static const String nombreProducto = 'Nombre del Producto';
  static const String sku = 'SKU';
  static const String stockInicial = 'Stock Inicial';
  static const String stockFinal = 'Stock';
  static const String categoriasLabel = 'Categorías';

  // Inspector
  static const String controlStock = 'Control de Stock';
  static const String historialReciente = 'Historial Reciente';
  static const String noMovimientos = 'No hay movimientos registrados';
  static const String eliminarProducto = 'ELIMINAR PRODUCTO';
  static const String editarNombre = 'Editar Nombre';
  static const String guardar = 'Guardar';
  static const String imagenActualizada = 'Imagen actualizada';
  static const String seleccionarProducto = 'Selecciona un producto';

  // Errors
  static const String errorCargarProductos = 'Error al cargar productos';
  static const String errorEliminarProducto = 'Error al eliminar producto';
  static const String errorGuardarProducto = 'Error al guardar producto';
  static const String errorCargarCategorias = 'Error al cargar categorías';
  static const String errorRequerido = 'Requerido';
  static const String errorNumero = 'Debe ser número';
}
