import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../wishlist_page.dart';
import '../home/home_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import '../../cart_page.dart';
import '../../image_history_page.dart';
import '../../recent_search_page.dart';
import 'address_management_page.dart';
import 'customer_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2; // Profile tab selected

  @override
  void initState() {
    super.initState();
    // Initialize user data if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.initializeUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(themeProvider),
                _buildProfileSection(themeProvider),
                _buildOrderStatusSection(themeProvider),
                _buildMenuSection(themeProvider),
                const SizedBox(height: 20),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(themeProvider),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showLanguageSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Row(
                    children: [
                      Text(
                        userProvider.currentLanguage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _openQRScanner,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ThemeProvider themeProvider) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: ClipOval(
                        child:
                            userProvider.profileImageFile != null
                                ? Image.file(
                                  userProvider.profileImageFile!,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  'assets/images/Rectangle 42.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[700],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: themeProvider.backgroundColor,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mariam',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Order',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOrderStatusItem(
                Icons.access_time,
                'Pending\nPayment',
                onTap: () => _showOrderStatus('Pending Payment'),
                themeProvider: themeProvider,
              ),
              _buildOrderStatusItem(
                Icons.inventory_2,
                'To Ship\n(Packing)',
                onTap: () => _showOrderStatus('To Ship'),
                themeProvider: themeProvider,
              ),
              _buildOrderStatusItem(
                Icons.local_shipping,
                'Shipping\nFeedback',
                hasNotification: true,
                onTap: () => _showOrderStatus('Shipping'),
                themeProvider: themeProvider,
              ),
              _buildOrderStatusItem(
                Icons.star_rate,
                'Rate &\nReview',
                onTap: () => _showOrderStatus('Rate & Review'),
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    IconData icon,
    String label, {
    bool hasNotification = false,
    VoidCallback? onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeProvider.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeProvider.textColor, size: 20),
              ),
              if (hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.shopping_cart, 'Cart', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItem(Icons.favorite, 'Wish List', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItemWithImages(Icons.image, 'Image History', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImageHistoryPage()),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItemWithImages(Icons.search, 'Recently Searched', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecentSearchPage()),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItem(Icons.location_on, 'Address Management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddressManagementPage(),
              ),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItem(Icons.headset_mic, 'Customer Center', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerCenterPage(),
              ),
            );
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItem(Icons.person_add, 'Invite Friend', () {
            _showInviteFriend();
          }, themeProvider),
          _buildMenuDivider(themeProvider),
          _buildMenuItem(Icons.chat, 'Friend Code', () {
            _showFriendCode();
          }, themeProvider),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: themeProvider.textColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: themeProvider.secondaryTextColor,
        size: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildMenuItemWithImages(
    IconData icon,
    String title,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: themeProvider.textColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Actual thumbnail images
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/Rectangle 42.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue[600],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/Rectangle 35.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.orange[600],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/product_listing.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.green[600],
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: themeProvider.secondaryTextColor,
            size: 14,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildMenuDivider(ThemeProvider themeProvider) {
    return Container(
      height: 1,
      color: themeProvider.borderColor,
      margin: const EdgeInsets.only(left: 52, right: 16),
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
            isActive: false,
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
            isActive: true,
            onTap: () {}, // Already on profile page
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.green : themeProvider.textColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.green : themeProvider.textColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openQRScanner() {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor: themeProvider.cardColor,
                title: Text(
                  'QR Code Scanner',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera access required to scan QR codes',
                      style: TextStyle(color: themeProvider.secondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR Scanner would open here'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Open Scanner',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Kinyarwanda', 'French', 'Swahili'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              color: themeProvider.cardColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...languages.map((language) {
                    return ListTile(
                      leading: const Icon(Icons.language, color: Colors.green),
                      title: Text(
                        language,
                        style: TextStyle(color: themeProvider.textColor),
                      ),
                      trailing:
                          language == 'English'
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                      onTap: () {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        userProvider.setLanguage(language);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Language changed to $language'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderStatus(String statusType) {
    final statusData = _getOrderStatusData(statusType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              color: themeProvider.cardColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusData['icon'], color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        statusType,
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: statusData['orders'].length,
                      itemBuilder: (context, index) {
                        final order = statusData['orders'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeProvider.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_pharmacy,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order['name'],
                                      style: TextStyle(
                                        color: themeProvider.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Order #${order['id']}',
                                      style: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer<CurrencyProvider>(
                                      builder: (
                                        context,
                                        currencyProvider,
                                        child,
                                      ) {
                                        return Text(
                                          currencyProvider.formatPriceSync(
                                            order['price'].toDouble(),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    order['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(order['status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildOrderActionButton(
                                    statusType,
                                    order,
                                    themeProvider,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic> _getOrderStatusData(String statusType) {
    switch (statusType) {
      case 'Pending Payment':
        return {
          'icon': Icons.access_time,
          'orders': [
            {
              'id': '12345',
              'name': 'Megha Star',
              'price': 40000.0,
              'status': 'Payment Due',
            },
            {
              'id': '12346',
              'name': 'Plant Protection Kit',
              'price': 25000.0,
              'status': 'Payment Due',
            },
          ],
        };
      case 'To Ship':
        return {
          'icon': Icons.inventory_2,
          'orders': [
            {
              'id': '12347',
              'name': 'Bio Fertilizer',
              'price': 15000.0,
              'status': 'Packing',
            },
            {
              'id': '12348',
              'name': 'Pest Control',
              'price': 30000.0,
              'status': 'Ready to Ship',
            },
          ],
        };
      case 'Shipping':
        return {
          'icon': Icons.local_shipping,
          'orders': [
            {
              'id': '12349',
              'name': 'Growth Enhancer',
              'price': 20000.0,
              'status': 'In Transit',
            },
            {
              'id': '12350',
              'name': 'Soil Treatment',
              'price': 35000.0,
              'status': 'Out for Delivery',
            },
          ],
        };
      case 'Rate & Review':
        return {
          'icon': Icons.star_rate,
          'orders': [
            {
              'id': '12351',
              'name': 'Organic Pesticide',
              'price': 18000.0,
              'status': 'Delivered',
            },
            {
              'id': '12352',
              'name': 'Plant Nutrients',
              'price': 22000.0,
              'status': 'Delivered',
            },
          ],
        };
      default:
        return {'icon': Icons.shopping_bag, 'orders': []};
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Payment Due':
        return Colors.orange;
      case 'Packing':
      case 'Ready to Ship':
        return Colors.blue;
      case 'In Transit':
      case 'Out for Delivery':
        return Colors.green;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderActionButton(
    String statusType,
    Map<String, dynamic> order,
    ThemeProvider themeProvider,
  ) {
    String buttonText;
    Color buttonColor;
    VoidCallback onPressed;

    switch (statusType) {
      case 'Pending Payment':
        buttonText = 'Pay Now';
        buttonColor = Colors.orange;
        onPressed = () => _payForOrder(order);
        break;
      case 'To Ship':
        buttonText = 'Track';
        buttonColor = Colors.blue;
        onPressed = () => _trackOrder(order);
        break;
      case 'Shipping':
        buttonText = 'Track';
        buttonColor = Colors.green;
        onPressed = () => _trackOrder(order);
        break;
      case 'Rate & Review':
        buttonText = 'Rate';
        buttonColor = Colors.green;
        onPressed = () => _rateOrder(order);
        break;
      default:
        buttonText = 'View';
        buttonColor = Colors.grey;
        onPressed = () => _viewOrder(order);
    }

    return SizedBox(
      width: 60,
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    print('Profile picture tapped - showing options'); // Debug print
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              color: themeProvider.cardColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImageOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () {
                          print('Camera option tapped'); // Debug print
                          Navigator.pop(context);
                          _pickImageFromCamera();
                        },
                        themeProvider: themeProvider,
                      ),
                      _buildImageOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () {
                          print('Gallery option tapped'); // Debug print
                          Navigator.pop(context);
                          _pickImageFromGallery();
                        },
                        themeProvider: themeProvider,
                      ),
                      // Check if user has a custom profile image
                      if (context.read<UserProvider>().profileImageFile != null)
                        _buildImageOption(
                          icon: Icons.delete,
                          label: 'Remove',
                          onTap: () {
                            Navigator.pop(context);
                            _removeProfileImage();
                          },
                          themeProvider: themeProvider,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: themeProvider.textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    print('_pickImageFromCamera called'); // Debug print
    try {
      final ImagePicker picker = ImagePicker();
      print('ImagePicker created, attempting to open camera'); // Debug print

      // Try multiple approaches for camera
      XFile? image;

      try {
        image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
      } catch (cameraError) {
        print(
          'Direct camera failed, trying with different settings: $cameraError',
        );

        // Try with minimal settings
        image = await picker.pickImage(source: ImageSource.camera);
      }

      print('Camera picker returned: ${image?.path ?? 'null'}'); // Debug print

      if (image != null) {
        final File imageFile = File(image.path);
        print('Image file exists: ${await imageFile.exists()}'); // Debug print
        print(
          'Image file size: ${await imageFile.length()} bytes',
        ); // Debug print

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateProfileImageFile(imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Profile picture updated from camera!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('User cancelled camera or camera unavailable'); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera was cancelled or unavailable'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Camera error details: $e'); // Debug print
      print('Error type: ${e.runtimeType}'); // Debug print

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Try Gallery',
            onPressed: _pickImageFromGallery,
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    print('_pickImageFromGallery called'); // Debug print
    try {
      final ImagePicker picker = ImagePicker();
      print('ImagePicker created, attempting to open gallery'); // Debug print

      // Try multiple approaches for gallery
      XFile? image;

      try {
        image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );
      } catch (galleryError) {
        print('Gallery with settings failed, trying minimal: $galleryError');

        // Try with minimal settings
        image = await picker.pickImage(source: ImageSource.gallery);
      }

      print('Gallery picker returned: ${image?.path ?? 'null'}'); // Debug print

      if (image != null) {
        final File imageFile = File(image.path);
        print('Image file exists: ${await imageFile.exists()}'); // Debug print
        print(
          'Image file size: ${await imageFile.length()} bytes',
        ); // Debug print

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateProfileImageFile(imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🖼️ Profile picture updated from gallery!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print(
          'User cancelled gallery selection or gallery unavailable',
        ); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallery selection was cancelled'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Gallery error details: $e'); // Debug print
      print('Error type: ${e.runtimeType}'); // Debug print

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Try Camera',
            onPressed: _pickImageFromCamera,
          ),
        ),
      );
    }
  }

  void _removeProfileImage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.removeProfileImage();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showInviteFriend() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              color: themeProvider.cardColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Invite Friends',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share PlantGuard AI with your friends and earn rewards!',
                    style: TextStyle(
                      color: themeProvider.secondaryTextColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your referral code: PLANT2024',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.copy, color: Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.message),
                          label: const Text('Send SMS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
      },
    );
  }

  void _showFriendCode() {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor: themeProvider.cardColor,
                title: Text(
                  'Friend Code',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: themeProvider.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code,
                            color: Colors.green,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your Friend Code',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PLANT2024',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with friends to connect',
                            style: TextStyle(
                              color: themeProvider.secondaryTextColor,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: themeProvider.textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter friend code...',
                        hintStyle: TextStyle(
                          color: themeProvider.secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: themeProvider.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: themeProvider.secondaryTextColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Friend code copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Copy Code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _payForOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment for Order #${order['id']}...'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Pay',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _trackOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking Order #${order['id']}...'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Details',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ${order['id']} is ${order['status']}'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _rateOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rate ${order['name']}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Rate',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your rating!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _viewOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing Order #${order['id']}...'),
        backgroundColor: Colors.grey,
      ),
    );
  }
}
