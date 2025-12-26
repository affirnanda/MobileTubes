class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double pricePerDay;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pricePerDay,
    required this.stock,
    required this.isAvailable,
    required this.createdAt,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      pricePerDay: (map['price_per_day'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      isAvailable: map['is_available'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      imageUrl: map['image_url'],
    );
  }
}