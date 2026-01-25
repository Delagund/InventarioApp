class ProductFilter {
  final int? categoryId;
  final String? searchQuery;
  final bool orderByStockAsc; // Para el Sprint 3
  final bool orderByDateDesc; // Para el Sprint 3

  ProductFilter({
    this.categoryId,
    this.searchQuery,
    this.orderByStockAsc = false,
    this.orderByDateDesc = false,
  });

  ProductFilter copyWith({
    int? Function()? categoryId,
    String? Function()? searchQuery,
    bool? orderByStockAsc,
    bool? orderByDateDesc,
  }) {
    return ProductFilter(
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      orderByStockAsc: orderByStockAsc ?? this.orderByStockAsc,
      orderByDateDesc: orderByDateDesc ?? this.orderByDateDesc,
    );
  }

  // Método helper para saber si el filtro está vacío
  bool get isEmpty =>
      categoryId == null &&
      (searchQuery == null || searchQuery!.isEmpty) &&
      !orderByStockAsc &&
      !orderByDateDesc;
}
