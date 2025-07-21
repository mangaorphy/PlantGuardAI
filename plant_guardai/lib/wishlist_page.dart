import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'product_detail_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/home/home_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(
        context,
        listen: false,
      );
      if (wishlistProvider.isEmpty) {
        wishlistProvider.initializeWishlist();
      }
    });
  }

  double _getResponsiveSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1024) return baseSize * 1.2; // Desktop
    if (screenWidth > 600) return baseSize * 1.1; // Tablet
    return baseSize; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final filteredItems =
            _searchQuery.isEmpty
                ? wishlistProvider.items
                : wishlistProvider.searchWishlist(_searchQuery);

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
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
                title: Text(
                  'Wishlist (${wishlistProvider.itemCount})',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: _getResponsiveSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: themeProvider.textColor,
                      size: _getResponsiveSize(context, 24),
                    ),
                    onPressed: _showSearchDialog,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      color: themeProvider.textColor,
                      size: _getResponsiveSize(context, 24),
                    ),
                    onPressed: () => _showSortDialog(wishlistProvider),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: themeProvider.textColor,
                      size: _getResponsiveSize(context, 24),
                    ),
                    onPressed: () => _showOptionsMenu(wishlistProvider),
                  ),
                ],
              ),
              body:
                  filteredItems.isEmpty
                      ? _buildEmptyState()
                      : _buildWishlistContent(filteredItems),
              bottomNavigationBar: _buildBottomNavigationBar(context),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline,
                size: _getResponsiveSize(context, 80),
                color: themeProvider.secondaryTextColor,
              ),
              SizedBox(height: _getResponsiveSize(context, 20)),
              Text(
                _searchQuery.isEmpty
                    ? 'Your wishlist is empty'
                    : 'No items found',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: _getResponsiveSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _getResponsiveSize(context, 8)),
              Text(
                _searchQuery.isEmpty
                    ? 'Add products you love to see them here'
                    : 'Try a different search term',
                style: TextStyle(
                  color: themeProvider.secondaryTextColor,
                  fontSize: _getResponsiveSize(context, 16),
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                SizedBox(height: _getResponsiveSize(context, 30)),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: _getResponsiveSize(context, 32),
                      vertical: _getResponsiveSize(context, 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getResponsiveSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistContent(List filteredItems) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 2 : 1;

    if (isTablet) {
      return GridView.builder(
        padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2,
          crossAxisSpacing: _getResponsiveSize(context, 16),
          mainAxisSpacing: _getResponsiveSize(context, 16),
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return _buildWishlistCard(filteredItems[index]);
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return _buildWishlistItem(filteredItems[index]);
        },
      );
    }
  }

  Widget _buildWishlistItem(dynamic product) {
    return Consumer2<CartProvider, ThemeProvider>(
      builder: (context, cartProvider, themeProvider, child) {
        return Container(
          margin: EdgeInsets.only(bottom: _getResponsiveSize(context, 16)),
          padding: EdgeInsets.all(_getResponsiveSize(context, 16)),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: _getResponsiveSize(context, 80),
                height: _getResponsiveSize(context, 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green[100],
                        child: Icon(
                          Icons.local_pharmacy,
                          color: Colors.green,
                          size: _getResponsiveSize(context, 40),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: _getResponsiveSize(context, 16)),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: _getResponsiveSize(context, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSize(context, 4)),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: _getResponsiveSize(context, 14),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _getResponsiveSize(context, 8)),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: _getResponsiveSize(context, 16),
                        ),
                        SizedBox(width: _getResponsiveSize(context, 4)),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: _getResponsiveSize(context, 14),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _getResponsiveSize(context, 8)),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return Text(
                          currencyProvider.formatPriceSync(
                            product.price.toDouble(),
                          ),
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: _getResponsiveSize(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeFromWishlist(product),
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: _getResponsiveSize(context, 24),
                    ),
                  ),
                  SizedBox(height: _getResponsiveSize(context, 8)),
                  ElevatedButton(
                    onPressed: () => _addToCart(cartProvider, product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveSize(context, 12),
                        vertical: _getResponsiveSize(context, 8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveSize(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistCard(dynamic product) {
    return Consumer2<CartProvider, ThemeProvider>(
      builder: (context, cartProvider, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          product.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.green[100],
                              child: const Icon(
                                Icons.local_pharmacy,
                                color: Colors.green,
                                size: 40,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () => _removeFromWishlist(product),
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        if (product.isNew)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Product Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return Text(
                            currencyProvider.formatPriceSync(
                              product.price.toDouble(),
                            ),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _addToCart(cartProvider, product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: _getResponsiveSize(context, 70),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            border: Border(top: BorderSide(color: themeProvider.borderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                themeProvider: themeProvider,
              ),
              _buildNavItem(
                icon: Icons.favorite,
                label: 'Wishlist',
                isActive: true,
                onTap: () {},
                themeProvider: themeProvider,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveSize(context, 16),
          vertical: _getResponsiveSize(context, 8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.green : themeProvider.textColor,
              size: _getResponsiveSize(context, 24),
            ),
            SizedBox(height: _getResponsiveSize(context, 4)),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.green : themeProvider.textColor,
                fontSize: _getResponsiveSize(context, 12),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor: themeProvider.cardColor,
                title: Text(
                  'Search Wishlist',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                content: TextField(
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                      color: themeProvider.secondaryTextColor,
                    ),
                    filled: true,
                    fillColor: themeProvider.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(color: themeProvider.secondaryTextColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Search'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showSortDialog(WishlistProvider wishlistProvider) {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor: themeProvider.cardColor,
                title: Text(
                  'Sort Wishlist',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSortOption('Default', 'default', wishlistProvider),
                    _buildSortOption('Name (A-Z)', 'name', wishlistProvider),
                    _buildSortOption(
                      'Price (Low to High)',
                      'price_low',
                      wishlistProvider,
                    ),
                    _buildSortOption(
                      'Price (High to Low)',
                      'price_high',
                      wishlistProvider,
                    ),
                    _buildSortOption(
                      'Rating (High to Low)',
                      'rating',
                      wishlistProvider,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildSortOption(
    String title,
    String value,
    WishlistProvider wishlistProvider,
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          title: Text(title, style: TextStyle(color: themeProvider.textColor)),
          leading: Radio<String>(
            value: value,
            groupValue: _sortBy,
            onChanged: (String? value) {
              setState(() {
                _sortBy = value!;
              });
              wishlistProvider.sortWishlist(value!);
              Navigator.pop(context);
            },
            activeColor: Colors.green,
          ),
        );
      },
    );
  }

  void _showOptionsMenu(WishlistProvider wishlistProvider) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                color: themeProvider.cardColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.clear_all, color: Colors.red),
                      title: Text(
                        'Clear All Items',
                        style: TextStyle(color: themeProvider.textColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _clearWishlist(wishlistProvider);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.green),
                      title: Text(
                        'Share Wishlist',
                        style: TextStyle(color: themeProvider.textColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _shareWishlist();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _removeFromWishlist(dynamic product) {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    wishlistProvider.removeFromWishlist(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from wishlist'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addToCart(CartProvider cartProvider, dynamic product) {
    cartProvider.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearWishlist(WishlistProvider wishlistProvider) {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor: themeProvider.cardColor,
                title: Text(
                  'Clear Wishlist',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                content: Text(
                  'Are you sure you want to remove all items from your wishlist?',
                  style: TextStyle(color: themeProvider.secondaryTextColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: themeProvider.secondaryTextColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      wishlistProvider.clearWishlist();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wishlist cleared'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _shareWishlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing wishlist...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
