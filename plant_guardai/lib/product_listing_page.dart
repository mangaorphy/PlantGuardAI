import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'models/product_model.dart';
import 'product_detail_page.dart';
import 'wishlist_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/home/home_page.dart';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  int _currentIndex = 0;
  bool _isGridView = true;
  String _searchQuery = '';
  String _selectedSort = 'Best Match';
  bool _showFilters = false;
  TextEditingController _searchController = TextEditingController();

  final List<String> _sortOptions = [
    'Best Match',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Newest First',
  ];

  // Language translation helper
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
        'grid_enabled': 'Grid view enabled',
        'list_enabled': 'List view enabled',
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
        'grid_enabled': 'Icyerekezo cya kashe kirakoreshwa',
        'list_enabled': 'Icyerekezo cya liste kirakoreshwa',
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
        'grid_enabled': 'Vue grille activée',
        'list_enabled': 'Vue liste activée',
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
        'grid_enabled': 'Mwongozo wa gridi umewashwa',
        'list_enabled': 'Mwongozo wa orodha umewashwa',
      },
    };

    return translations[language]?[key] ?? translations['English']![key]!;
  }

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Megha Star',
      'price': 40000,
      'rating': 4.0,
      'orders': 32,
      'image': 'assets/images/product_listing.png',
      'isNew': false,
    },
    {
      'name': 'Plant Guard Pro',
      'price': 35000,
      'rating': 4.2,
      'orders': 45,
      'image': 'assets/images/product_listing.png',
      'isNew': true,
    },
    {
      'name': 'Leaf Protection Plus',
      'price': 42000,
      'rating': 3.8,
      'orders': 28,
      'image': 'assets/images/product_listing.png',
      'isNew': false,
    },
    {
      'name': 'Bacterial Defense',
      'price': 38000,
      'rating': 4.1,
      'orders': 56,
      'image': 'assets/images/product_listing.png',
      'isNew': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Bacteria leaf streak';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (wishlistProvider.isEmpty) {
        wishlistProvider.initializeWishlist();
      }
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

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered =
        _products.where((product) {
          return product['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        }).toList();

    // Sort products
    switch (_selectedSort) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Rating: High to Low':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Newest First':
        filtered.sort((a, b) => b['isNew'] ? 1 : -1);
        break;
      default: // Best Match
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeProvider.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.textColor,
                size: _getResponsiveSize(context, 24),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Container(
              height: _getResponsiveSize(context, 40),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  _performSearch();
                },
                decoration: InputDecoration(
                  hintText: _getLocalizedText(
                    'search_hint',
                    userProvider.currentLanguage,
                  ),
                  hintStyle: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: _getResponsiveSize(context, 16),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: themeProvider.secondaryTextColor,
                    size: _getResponsiveSize(context, 20),
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: themeProvider.secondaryTextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSize(context, 16),
                    vertical: _getResponsiveSize(context, 8),
                  ),
                ),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: _getResponsiveSize(context, 16),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: themeProvider.textColor,
                  size: _getResponsiveSize(context, 24),
                ),
                onPressed: _showOptionsMenu,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Filter controls
                Container(
                  padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _showSortOptions,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getResponsiveSize(context, 12),
                            vertical: _getResponsiveSize(context, 8),
                          ),
                          decoration: BoxDecoration(
                            color: themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedSort,
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                  fontSize: _getResponsiveSize(context, 14),
                                ),
                              ),
                              SizedBox(width: _getResponsiveSize(context, 8)),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: themeProvider.textColor,
                                size: _getResponsiveSize(context, 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isGridView ? Icons.grid_view : Icons.list,
                          color: themeProvider.textColor,
                          size: _getResponsiveSize(context, 24),
                        ),
                        onPressed: () {
                          setState(() {
                            _isGridView = !_isGridView;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isGridView
                                    ? _getLocalizedText(
                                      'grid_enabled',
                                      userProvider.currentLanguage,
                                    )
                                    : _getLocalizedText(
                                      'list_enabled',
                                      userProvider.currentLanguage,
                                    ),
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: _getResponsiveSize(context, 8)),
                      GestureDetector(
                        onTap: _toggleFilters,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getResponsiveSize(context, 12),
                            vertical: _getResponsiveSize(context, 8),
                          ),
                          decoration: BoxDecoration(
                            color:
                                _showFilters
                                    ? Colors.green
                                    : themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list,
                                color:
                                    _showFilters
                                        ? Colors.white
                                        : themeProvider.textColor,
                                size: _getResponsiveSize(context, 16),
                              ),
                              SizedBox(width: _getResponsiveSize(context, 4)),
                              Text(
                                _getLocalizedText(
                                  'filter',
                                  userProvider.currentLanguage,
                                ),
                                style: TextStyle(
                                  color:
                                      _showFilters
                                          ? Colors.white
                                          : themeProvider.textColor,
                                  fontSize: _getResponsiveSize(context, 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Filters panel (conditionally shown)
                if (_showFilters) _buildFiltersPanel(userProvider),
                // Product grid/list
                Expanded(
                  child:
                      _filteredProducts.isEmpty
                          ? _buildEmptyState(themeProvider, userProvider)
                          : _isGridView
                          ? _buildGridView()
                          : _buildListView(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: themeProvider.backgroundColor,
            selectedItemColor: themeProvider.textColor,
            unselectedItemColor: themeProvider.secondaryTextColor,
            currentIndex: _currentIndex,
            selectedLabelStyle: TextStyle(
              fontSize: _getResponsiveSize(context, 12),
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: _getResponsiveSize(context, 12),
            ),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _handleBottomNavigation(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: _getResponsiveSize(context, 24)),
                label: _getLocalizedText('home', userProvider.currentLanguage),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border,
                  size: _getResponsiveSize(context, 24),
                ),
                label: _getLocalizedText(
                  'wishlist',
                  userProvider.currentLanguage,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                  size: _getResponsiveSize(context, 24),
                ),
                label: _getLocalizedText(
                  'profile',
                  userProvider.currentLanguage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersPanel(UserProvider userProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
          margin: EdgeInsets.symmetric(
            horizontal: _getResponsiveSize(context, 16),
          ),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getLocalizedText('filters', userProvider.currentLanguage),
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: _getResponsiveSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _getResponsiveSize(context, 12)),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    _getLocalizedText(
                      'all_products',
                      userProvider.currentLanguage,
                    ),
                    true,
                    themeProvider,
                    userProvider,
                  ),
                  _buildFilterChip(
                    _getLocalizedText('on_sale', userProvider.currentLanguage),
                    false,
                    themeProvider,
                    userProvider,
                  ),
                  _buildFilterChip(
                    _getLocalizedText(
                      'new_arrivals',
                      userProvider.currentLanguage,
                    ),
                    false,
                    themeProvider,
                    userProvider,
                  ),
                  _buildFilterChip(
                    _getLocalizedText(
                      'top_rated',
                      userProvider.currentLanguage,
                    ),
                    false,
                    themeProvider,
                    userProvider,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    ThemeProvider themeProvider,
    UserProvider userProvider,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : themeProvider.secondaryTextColor,
          fontSize: _getResponsiveSize(context, 12),
        ),
      ),
      selected: isSelected,
      onSelected: (bool value) {
        // Implement filter logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label filter ${value ? 'applied' : 'removed'}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      backgroundColor: themeProvider.cardColor,
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildEmptyState(
    ThemeProvider themeProvider,
    UserProvider userProvider,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: _getResponsiveSize(context, 64),
            color: themeProvider.secondaryTextColor,
          ),
          SizedBox(height: _getResponsiveSize(context, 16)),
          Text(
            _getLocalizedText('no_products', userProvider.currentLanguage),
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: _getResponsiveSize(context, 18),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: _getResponsiveSize(context, 8)),
          Text(
            _getLocalizedText('try_different', userProvider.currentLanguage),
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: _getResponsiveSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: _getChildAspectRatio(context),
        mainAxisSpacing: _getResponsiveSize(context, 16),
        crossAxisSpacing: _getResponsiveSize(context, 16),
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, _filteredProducts[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: _getResponsiveSize(context, 16)),
          child: _buildProductCard(context, _filteredProducts[index]),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardHeight = _getResponsiveSize(context, 120);
    final imageSize = _getResponsiveSize(context, 120);

    // Convert Map to ProductModel for provider compatibility
    final productModel = ProductModel(
      id: product['id'] ?? product['name'].hashCode.toString(),
      name: product['name'],
      price: product['price'].toDouble(),
      rating: product['rating'].toDouble(),
      orders: product['orders'],
      image: product['image'],
      description: product['description'] ?? '',
      isNew: product['isNew'] ?? false,
    );

    return Consumer2<WishlistProvider, CartProvider>(
      builder: (context, wishlistProvider, cartProvider, child) {
        final isInWishlist = wishlistProvider.isInWishlist(productModel.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: productModel),
              ),
            );
          },
          child: Container(
            height: _getResponsiveSize(
              context,
              100,
            ), // Fixed height to prevent overflow
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Product image
                Container(
                  width: _getResponsiveSize(context, 90),
                  height: _getResponsiveSize(context, 90),
                  margin: EdgeInsets.all(_getResponsiveSize(context, 5)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackProductImage(context, product);
                      },
                    ),
                  ),
                ),
                // Product details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: _getResponsiveSize(context, 5),
                      horizontal: _getResponsiveSize(context, 5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name and NEW badge
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _getResponsiveSize(context, 11),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product['isNew'])
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _getResponsiveSize(context, 3),
                                    vertical: _getResponsiveSize(context, 1),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: _getResponsiveSize(context, 6),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Price
                        Expanded(
                          flex: 1,
                          child: Consumer<CurrencyProvider>(
                            builder: (context, currencyProvider, child) {
                              return Text(
                                currencyProvider.formatPriceSync(
                                  product['price'].toDouble(),
                                ),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: _getResponsiveSize(context, 12),
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),

                        // Rating
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < product['rating'].floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: _getResponsiveSize(context, 9),
                                  );
                                }),
                              ),
                              SizedBox(width: _getResponsiveSize(context, 3)),
                              Text(
                                '${product['rating']}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: _getResponsiveSize(context, 8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      () => _addToCart(
                                        cartProvider,
                                        productModel,
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: _getResponsiveSize(context, 2),
                                      horizontal: _getResponsiveSize(
                                        context,
                                        4,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: Size(
                                      0,
                                      _getResponsiveSize(context, 20),
                                    ),
                                  ),
                                  child: Text(
                                    'Cart',
                                    style: TextStyle(
                                      fontSize: _getResponsiveSize(context, 8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: _getResponsiveSize(context, 3)),
                              Container(
                                width: _getResponsiveSize(context, 25),
                                height: _getResponsiveSize(context, 20),
                                child: IconButton(
                                  onPressed:
                                      () => _toggleWishlist(
                                        wishlistProvider,
                                        productModel,
                                      ),
                                  icon: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isInWishlist ? Colors.red : Colors.grey,
                                    size: _getResponsiveSize(context, 12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackProductImage(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFF98FB98), // Light green
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Main product bottle
          Positioned(
            top: _getResponsiveSize(context, 15),
            left: _getResponsiveSize(context, 15),
            child: Container(
              width: _getResponsiveSize(context, 45),
              height: _getResponsiveSize(context, 75),
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[700]!, width: 1),
              ),
              child: Column(
                children: [
                  // Bottle cap
                  Container(
                    width: _getResponsiveSize(context, 30),
                    height: _getResponsiveSize(context, 15),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: _getResponsiveSize(context, 5)),
                  // Product label
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(_getResponsiveSize(context, 4)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _getResponsiveSize(context, 6),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: _getResponsiveSize(context, 5)),
                          Icon(
                            Icons.agriculture,
                            size: _getResponsiveSize(context, 20),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Disease examples
          Positioned(
            top: _getResponsiveSize(context, 10),
            right: _getResponsiveSize(context, 5),
            child: Container(
              width: _getResponsiveSize(context, 30),
              height: _getResponsiveSize(context, 30),
              decoration: BoxDecoration(
                color: Colors.brown[600],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.grass,
                color: Colors.white,
                size: _getResponsiveSize(context, 14),
              ),
            ),
          ),
          Positioned(
            bottom: _getResponsiveSize(context, 10),
            right: _getResponsiveSize(context, 5),
            child: Container(
              width: _getResponsiveSize(context, 30),
              height: _getResponsiveSize(context, 30),
              decoration: BoxDecoration(
                color: Colors.brown[800],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.bug_report,
                color: Colors.white,
                size: _getResponsiveSize(context, 14),
              ),
            ),
          ),
          // Discount label
          if (product['price'] < 40000)
            Positioned(
              top: _getResponsiveSize(context, 5),
              left: _getResponsiveSize(context, 5),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveSize(context, 6),
                  vertical: _getResponsiveSize(context, 2),
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Discount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getResponsiveSize(context, 8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Functional methods
  void _performSearch() {
    // Implement search logic
    if (_searchQuery.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a search term')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "${_searchQuery}"...')),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getResponsiveSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _getResponsiveSize(context, 16)),
              ..._sortOptions.map(
                (option) => ListTile(
                  title: Text(option, style: TextStyle(color: Colors.white)),
                  trailing:
                      _selectedSort == option
                          ? Icon(Icons.check, color: Colors.green)
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
        );
      },
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: Colors.white),
                title: Text('Refresh', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    // Refresh the page
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Refreshed!')));
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Share functionality would open here'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.white),
                title: Text('Help', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Help section would open here')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => WishlistPage()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ProfilePage()));
        break;
    }
  }

  // Helper methods for responsive design
  double _getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base width (iPhone 6/7/8)
    return baseSize * scaleFactor.clamp(0.8, 2.0);
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) return 2; // Desktop
    if (screenWidth > 600) return 2; // Tablet
    return 1; // Phone
  }

  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) return 3.5; // Desktop
    if (screenWidth > 600) return 3.0; // Tablet
    return 2.5; // Phone
  }

  void _addToCart(CartProvider cartProvider, ProductModel product) {
    cartProvider.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleWishlist(
    WishlistProvider wishlistProvider,
    ProductModel product,
  ) {
    final isInWishlist = wishlistProvider.isInWishlist(product.id);
    if (isInWishlist) {
      wishlistProvider.removeFromWishlist(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} removed from wishlist'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      wishlistProvider.addToWishlist(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to wishlist'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
