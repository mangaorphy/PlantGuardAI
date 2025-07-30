class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? paymentId;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.paymentId,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    required this.shippingAddress,
  });

  OrderModel copyWith({
    String? id,
    List<OrderItemModel>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? paymentId,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? shippingAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final String category;
  final double price;
  final int quantity;
  final double rating;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.category,
    required this.price,
    required this.quantity,
    required this.rating,
  });

  double get totalPrice => price * quantity;

  OrderItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    String? category,
    double? price,
    int? quantity,
    double? rating,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      rating: rating ?? this.rating,
    );
  }
}

enum OrderStatus {
  pendingPayment,
  paid,
  packing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'Payment Due';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.packing:
        return 'Packing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'Waiting for payment to complete';
      case OrderStatus.paid:
        return 'Payment received, preparing for shipment';
      case OrderStatus.packing:
        return 'Your order is being packed';
      case OrderStatus.shipped:
        return 'Your order has been shipped';
      case OrderStatus.inTransit:
        return 'Your package is on the way';
      case OrderStatus.outForDelivery:
        return 'Your package is out for delivery';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
      case OrderStatus.refunded:
        return 'Order has been refunded';
    }
  }
}
