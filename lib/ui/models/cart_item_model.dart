import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}
