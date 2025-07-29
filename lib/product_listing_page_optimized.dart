import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import '/ui/models/product_model.dart';
import 'product_detail_page.dart';
import 'wishlist_page.dart';
import 'screens/profile/profile_page.dart';
import '/screens/home_page.dart';

class ProductListingPage extends StatefulWidget {
  final String? category; // 'pesticides', 'fertilizers', or null for all
  final String? searchQuery; // Initial search query

  const ProductListingPage({super.key, this.category, this.searchQuery});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedSort = 'Best Match';
  late TextEditingController _searchController;

  // Filter states
  final List<String> _selectedCategories = [];
  final double _minPrice = 0;
  final double _maxPrice = 200000;
  final double _minRating = 0;

  final List<String> _sortOptions = [
    'Best Match',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Newest First',
  ];

  // Translation helper
  String _getLocalizedText(String key, String language) {
    final translations = {
      'English': {
        'search_hint': 'Search products...',
        'filter': 'Filter',
        'filters': 'Filters',
        'all_products': 'All Products',
        'on_sale': 'On Sale',
        'new_arrivals': 'New Arrivals',
        'top_rated': 'Top Rated',
        'home': 'Home',
        'wishlist': 'Wishlist',
        'profile': 'Profile',
        'no_products': 'No products found',
        'try_different': 'Try a different search term',
      },
      'Kinyarwanda': {
        'search_hint': 'Shakisha ibicuruzwa...',
        'filter': 'Mushyushya',
        'filters': 'Amashyushya',
        'all_products': 'Ibicuruzwa Byose',
        'on_sale': 'Kugurisha',
        'new_arrivals': 'Bishya',
        'top_rated': 'Byiza cyane',
        'home': 'Urugo',
        'wishlist': 'Ibifuza',
        'profile': 'Umwirondoro',
        'no_products': 'Nta bicuruzwa bibonetse',
        'try_different': 'Gerageza ijambo ryindi',
      },
      'French': {
        'search_hint': 'Rechercher des produits...',
        'filter': 'Filtrer',
        'filters': 'Filtres',
        'all_products': 'Tous les Produits',
        'on_sale': 'En Vente',
        'new_arrivals': 'Nouveautés',
        'top_rated': 'Mieux Notés',
        'home': 'Accueil',
        'wishlist': 'Favoris',
        'profile': 'Profil',
        'no_products': 'Aucun produit trouvé',
        'try_different': 'Essayez un autre terme',
      },
      'Swahili': {
        'search_hint': 'Tafuta bidhaa...',
        'filter': 'Chuja',
        'filters': 'Vichujio',
        'all_products': 'Bidhaa Zote',
        'on_sale': 'Kwenye Uuzaji',
        'new_arrivals': 'Zilizofika Hivi Karibuni',
        'top_rated': 'Zilizo na Alama Juu',
        'home': 'Nyumbani',
        'wishlist': 'Orodha ya Matakwa',
        'profile': 'Maelezo',
        'no_products': 'Hakuna bidhaa zilizopatikana',
        'try_different': 'Jaribu neno lingine',
      },
    };
    return translations[language]?[key] ?? translations['English']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Set initial search query if provided
    if (widget.searchQuery != null) {
      _searchQuery = widget.searchQuery!;
      _searchController.text = _searchQuery;
    }
    // Leave search bar empty by default to show all products

    // Initialize providers and fetch products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Fetch products from Firestore
      productProvider.fetchProducts();

      // // Initialize other providers
      // if (wishlistProvider.isEmpty) {
      //   wishlistProvider.initializeWishlist();
      // }
      if (cartProvider.isEmpty) {
        cartProvider.initializeCart();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    List<ProductModel> products;

    // Get products based on category
    if (widget.category == 'pesticides') {
      products = productProvider.pesticides;
    } else if (widget.category == 'fertilizers') {
      products = productProvider.fertilizers;
    } else {
      // Show both pesticides and fertilizers for general browsing
      products = [
        ...productProvider.pesticides,
        ...productProvider.fertilizers,
      ];
    }

    // Apply search filter
    List<ProductModel> filtered = products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          product.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
    }).toList();

    // Apply category filters
    if (_selectedCategories.isNotEmpty &&
        !_selectedCategories.contains('All Products')) {
      filtered = filtered.where((product) {
        return _selectedCategories.any((category) {
          if (category == 'Pesticides') {
            return product.category.toLowerCase().contains('pesticide');
          } else if (category == 'Fertilizers') {
            return product.category.toLowerCase().contains('fertilizer');
          }
          return false;
        });
      }).toList();
    }

    // Apply price range filter
    filtered = filtered.where((product) {
      return product.price >= _minPrice && product.price <= _maxPrice;
    }).toList();

    // Apply rating filter
    filtered = filtered.where((product) {
      return product.rating >= _minRating;
    }).toList();

