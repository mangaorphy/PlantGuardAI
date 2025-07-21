import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  // Calculate totals
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get shipping => subtotal > 100000 ? 0 : 5000;
  double get tax => subtotal * 0.18; // 18% VAT
  double get total => subtotal + shipping + tax;

  // Initialize with demo data
  void initializeCart() {
    final demoProducts = [
      ProductModel(
        id: '1',
        name: 'Megha Star',
        price: 40000,
        rating: 4.0,
        orders: 32,
        image: 'assets/images/product_listing.png',
        description: 'Multiplex Megha Star for bacterial leaf diseases',
        inStock: true,
      ),
      ProductModel(
        id: '2',
        name: 'Plant Guard Pro',
        price: 35000,
        rating: 4.2,
        orders: 45,
        image: 'assets/images/product_detail.png',
        description: 'Advanced plant protection solution',
        inStock: true,
      ),
      ProductModel(
        id: '3',
        name: 'Leaf Protection Plus',
        price: 42000,
        rating: 3.8,
        orders: 28,
        image: 'assets/images/Rectangle 42.png',
        description: 'Premium leaf protection formula',
        inStock: false,
      ),
    ];

    _items.clear();
    _items.addAll([
      CartItemModel(
        id: '1',
        product: demoProducts[0],
        quantity: 2,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CartItemModel(
        id: '2',
        product: demoProducts[1],
        quantity: 1,
        addedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      CartItemModel(
        id: '3',
        product: demoProducts[2],
        quantity: 3,
        addedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
    notifyListeners();
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // Update quantity if item exists
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item
        final newItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        _items.add(newItem);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final index = _items.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      _items.removeWhere((item) => item.id == itemId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear all items
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _items.clear();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get item quantity in cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse:
          () => CartItemModel(
            id: '',
            product: ProductModel(
              id: '',
              name: '',
              price: 0,
              rating: 0,
              orders: 0,
              image: '',
              description: '',
            ),
            quantity: 0,
            addedAt: DateTime.now(),
          ),
    );
    return item.quantity;
  }

  // Check if there are out of stock items
  bool get hasOutOfStockItems {
    return _items.any((item) => !item.product.inStock);
  }

  // Get only in-stock items
  List<CartItemModel> get inStockItems {
    return _items.where((item) => item.product.inStock).toList();
  }
}
