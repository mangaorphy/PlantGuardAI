import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/ui/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _pesticides = [];
  List<ProductModel> _fertilizers = [];
  List<ProductModel> _plants = [];
  List<ProductModel> _tutorials = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;

  List<ProductModel> get products => List.unmodifiable(_products);
  List<ProductModel> get pesticides => List.unmodifiable(_pesticides);
  List<ProductModel> get fertilizers => List.unmodifiable(_fertilizers);
  List<ProductModel> get plants => List.unmodifiable(_plants);
  List<ProductModel> get tutorials => List.unmodifiable(_tutorials);
  List<ProductModel> get featuredProducts =>
      List.unmodifiable(_featuredProducts);
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
              product.tags.any(
                (tag) => tag.toLowerCase().contains(lowerCaseQuery),
              );
        }).toList();
      }
      notifyListeners();
    });
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Fetching products from Firestore...');

      // For now, fetch from the existing 'products' collection to avoid permission issues
      // Later you can update Firestore security rules to allow separate collections
      final snapshot = await _firestore.collection('products').get();

      if (snapshot.docs.isNotEmpty) {
        print(
          '✅ Found ${snapshot.docs.length} documents in products collection',
        );

        // First, clean any plant disease diagnosis data from products collection
        bool hasInvalidData = false;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data.containsKey('plantName') ||
              data.containsKey('diseaseName')) {
            hasInvalidData = true;
            print(
              '🗑️ Removing plant diagnosis data from products collection: ${doc.id}',
            );
            await doc.reference.delete();
          }
        }

        // If we cleaned invalid data, repopulate with proper products
        if (hasInvalidData) {
          print(
            '🏗️ Repopulating products collection with proper product data...',
          );
          await _populateProductsCollection();
          // Fetch again after repopulating
          await fetchProducts();
          return;
        }

        // For testing: Force repopulation if we don't have all categories
        if (snapshot.docs.length < 12) {
          print(
            '🔄 Insufficient product data, adding comprehensive sample data...',
          );
          await _populateProductsCollection();
          // Fetch again after populating
          await fetchProducts();
          return;
        }

        final List<ProductModel> fetchedProducts = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          print('🔍 Processing document ${doc.id}');

          try {
            // Ensure the document has an ID
            data['id'] = doc.id;

            final product = ProductModel.fromJson(data);
            fetchedProducts.add(product);
            print(
              '✅ Successfully parsed product: ${product.name} (${product.category})',
            );
          } catch (e) {
            print('⚠️ Skipping document ${doc.id}: $e');
            continue;
          }
        }

        // Organize products by category (handle both singular and plural forms)
        _products = fetchedProducts;
        _pesticides = fetchedProducts
            .where(
              (p) => p.category == 'pesticide' || p.category == 'pesticides',
            )
            .toList();
        _fertilizers = fetchedProducts
            .where(
              (p) => p.category == 'fertilizer' || p.category == 'fertilizers',
            )
            .toList();
        _plants = fetchedProducts
            .where((p) => p.category == 'plant' || p.category == 'plants')
            .toList();
        _tutorials = fetchedProducts
            .where((p) => p.category == 'tutorial' || p.category == 'tutorials')
            .toList();
        _featuredProducts = fetchedProducts.take(10).toList();

        print('📊 Products by category:');
        print('   Total: ${_products.length}');
        print('   Pesticides: ${_pesticides.length}');
        print('   Fertilizers: ${_fertilizers.length}');
        print('   Plants: ${_plants.length}');
        print('   Tutorials: ${_tutorials.length}');
        print('   Featured: ${_featuredProducts.length}');

        // If no valid products found, create sample data
        if (_products.isEmpty) {
          print(
            '⚠️ No valid products found, creating comprehensive sample data...',
          );
          await _populateProductsCollection();
          // Retry fetching after populating
          await fetchProducts();
          return;
        }
      } else {
        print(
          '📭 No documents found in products collection, creating sample data...',
        );
        await _populateProductsCollection();
        // Retry fetching after populating
        await fetchProducts();
        return;
      }
    } catch (e) {
      print('❌ Error fetching products from Firestore: $e');
      _createSampleProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _createSampleProducts() {
    final List<ProductModel> allProducts = [
      // Pesticides
      ProductModel(
        id: '1',
        name: 'Alpha Star',
        price: 12.99,
        rating: 4.5,
        orders: 120,
        image:
            'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Alpha+Star',
        description: 'Effective pest control solution for garden plants',
        isNew: true,
        category: 'pesticide',
        tags: ['pest-control', 'garden', 'plants'],
      ),
      ProductModel(
        id: '2',
        name: 'Garden Guard',
        price: 15.50,
        rating: 4.2,
        orders: 89,
        image:
            'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Garden+Guard',
        description: 'Multi-purpose pesticide for various plant diseases',
        category: 'pesticide',
        tags: ['multi-purpose', 'disease-control'],
      ),
      ProductModel(
        id: '3',
        name: 'Crop Shield',
        price: 18.75,
        rating: 4.7,
        orders: 156,
        image:
            'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Crop+Shield',
        description: 'Advanced protection for crop plants',
        category: 'pesticide',
        tags: ['crop-protection', 'advanced'],
      ),

      // Fertilizers
      ProductModel(
        id: '4',
        name: 'NPK Premium',
        price: 22.00,
        rating: 4.8,
        orders: 234,
        image:
            'https://via.placeholder.com/150x150/8BC34A/FFFFFF?text=NPK+Premium',
        description: 'Balanced NPK fertilizer for optimal plant growth',
        isNew: true,
        category: 'fertilizer',
        tags: ['npk', 'balanced', 'growth'],
      ),
      ProductModel(
        id: '5',
        name: 'Organic Boost',
        price: 19.99,
        rating: 4.6,
        orders: 178,
        image:
            'https://via.placeholder.com/150x150/795548/FFFFFF?text=Organic+Boost',
        description: 'Organic fertilizer for natural plant nutrition',
        category: 'fertilizer',
        tags: ['organic', 'natural', 'nutrition'],
      ),
      ProductModel(
        id: '6',
        name: 'Super Grow',
        price: 16.25,
        rating: 4.3,
        orders: 145,
        image:
            'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Super+Grow',
        description: 'Fast-acting fertilizer for quick results',
        category: 'fertilizer',
        tags: ['fast-acting', 'quick-results'],
      ),

      // Plants
      ProductModel(
        id: '7',
        name: 'Rose Plant',
        price: 25.00,
        rating: 4.9,
        orders: 89,
        image:
            'https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Rose+Plant',
        description: 'Beautiful flowering rose plant for your garden',
        isNew: true,
        category: 'plant',
        tags: ['flowering', 'garden', 'ornamental'],
      ),
      ProductModel(
        id: '8',
        name: 'Tomato Seedling',
        price: 8.50,
        rating: 4.4,
        orders: 203,
        image:
            'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Tomato+Plant',
        description: 'Fresh tomato seedlings ready for planting',
        category: 'plant',
        tags: ['vegetable', 'seedling', 'edible'],
      ),
      ProductModel(
        id: '9',
        name: 'Herb Collection',
        price: 18.00,
        rating: 4.6,
        orders: 156,
        image:
            'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Herb+Kit',
        description: 'Collection of popular cooking herbs',
        category: 'plant',
        tags: ['herbs', 'cooking', 'aromatic'],
      ),

      // Tutorials
      ProductModel(
        id: '10',
        name: 'Basic Gardening Guide',
        price: 9.99,
        rating: 4.7,
        orders: 312,
        image: 'https://img.youtube.com/vi/Yos7pVIZwl8/maxresdefault.jpg',
        description: 'Complete beginner guide to gardening',
        isNew: true,
        category: 'tutorial',
        tags: ['beginner', 'guide', 'education'],
        videoUrl: 'https://www.youtube.com/shorts/Yos7pVIZwl8',
      ),
      ProductModel(
        id: '11',
        name: 'Pest Control Mastery',
        price: 14.99,
        rating: 4.8,
        orders: 198,
        image: 'https://img.youtube.com/vi/Yos7pVIZwl8/maxresdefault.jpg',
        description: 'Advanced techniques for plant pest management',
        category: 'tutorial',
        tags: ['advanced', 'pest-control', 'management'],
        videoUrl: 'https://www.youtube.com/shorts/Yos7pVIZwl8',
      ),
      ProductModel(
        id: '12',
        name: 'Plant Disease Identification',
        price: 12.99,
        rating: 4.5,
        orders: 267,
        image: 'https://img.youtube.com/vi/Yos7pVIZwl8/maxresdefault.jpg',
        description: 'Learn to identify and treat common plant diseases',
        category: 'tutorial',
        tags: ['disease', 'identification', 'treatment'],
        videoUrl: 'https://www.youtube.com/shorts/Yos7pVIZwl8',
      ),
    ];

    // Set all product lists
    _products = allProducts;
    _pesticides = allProducts.where((p) => p.category == 'pesticide').toList();
    _fertilizers = allProducts
        .where((p) => p.category == 'fertilizer')
        .toList();
    _plants = allProducts.where((p) => p.category == 'plant').toList();
    _tutorials = allProducts.where((p) => p.category == 'tutorial').toList();
    _featuredProducts = allProducts.take(10).toList();

    notifyListeners();
  }

  // Method to populate Firestore with sample data (call this once to set up your database)
  Future<void> populateFirestoreWithSampleData() async {
    try {
      debugPrint('Checking if Firestore already has data...');

      // Check if products collection already has valid data
      final productsSnapshot = await _firestore
          .collection('products')
          .limit(1)
          .get();

      if (productsSnapshot.docs.isNotEmpty) {
        // Check if it contains valid product data (not plant diagnosis data)
        final firstDoc = productsSnapshot.docs.first.data();
        if (!firstDoc.containsKey('plantName') &&
            !firstDoc.containsKey('diseaseName')) {
          print('🔄 Firestore already has valid product data');
          return;
        }
      }

      await _populateProductsCollection();
    } catch (e) {
      debugPrint('Error checking/populating Firestore: $e');
    }
  }

  Future<void> _populateProductsCollection() async {
    try {
      debugPrint('🏗️ Populating products collection with sample data...');

      // Combined product data for all categories
      final allProducts = [
        // Pesticides
        {
          'name': 'Alpha Star',
          'price': 12.99,
          'rating': 4.5,
          'orders': 120,
          'image':
              'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Alpha+Star',
          'description': 'Effective pest control solution for garden plants',
          'isNew': true,
          'inStock': true,
          'category': 'pesticide',
          'tags': ['pest-control', 'garden', 'plants'],
        },
        {
          'name': 'Garden Guard',
          'price': 15.50,
          'rating': 4.2,
          'orders': 89,
          'image':
              'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Garden+Guard',
          'description': 'Multi-purpose pesticide for various plant diseases',
          'isNew': false,
          'inStock': true,
          'category': 'pesticide',
          'tags': ['multi-purpose', 'disease-control'],
        },
        {
          'name': 'Crop Shield',
          'price': 18.75,
          'rating': 4.7,
          'orders': 156,
          'image':
              'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Crop+Shield',
          'description': 'Advanced protection for crop plants',
          'isNew': false,
          'inStock': true,
          'category': 'pesticide',
          'tags': ['crop-protection', 'advanced'],
        },

        // Fertilizers
        {
          'name': 'NPK Premium',
          'price': 22.00,
          'rating': 4.8,
          'orders': 234,
          'image':
              'https://via.placeholder.com/150x150/8BC34A/FFFFFF?text=NPK+Premium',
          'description': 'Balanced NPK fertilizer for optimal plant growth',
          'isNew': true,
          'inStock': true,
          'category': 'fertilizer',
          'tags': ['npk', 'balanced', 'growth'],
        },
        {
          'name': 'Organic Boost',
          'price': 19.99,
          'rating': 4.6,
          'orders': 178,
          'image':
              'https://via.placeholder.com/150x150/795548/FFFFFF?text=Organic+Boost',
          'description': 'Organic fertilizer for natural plant nutrition',
          'isNew': false,
          'inStock': true,
          'category': 'fertilizer',
          'tags': ['organic', 'natural', 'nutrition'],
        },
        {
          'name': 'Super Grow',
          'price': 16.25,
          'rating': 4.3,
          'orders': 145,
          'image':
              'https://via.placeholder.com/150x150/607D8B/FFFFFF?text=Super+Grow',
          'description': 'Fast-acting fertilizer for quick results',
          'isNew': false,
          'inStock': true,
          'category': 'fertilizer',
          'tags': ['fast-acting', 'quick-results'],
        },

        // Plants
        {
          'name': 'Rose Plant',
          'price': 25.00,
          'rating': 4.9,
          'orders': 89,
          'image':
              'https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Rose+Plant',
          'description': 'Beautiful flowering rose plant for your garden',
          'isNew': true,
          'inStock': true,
          'category': 'plant',
          'tags': ['flowering', 'garden', 'ornamental'],
        },
        {
          'name': 'Tomato Seedling',
          'price': 8.50,
          'rating': 4.4,
          'orders': 203,
          'image':
              'https://via.placeholder.com/150x150/FF5722/FFFFFF?text=Tomato+Plant',
          'description': 'Fresh tomato seedlings ready for planting',
          'isNew': false,
          'inStock': true,
          'category': 'plant',
          'tags': ['vegetable', 'seedling', 'edible'],
        },
        {
          'name': 'Herb Collection',
          'price': 18.00,
          'rating': 4.6,
          'orders': 156,
          'image':
              'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Herb+Kit',
          'description': 'Collection of popular cooking herbs',
          'isNew': false,
          'inStock': true,
          'category': 'plant',
          'tags': ['herbs', 'cooking', 'aromatic'],
        },

        // Tutorials
        {
          'name': 'Basic Gardening Guide',
          'price': 9.99,
          'rating': 4.7,
          'orders': 312,
          'image':
              'https://via.placeholder.com/150x150/9C27B0/FFFFFF?text=Garden+Guide',
          'description': 'Complete beginner guide to gardening',
          'isNew': true,
          'inStock': true,
          'category': 'tutorial',
          'tags': ['beginner', 'guide', 'education'],
        },
        {
          'name': 'Pest Control Mastery',
          'price': 14.99,
          'rating': 4.8,
          'orders': 198,
          'image':
              'https://via.placeholder.com/150x150/FF9800/FFFFFF?text=Pest+Control',
          'description': 'Advanced techniques for plant pest management',
          'isNew': false,
          'inStock': true,
          'category': 'tutorial',
          'tags': ['advanced', 'pest-control', 'management'],
        },
        {
          'name': 'Plant Disease Identification',
          'price': 12.99,
          'rating': 4.5,
          'orders': 267,
          'image':
              'https://via.placeholder.com/150x150/F44336/FFFFFF?text=Disease+ID',
          'description': 'Learn to identify and treat common plant diseases',
          'isNew': false,
          'inStock': true,
          'category': 'tutorial',
          'tags': ['disease', 'identification', 'treatment'],
        },
      ];

      // Add data to the products collection
      for (final productData in allProducts) {
        await _firestore.collection('products').add(productData);
      }

      debugPrint(
        '✅ Successfully populated products collection with ${allProducts.length} products',
      );
    } catch (e) {
      debugPrint('❌ Error populating products collection: $e');
    }
  }

  Future<void> forceUpdateFirestoreWithYouTubeData() async {
    try {
      debugPrint('🔄 Force updating Firestore with YouTube tutorial data...');

      // Clear existing tutorial products
      final tutorialQuery = await _firestore
          .collection('products')
          .where('category', isEqualTo: 'tutorial')
          .get();

      for (var doc in tutorialQuery.docs) {
        await doc.reference.delete();
      }

      // Create sample products to get the updated tutorial data
      _createSampleProducts();

      // Get tutorial products from local data
      final tutorialProducts = _tutorials;

      // Add updated tutorial products with YouTube URLs
      for (var product in tutorialProducts) {
        await _firestore.collection('products').add(product.toJson());
      }

      debugPrint('✅ Successfully updated Firestore with YouTube tutorial data');

      // Refresh the local data
      await fetchProducts();
    } catch (e) {
      debugPrint('❌ Error updating Firestore with YouTube data: $e');
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
