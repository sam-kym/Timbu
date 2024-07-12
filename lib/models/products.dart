class Product {
  final String name;
  final String description;
  final List<String> productImageIds;

  Product({
    required this.name,
    required this.description,
    required this.productImageIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      productImageIds: List<String>.from(json['product_image'] ?? []),
    );
  }
}