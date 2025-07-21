class ProductModel {
  final String id;
  final String name;
  final double price;
  final double rating;
  final int orders;
  final String image;
  final String description;
  final bool isNew;
  final bool inStock;
  final String category;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.orders,
    required this.image,
    required this.description,
    this.isNew = false,
    this.inStock = true,
    this.category = 'General',
    this.tags = const [],
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? rating,
    int? orders,
    String? image,
    String? description,
    bool? isNew,
    bool? inStock,
    String? category,
    List<String>? tags,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      orders: orders ?? this.orders,
      image: image ?? this.image,
      description: description ?? this.description,
      isNew: isNew ?? this.isNew,
      inStock: inStock ?? this.inStock,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'orders': orders,
      'image': image,
      'description': description,
      'isNew': isNew,
      'inStock': inStock,
      'category': category,
      'tags': tags,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      rating: json['rating'].toDouble(),
      orders: json['orders'],
      image: json['image'],
      description: json['description'],
      isNew: json['isNew'] ?? false,
      inStock: json['inStock'] ?? true,
      category: json['category'] ?? 'General',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
