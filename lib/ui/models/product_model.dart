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
  final String? videoUrl; // For tutorial videos

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
    this.videoUrl,
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
    String? videoUrl,
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
      videoUrl: videoUrl ?? this.videoUrl,
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
      'videoUrl': videoUrl,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle both proper product data and incorrectly formatted data
    // Skip records that look like plant disease diagnosis (they have plantName, diseaseName etc.)
    if (json.containsKey('plantName') || json.containsKey('diseaseName')) {
      // This looks like plant disease diagnosis data, skip it
      throw FormatException(
        'Not a product record - contains plant diagnosis fields',
      );
    }

    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      orders: json['orders'] ?? 0,
      image: json['image'] ?? json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      isNew: json['isNew'] ?? false,
      inStock: json['inStock'] ?? true,
      category: json['category'] ?? 'general',
      tags: List<String>.from(json['tags'] ?? []),
      videoUrl: json['videoUrl'],
    );
  }
}