    // Apply sorting
    switch (_selectedSort) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating: High to Low':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest First':
        filtered.sort((a, b) => b.isNew ? 1 : (a.isNew ? -1 : 0));
        break;
      default: // Best Match
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Always black background like Figma
      appBar: AppBar(
        backgroundColor: Colors.black, // Always black background like Figma
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.white, // Always white text on black background
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white, // Always white on black background
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(themeProvider, userProvider),

          // Products List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductsList(themeProvider, currencyProvider),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(themeProvider, userProvider),
    );
  }

  Widget _buildSearchAndFilter(
    ThemeProvider themeProvider,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.black, // Always black background
      child: Column(
        children: [
          // Search Bar with Figma styling
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800], // Dark search bar
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Bacteria leaf streak',
                hintStyle: TextStyle(
                  color: Colors.grey[400], // Always light grey hint
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400], // Always light grey icon
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              style: const TextStyle(
                color: Colors.white, // Always white text
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sort and Filter Row with functional dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Functional Sort Dropdown
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.grey[900],
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sort by',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._sortOptions.map(
                            (option) => ListTile(
                              title: Text(
                                option,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: _selectedSort == option
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedSort = option;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSort,
                        style: const TextStyle(
                          color: Colors.white, // Always white text
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white, // Always white icon
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              // Filter Button
              GestureDetector(
                onTap: () {
                  final RenderBox button =
                      context.findRenderObject() as RenderBox;
                  final RenderBox overlay =
                      Navigator.of(context).overlay!.context.findRenderObject()
                          as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(
                        button.size.bottomRight(Offset.zero),
                        ancestor: overlay,
                      ),
                    ),
                    Offset.zero & overlay.size,
                  );

                  showMenu(
                    context: context,
                    position: position,
                    color: Colors.grey[900],
                    items: [
                      PopupMenuItem<String>(
                        value: 'All Products',
                        child: Row(
                          children: [
                            Icon(
                              _selectedCategories.contains('All Products') ||
                                      _selectedCategories.isEmpty
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color:
                                  _selectedCategories.contains(
                                        'All Products',
                                      ) ||
                                      _selectedCategories.isEmpty
                                  ? Colors.green
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'All Products',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Pesticides',
                        child: Row(
                          children: [
                            Icon(
                              _selectedCategories.contains('Pesticides')
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _selectedCategories.contains('Pesticides')
                                  ? Colors.green
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Pesticides',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Fertilizers',
                        child: Row(
                          children: [
                            Icon(
                              _selectedCategories.contains('Fertilizers')
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _selectedCategories.contains('Fertilizers')
                                  ? Colors.green
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Fertilizers',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategories.clear();
                        if (value != 'All Products') {
                          _selectedCategories.add(value);
                        }
                      });
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tune,
                        color: Colors.white, // Always white icon
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getLocalizedText(
                          'filter',
                          userProvider.currentLanguage,
                        ),
                        style: const TextStyle(
                          color: Colors.white, // Always white text
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(
    ThemeProvider themeProvider,
    CurrencyProvider currencyProvider,
  ) {
    final filtered = _filteredProducts;

    if (filtered.isEmpty) {
      return Container(
        color: Colors.black, // Always black background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[600], // Always grey on black
              ),
              const SizedBox(height: 16),
              Text(
                _getLocalizedText(
                  'no_products',
                  Provider.of<UserProvider>(context).currentLanguage,
                ),
                style: TextStyle(
                  color: Colors.grey[400], // Always grey on black
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getLocalizedText(
                  'try_different',
                  Provider.of<UserProvider>(context).currentLanguage,
                ),
                style: TextStyle(
                  color: Colors.grey[500], // Always grey on black
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Always use list view to match Figma design
    return Container(
      color: Colors.black, // Always black background
      child: _buildListView(filtered, themeProvider, currencyProvider),
    );
  }

  Widget _buildListView(
    List<ProductModel> products,
    ThemeProvider themeProvider,
    CurrencyProvider currencyProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ), // Minimal horizontal padding
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(
            bottom: 12,
          ), // Consistent spacing between items
          child: _buildProductListTile(
            products[index],
            themeProvider,
            currencyProvider,
          ),
        );
      },
    );
  }

  Widget _buildProductListTile(
    ProductModel product,
    ThemeProvider themeProvider,
    CurrencyProvider currencyProvider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        height: 140, // Increased height for better visibility
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // Minimal margin for full width
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900], // Always dark card on black background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[700]!, // Always dark border
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Product Image - Larger
            Container(
              width: 108, // Increased image size
              height: 108,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF87CEEB).withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.image.startsWith('http')
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            width: 108,
                            height: 108,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackImage(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                            width: 108,
                            height: 108,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackImage(),
                          ),
                  ),
                  // Disease badge
                  if (product.category.toLowerCase().contains('disease'))
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Disease',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 20), // Increased spacing
            // Product Info - Expanded to fill remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name - Larger text
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18, // Increased font size
                      color:
                          Colors.white, // Always white text on dark background
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Rating and Orders - Larger
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18, // Increased star size
                        );
                      }),
                      const SizedBox(width: 10), // Increased spacing
                      Text(
                        '${product.orders} orders',
                        style: TextStyle(
                          color: Colors
                              .grey[400], // Always grey on dark background
                          fontSize: 14, // Increased font size
                        ),
                      ),
                    ],
                  ),

                  // Price - Larger and more prominent
                  Text(
                    currencyProvider.formatPriceSync(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, // Increased font size
                      color:
                          Colors.white, // Always white text on dark background
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    ThemeProvider themeProvider,
    UserProvider userProvider,
  ) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[900], // Always dark background
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey[600], // Always grey for unselected
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: _getLocalizedText('home', userProvider.currentLanguage),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: _getLocalizedText('wishlist', userProvider.currentLanguage),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: _getLocalizedText('profile', userProvider.currentLanguage),
        ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.local_pharmacy, color: Colors.white, size: 40),
      ),
    );
  }
}
