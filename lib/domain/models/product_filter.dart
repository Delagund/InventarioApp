import 'product_sort.dart';

class ProductFilter {
  final int? categoryId;
  final String? searchQuery;
  final ProductSort sortBy;

  ProductFilter({
    this.categoryId,
    this.searchQuery,
    this.sortBy = ProductSort.nameAsc,
  });

  ProductFilter copyWith({
    int? Function()? categoryId,
    String? Function()? searchQuery,
    ProductSort? sortBy,
  }) {
    return ProductFilter(
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get isEmpty =>
      categoryId == null &&
      (searchQuery == null || searchQuery!.isEmpty) &&
      sortBy == ProductSort.nameAsc;
}
