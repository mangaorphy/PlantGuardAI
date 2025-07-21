import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<ProductModel> _items = [];
  bool _isLoading = false;

  List<ProductModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  // Initialize with demo data
  void initializeWishlist() {
    _items.clear();
    _items.addAll([
      ProductModel(
        id: '1',
        name: 'Megha Star',
        price: 40000,
        rating: 4.0,
        orders: 32,
        image: 'assets/images/product_detail.png',
        description: 'Multiplex Megha Star for bacterial leaf diseases',
        isNew: false,
      ),
      ProductModel(
        id: '2',
        name: 'Plant Guard Pro',
        price: 35000,
        rating: 4.2,
        orders: 45,
        image: 'assets/images/product_listing.png',
        description: 'Advanced plant protection solution',
        isNew: true,
      ),
    ]);
    notifyListeners();
  }

  // Add item to wishlist
  Future<void> addToWishlist(ProductModel product) async {
    if (isInWishlist(product.id)) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _items.add(product);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      _items.removeWhere((item) => item.id == productId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Toggle wishlist status
  Future<void> toggleWishlist(ProductModel product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product.id);
    } else {
      await addToWishlist(product);
    }
  }

  // Clear all items
  Future<void> clearWishlist() async {
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

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  // Search in wishlist
  List<ProductModel> searchWishlist(String query) {
    if (query.isEmpty) return items;

    return _items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Sort wishlist
  void sortWishlist(String sortBy) {
    switch (sortBy) {
      case 'name':
        _items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
        _items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // Default sorting by date added (most recent first)
        break;
    }
    notifyListeners();
  }
}
