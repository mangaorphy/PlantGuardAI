import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/ui/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _pesticides = [];
  List<ProductModel> _fertilizers = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;

  List<ProductModel> get products => List.unmodifiable(_products);
  List<ProductModel> get pesticides => List.unmodifiable(_pesticides);
  List<ProductModel> get fertilizers => List.unmodifiable(_fertilizers);
  List<ProductModel> get featuredProducts => List.unmodifiable(_featuredProducts);
  List<ProductModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _searchDebounce;

  void searchProducts(String query) {
    // Cancel previous debounce timer if active
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    // Set up new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        final lowerCaseQuery = query.toLowerCase();
        _searchResults = _products.where((product) {
          return product.name.toLowerCase().contains(lowerCaseQuery) ||
                 product.description.toLowerCase().contains(lowerCaseQuery) ||
                 product.category.toLowerCase().contains(lowerCaseQuery) ||
                 product.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
        }).toList();
      }
      notifyListeners();
    });
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('products').get();
      
      _products = snapshot.docs.map((doc) {
        return ProductModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      _updateFilteredLists();
      
    } catch (e) {
      debugPrint('Error fetching products: $e');
      // Consider adding error state handling here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateFilteredLists() {
    _pesticides = _products.where((p) => p.category == 'pesticide').toList();
    _fertilizers = _products.where((p) => p.category == 'fertilizer').toList();
    _featuredProducts = _products.where((p) => p.isNew).toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}