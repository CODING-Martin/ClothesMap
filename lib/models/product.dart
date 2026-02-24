class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final bool isAvailable;
  final int stockCount;

  const ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.images = const [],
    required this.category,
    this.sizes = const [],
    this.colors = const [],
    this.isAvailable = true,
    this.stockCount = 0,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  double get discountPercent =>
      hasDiscount ? ((price - discountPrice!) / price * 100) : 0;

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? category,
    List<String>? sizes,
    List<String>? colors,
    bool? isAvailable,
    int? stockCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isAvailable: isAvailable ?? this.isAvailable,
      stockCount: stockCount ?? this.stockCount,
    );
  }
}
