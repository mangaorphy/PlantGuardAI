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


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isLoading = false;

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
      final fileName = path.basename(imageFile.path);
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'image/jpeg'; // default fallback
      final fileSize = await imageFile.length();

      final uri = Uri.parse(
        'https://sng404.onrender.com/webhook/ae669c75-11b9-4ef6-af73-47c175e64d3a',
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

          // 🛠️ Parse symptoms from either string or list
          final dynamic symptomsRaw = result['symptomsIdentified'];
          List<String> symptoms = [];

          if (symptomsRaw is List) {
            symptoms = List<String>.from(symptomsRaw);
          } else if (symptomsRaw is String) {
            symptoms = RegExp(
              r"'([^']+)'",
            ).allMatches(symptomsRaw).map((m) => m.group(1)!).toList();
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantAnalysis(
                plantName: result['plantName'] ?? 'Unknown',
                diseaseName: result['diseaseName'] ?? 'Unknown',
                confidenceScore: confidence,
                symptoms: RegExp(r"'([^']+)'")
                    .allMatches(result['symptomsIdentified'] ?? '')
                    .map((m) => m.group(1)!)
                    .toList(),
                diseaseDescription: result['shortDiseaseDescrition'] ?? '',
                imageFile: result['imageUrl'] ?? '',
              ),
            ),
          );
        } else {
          throw Exception('Unexpected or empty response format.');
        }
      } else {
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[200] : Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            style: TextStyle(color: themeProvider.textColor),
            decoration: InputDecoration(
              hintText: 'Start your search',
              hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
              prefixIcon: Icon(Icons.search, color: themeProvider.secondaryTextColor),
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
          _pages[_currentIndex],
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(themeProvider),
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
    required VoidCallback onTap, required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive 
                ? Colors.green 
                : themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive 
                  ? Colors.green 
                  : themeProvider.secondaryTextColor,
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
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Fetch products when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider.fetchProducts();
    });

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Camera icon (keep existing code)
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
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan Plant',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Latest Section
                const SizedBox(height: 20),
                _buildLatestItemCard('NPK Fertilizer', themeProvider),

                const SizedBox(height: 20),

                // Featured Products Section
                const SizedBox(height: 20),
                Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: productProvider.featuredProducts.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.featuredProducts[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 10),
                              child: _buildProductCard(product, themeProvider),
                            );
                          },
                        ),
                ),

                // Pesticides Section
                const SizedBox(height: 20),
                Text(
                  'Pesticides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: productProvider.pesticides.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.pesticides.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.pesticides[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 10),
                              child: _buildProductCard(product, themeProvider),
                            );
                          },
                        ),
                ),

                // Fertilizers Section
                const SizedBox(height: 20),
                Text(
                  'Fertilizers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: productProvider.fertilizers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.fertilizers.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.fertilizers[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 10),
                              child: _buildProductCard(product, themeProvider),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  static Widget _buildLatestItemCard(String title, ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/npk_fertilizer.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LATEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Balanced nutrients for plant growth',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '4.8',
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                '\$12.99',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[300],
                                  fontSize: 16,
                                ),
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
          ],
        ),
      ),
    );
  }

  static Widget _buildProductCard(ProductModel product, ThemeProvider themeProvider) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              product.image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(product.rating.toStringAsFixed(1)),
                    const Spacer(),
                    if (product.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                const SizedBox(height: 4),
                Text(
                  '${product.orders} orders',
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}