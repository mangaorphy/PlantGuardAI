import 'package:flutter/foundation.dart';
import '../ui/models/order_model.dart';
import '../ui/models/cart_item_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrderModel> _orders = [];
  bool _isLoading = false;

  OrderProvider() {
    // Remove any automatic demo data initialization
    // Users should only see real orders from their cart
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get pending payment orders (these come from cart items that were "ordered" but not paid)
  List<OrderModel> get pendingPaymentOrders {
    return _orders
        .where((order) => order.status == OrderStatus.pendingPayment)
        .toList();
  }

  // Get orders ready to ship (paid but not yet shipped)
  List<OrderModel> get toShipOrders {
    return _orders
        .where(
          (order) =>
              order.status == OrderStatus.paid ||
              order.status == OrderStatus.packing,
        )
        .toList();
  }

  // Get shipping orders (shipped but not delivered)
  List<OrderModel> get shippingOrders {
    return _orders
        .where(
          (order) =>
              order.status == OrderStatus.shipped ||
              order.status == OrderStatus.inTransit ||
              order.status == OrderStatus.outForDelivery,
        )
        .toList();
  }

  // Get delivered orders (ready for rating)
  List<OrderModel> get deliveredOrders {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .toList();
  }

  // Create order from cart items (when user proceeds to checkout but doesn't pay yet)
  Future<String> createOrderFromCart(
    List<CartItemModel> cartItems,
    String shippingAddress,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final orderItems = cartItems
          .map(
            (cartItem) => OrderItemModel(
              productId: cartItem.product.id,
              productName: cartItem.product.name,
              productImage: cartItem.product.image,
              category: cartItem.product.category,
              price: cartItem.product.price,
              quantity: cartItem.quantity,
              rating: cartItem.product.rating,
            ),
          )
          .toList();

      final totalAmount = cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = OrderModel(
        id: orderId,
        items: orderItems,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        status: OrderStatus.pendingPayment,
        shippingAddress: shippingAddress,
      );

      _orders.add(order);
      _isLoading = false;
      notifyListeners();

      return orderId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update order status after payment
  Future<void> markOrderAsPaid(String orderId, String paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(
          status: OrderStatus.paid,
          paymentId: paymentId,
          paidAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update order status to packing
  Future<void> markOrderAsPacking(String orderId) async {
    await _updateOrderStatus(orderId, OrderStatus.packing);
  }

  // Update order status to shipped
  Future<void> markOrderAsShipped(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(
          status: OrderStatus.shipped,
          shippedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update order status to delivered
  Future<void> markOrderAsDelivered(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(
          status: OrderStatus.delivered,
          deliveredAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Generic method to update order status
  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Clear all orders
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  // Initialize demo orders (remove this after testing)
  void initializeDemoOrders() {
    // Add a demo pending payment order to test the UI
    final demoOrder = OrderModel(
      id: 'DEMO_001',
      items: [
        OrderItemModel(
          productId: 'npk_001',
          productName: 'NPK Premium Fertilizer',
          productImage: 'assets/npk_fertilizer.png',
          category: 'fertilizer',
          price: 25.99,
          quantity: 2,
          rating: 4.5,
        ),
      ],
      totalAmount: 51.98,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.pendingPayment,
      shippingAddress: 'Demo Address',
    );

    _orders.add(demoOrder);
    notifyListeners();
  }

  // Remove demo orders
  void removeDemoOrders() {
    _orders.removeWhere((order) => order.id.startsWith('DEMO_'));
    notifyListeners();
  }
}
