import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantguard_ai/ui/models/product_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:plantguard_ai/screens/plant_analysis/ui/plant_analysis.dart';
import '/wishlist_page.dart';
import 'package:plantguard_ai/screens/profile/profile_page.dart';
import '/providers/theme_provider.dart';
import '/providers/product_provider.dart';
import '/providers/wishlist_provider.dart';
import '/providers/image_history_provider.dart';
import '/ui/widgets/video_player_widget.dart';
import '/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Pages to display for each tab
  final List<Widget> _pages = [
    const HomeContent(), // Your existing home content
    const Center(child: Text('Wishlist')),
    const Center(child: Text('Profile Page')),
  ];

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picking cancelled.')),
        );
        return;
      }

      final imageFile = File(pickedFile.path);

      // Save image to history provider for analysis
      final imageHistoryProvider = Provider.of<ImageHistoryProvider>(
        context,
        listen: false,
      );
      final imageId = await imageHistoryProvider.addImageForAnalysis(
        imageFile: imageFile,
        location: 'Plant Analysis',
        notes: 'Analyzed via mobile app',
      );

      final fileName = path.basename(imageFile.path);
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'image/jpeg'; // default fallback
      final fileSize = await imageFile.length();

      final uri = Uri.parse(
        'https://sng43.onrender.com/webhook/ae669c75-11b9-4ef6-af73-47c175e64d3a',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['filename'] = fileName
        ..fields['mimetype'] = mimeType
        ..fields['size'] = fileSize.toString()
        ..fields['submittedAt'] = DateTime.now().toIso8601String()
        // ..fields['formMode'] = 'test'
        ..files.add(
          await http.MultipartFile.fromPath(
            'data',
            imageFile.path,
            contentType: MediaType.parse(mimeType),
            filename: fileName,
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Raw response.body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List &&
            body.isNotEmpty &&
            body[0] is Map<String, dynamic>) {
          final result = body[0];

          final confidence =
              double.tryParse(
                (result['confidenceScore'] ?? '0').replaceAll('%', ''),
              ) ??
              0;

          final symptoms =
              (jsonDecode(result['symptomsIdentified']) as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
          // Update the image history with analysis results
          final isHealthy =
              (result['diseaseName'] ?? 'Unknown').toLowerCase() == 'healthy' ||
              (result['diseaseName'] ?? 'Unknown').toLowerCase() ==
                  'no disease detected';

          await imageHistoryProvider.updateAnalysisResults(
            imageId: imageId,
            status: isHealthy ? 'Healthy' : 'Disease Detected',
            disease: isHealthy ? null : (result['diseaseName'] ?? 'Unknown'),
            confidence: confidence,
            analysisResults: {
              'plantName': result['plantName'] ?? 'Unknown',
              'diseaseName': result['diseaseName'] ?? 'Unknown',
              'symptoms': RegExp(r"'([^']+)'")
                  .allMatches(result['symptomsIdentified'] ?? '')
                  .map((m) => m.group(1)!)
                  .toList(),
              'description': result['shortDiseaseDescrition'] ?? '',
              'imageUrl': result['imageUrl'] ?? '',
            },
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantAnalysis(
                plantName: result['plantName'] ?? 'Unknown',
                diseaseName: result['diseaseName'] ?? 'Unknown',
                confidenceScore: confidence,
                symptoms: symptoms,
                diseaseDescription: result['shortDiseaseDescrition'] ?? '',
                imageFile: result['imageUrl'] ?? '',
              ),
            ),
          );
        } else {
          // If analysis fails, update the image as failed
          await imageHistoryProvider.updateAnalysisResults(
            imageId: imageId,
            status: 'Analysis Failed',
            analysisResults: {'error': 'Unexpected response format'},
          );
          throw Exception('Unexpected or empty response format.');
        }
      } else {
        // If API call fails, update the image as failed
        await imageHistoryProvider.updateAnalysisResults(
          imageId: imageId,
          status: 'Analysis Failed',
          analysisResults: {'error': 'API Error: ${response.statusCode}'},
        );
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: TextStyle(color: themeProvider.textColor),
            decoration: InputDecoration(
              hintText: 'Start your search',
              hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
              prefixIcon: Icon(
                Icons.search,
                color: themeProvider.secondaryTextColor,
              ),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: themeProvider.secondaryTextColor,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _isSearching ? _buildSearchResults() : _pages[_currentIndex],
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(themeProvider),
    );
  }

  Widget _buildSearchResults() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: themeProvider.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 18,
                    color: themeProvider.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${productProvider.searchResults.length} results found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65, // Reduced to give more height
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.searchResults[index];
                    return _buildGridProductCard(
                      product,
                      themeProvider,
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(ThemeProvider themeProvider) {
    return Container(
      height: 70,
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
            isActive: _currentIndex == 0,
            onTap: () => _onTabTapped(0),
            themeProvider: themeProvider,
          ),
          _buildNavItem(
            icon: Icons.favorite,
            label: 'Wishlist',
            isActive: _currentIndex == 1,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WishlistPage()),
              );
            },
            themeProvider: themeProvider,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: _currentIndex == 2,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            themeProvider: themeProvider,
          ),
        ],
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.green : themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.green : themeProvider.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return; // Prevent re-tapping the same tab
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildGridProductCard(
    ProductModel product,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 24),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9, // Reduced font size
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2), // Small spacing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\RWF${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 8, // Reduced font size
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 7,
                                ), // Smaller icon
                                const SizedBox(width: 1),
                                Flexible(
                                  child: Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 7,
                                    ), // Reduced font size
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Wishlist heart icon
            Positioned(
              top: 4,
              right: 4,
              child: Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final isInWishlist = wishlistProvider.isInWishlist(
                    product.id,
                  );
                  return GestureDetector(
                    onTap: () async {
                      try {
                        await wishlistProvider.toggleWishlist(product);

                        final isNowInWishlist = wishlistProvider.isInWishlist(
                          product.id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isNowInWishlist
                                  ? '${product.name} added to wishlist'
                                  : '${product.name} removed from wishlist',
                            ),
                            backgroundColor: isNowInWishlist
                                ? Colors.red
                                : Colors.grey[600],
                            duration: const Duration(seconds: 1),
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
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey[600],
                        size: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Fetch products when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Force update Firestore with YouTube tutorial data
      await productProvider.forceUpdateFirestoreWithYouTubeData();
      // Then fetch products from Firestore
      productProvider.fetchProducts();
    });

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Show loading indicator while fetching products OR if no products loaded yet
        if (productProvider.isLoading ||
            (productProvider.products.isEmpty &&
                productProvider.pesticides.isEmpty &&
                productProvider.fertilizers.isEmpty &&
                productProvider.plants.isEmpty &&
                productProvider.tutorials.isEmpty)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading products...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Camera Upload Section
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          (context
                              .findAncestorStateOfType<_HomePageState>()
                              ?._showImageSourceDialog());
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey[600],
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pesticides Section
                _buildSectionHeader('Pesticides', themeProvider),
                const SizedBox(height: 12),
                _buildProductGrid(
                  productProvider.pesticides,
                  themeProvider,
                  'pesticides',
                  context,
                  productProvider.isLoading,
                ),

                const SizedBox(height: 24),

                // Plants Section (Using fertilizers as plants for demo)
                _buildSectionHeader('Plants', themeProvider),
                const SizedBox(height: 12),
                _buildProductGrid(
                  productProvider.plants,
                  themeProvider,
                  'plants',
                  context,
                  productProvider.isLoading,
                ),

                const SizedBox(height: 24),

                // Fertilizers Section
                _buildSectionHeader('Fertilizers', themeProvider),
                const SizedBox(height: 12),
                _buildProductGrid(
                  productProvider.fertilizers,
                  themeProvider,
                  'fertilizers',
                  context,
                  productProvider.isLoading,
                ),

                const SizedBox(height: 24),

                // Tutorials Section
                _buildSectionHeader('Tutorials', themeProvider),
                const SizedBox(height: 12),
                _buildProductGrid(
                  productProvider.tutorials,
                  themeProvider,
                  'tutorials',
                  context,
                  productProvider.isLoading,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: themeProvider.textColor,
      ),
    );
  }

  Widget _buildProductGrid(
    List<ProductModel> products,
    ThemeProvider themeProvider,
    String section,
    BuildContext context,
    bool isLoading,
  ) {
    if (isLoading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Loading...',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'loading...',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 120, // Fixed width for each product card
            margin: const EdgeInsets.only(right: 8),
            child: product.category == 'tutorial' && product.videoUrl != null
                ? _buildVideoTutorialCard(product, themeProvider, context)
                : _buildGridProductCard(product, themeProvider, context),
          );
        },
      ),
    );
  }

  Widget _buildVideoTutorialCard(
    ProductModel product,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (product.videoUrl != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return VideoPlayerWidget(
                videoUrl: product.videoUrl!,
                title: product.name,
              );
            },
          );
        }
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: Stack(
                  children: [
                    // Thumbnail image
                    Image.network(
                      product.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.video_library, size: 24),
                      ),
                    ),
                    // Play button overlay
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Video badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIDEO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\RWF${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 7,
                            ),
                            const SizedBox(width: 1),
                            Flexible(
                              child: Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridProductCard(
    ProductModel product,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 24),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9, // Reduced font size
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2), // Small spacing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\RWF${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 8, // Reduced font size
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 7,
                                ), // Smaller icon
                                const SizedBox(width: 1),
                                Flexible(
                                  child: Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 7,
                                    ), // Reduced font size
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Wishlist heart icon
            Positioned(
              top: 4,
              right: 4,
              child: Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final isInWishlist = wishlistProvider.isInWishlist(
                    product.id,
                  );
                  return GestureDetector(
                    onTap: () async {
                      try {
                        await wishlistProvider.toggleWishlist(product);

                        final isNowInWishlist = wishlistProvider.isInWishlist(
                          product.id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isNowInWishlist
                                  ? '${product.name} added to wishlist'
                                  : '${product.name} removed from wishlist',
                            ),
                            backgroundColor: isNowInWishlist
                                ? Colors.red
                                : Colors.grey[600],
                            duration: const Duration(seconds: 1),
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
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey[600],
                        size: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
