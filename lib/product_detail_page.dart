import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/models/product_model.dart';
import 'providers/currency_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/home_page.dart';
import 'wishlist_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/payment_screens/rwanda_payment.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentIndex = 0;
  int _selectedTabIndex = 0; // 0 for Overview, 1 for Guide
  int _currentGuidePage = 0; // For guide pagination

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),

          // Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildOverviewTab()
                : _buildGuideTab(),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(currencyProvider),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabButton('Overview', 0, isSelected: _selectedTabIndex == 0),
          const SizedBox(width: 40),
          _buildTabButton('Guide', 1, isSelected: _selectedTabIndex == 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Product Image Section - Full width grey background
        Expanded(flex: 3, child: _buildProductImageSection()),

        // Product Details Section - Black background
        Expanded(flex: 2, child: _buildProductDetailsSection()),
      ],
    );
  }

  // Helper method to split guide content into pages
  List<String> _getGuidePages() {
    String content =
        widget.product.howToApply ??
        '1. Apply this product according to manufacturer instructions.\n'
            '2. Follow safety guidelines during application.\n'
            '3. Store in a cool, dry place after use.\n'
            '4. Ensure proper protective equipment is used.\n'
            '5. Apply during appropriate weather conditions.\n'
            '6. Follow the recommended dosage carefully.';

    // Split content into sentences and group them for better pagination
    List<String> sentences = content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    List<String> pages = [];

    // Group sentences into pages (2 sentences per page for better fit without scrolling)
    for (int i = 0; i < sentences.length; i += 2) {
      int end = (i + 2 < sentences.length) ? i + 2 : sentences.length;
      pages.add(sentences.sublist(i, end).join('\n'));
    }

    return pages.isEmpty ? ['No guide content available.'] : pages;
  }

  Widget _buildGuideTab() {
    List<String> guidePages = _getGuidePages();
    int totalPages = guidePages.length;

    return Column(
      children: [
        // Product image section with grey background - reduced height
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            color: Colors.grey[400],
            child: widget.product.image.startsWith('http')
                ? Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green[100],
                        child: Icon(
                          Icons.local_pharmacy,
                          color: Colors.green,
                          size: 80,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green[100],
                        child: Icon(
                          Icons.local_pharmacy,
                          color: Colors.green,
                          size: 80,
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Bottom section with guide content - increased height
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // How to Apply section with pagination
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'How to Apply :-',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (totalPages > 1)
                              Text(
                                '${_currentGuidePage + 1}/$totalPages',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              guidePages[_currentGuidePage],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                height: 1.5,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _currentGuidePage > 0
                            ? () {
                                setState(() {
                                  _currentGuidePage--;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentGuidePage > 0
                                ? Colors.red[300]
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: _currentGuidePage > 0
                                    ? Colors.black
                                    : Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Previous',
                                style: TextStyle(
                                  color: _currentGuidePage > 0
                                      ? Colors.black
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _currentGuidePage < totalPages - 1
                            ? () {
                                setState(() {
                                  _currentGuidePage++;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentGuidePage < totalPages - 1
                                ? Colors.green
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  color: _currentGuidePage < totalPages - 1
                                      ? Colors.black
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: _currentGuidePage < totalPages - 1
                                    ? Colors.black
                                    : Colors.grey[400],
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImageSection() {
    return Container(
      width: double.infinity,
      color: Colors.grey[400], // Grey background as shown in screenshot
      child: Stack(
        children: [
          // Main product image - fills the entire grey area
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.product.image.startsWith('http')
                ? Image.network(
                    widget.product.image,
                    fit: BoxFit
                        .cover, // Changed to cover to fill entire container
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackImage(),
                  )
                : Image.asset(
                    widget.product.image,
                    fit: BoxFit
                        .cover, // Changed to cover to fill entire container
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackImage(),
                  ),
          ),

          // Heart/Wishlist icon in top right
          Positioned(
            right: 20,
            top: 20,
            child: Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, child) {
                final isInWishlist = wishlistProvider.isInWishlist(
                  widget.product.id,
                );
                return GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Text(
              currencyProvider.formatPriceSync(widget.product.price),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
      
            const SizedBox(height: 12),
      
            // Product Name
            Text(
              widget.product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
      
            const SizedBox(height: 12),
      
            // Product Description
            Text(
              widget.product.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
      
            const SizedBox(height: 16),
      
            // Rating and Orders
            Row(
              children: [
                Text(
                  '${widget.product.orders} orders',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 20),
                // Star Rating
                Row(
                  children: [
                    Text(
                      widget.product.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < widget.product.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(CurrencyProvider currencyProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Row(
        children: [
          // Cart Button
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _addToCart,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[600]!),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Buy Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _buyNow,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Buy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black, // Changed from grey to black
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey[600],
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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

  void _addToCart() {
    // Remove unused variable
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }

  void _buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RwandaPaymentScreen(product: widget.product),
      ),
    );
  }

  void _toggleWishlist() async {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );

    try {
      await wishlistProvider.toggleWishlist(widget.product);

      final isNowInWishlist = wishlistProvider.isInWishlist(widget.product.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowInWishlist
                ? '${widget.product.name} added to wishlist'
                : '${widget.product.name} removed from wishlist',
          ),
          backgroundColor: isNowInWishlist ? Colors.red : Colors.grey[600],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating wishlist: $e'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }
}
