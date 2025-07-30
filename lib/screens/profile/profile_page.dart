import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../ui/models/order_model.dart';
import '../../wishlist_page.dart';
import '/screens/home_page.dart';
import 'edit_profile_page.dart';
import 'enhanced_settings_page.dart';
import '../../cart_page.dart';
import '../../image_history_page.dart';
import 'customer_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Initialize user data if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.initializeUser();
      }

      // Ensure no demo orders are showing - remove any static data
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.removeDemoOrders(); // Remove any demo orders
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
          // Removed language selector
          SizedBox(width: 1), // Placeholder to maintain layout
          Row(
            children: [
              // Removed QR Scanner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnhancedSettingsPage(),
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
                        child: userProvider.profileImageFile != null
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
                'Shipping',
                onTap: () => _showOrderStatus('Shipping'),
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
          _buildMenuItem(Icons.headset_mic, 'Customer Center', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerCenterPage(),
              ),
            );
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
                        final isCartItem = order['id'].toString().startsWith(
                          'CART_',
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeProvider.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Product Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: order['image'] != null
                                          ? Image.network(
                                              order['image'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.local_pharmacy,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.local_pharmacy,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          '${isCartItem ? 'Cart Item' : 'Order'} #${order['id']}',
                                          style: TextStyle(
                                            color: themeProvider
                                                .secondaryTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Consumer<CurrencyProvider>(
                                          builder:
                                              (
                                                context,
                                                currencyProvider,
                                                child,
                                              ) {
                                                return Text(
                                                  currencyProvider
                                                      .formatPriceSync(
                                                        order['price']
                                                            .toDouble(),
                                                      ),
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                        ),
                                        // Show quantity for cart items
                                        if (isCartItem &&
                                            order['quantity'] != null)
                                          Text(
                                            'Qty: ${order['quantity']}',
                                            style: TextStyle(
                                              color: themeProvider
                                                  .secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        order['status'],
                                        style: TextStyle(
                                          color: _getStatusColor(
                                            order['status'],
                                          ),
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
                              // Show additional info for paid orders
                              if (order['paidAt'] != null ||
                                  order['paymentId'] != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.payment,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (order['paymentId'] != null)
                                              Text(
                                                'Payment ID: ${order['paymentId']}',
                                                style: TextStyle(
                                                  color:
                                                      themeProvider.textColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            if (order['paidAt'] != null)
                                              Text(
                                                'Paid: ${_formatDate(order['paidAt'])}',
                                                style: TextStyle(
                                                  color: themeProvider
                                                      .secondaryTextColor,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    switch (statusType) {
      case 'Pending Payment':
        // Show items in cart that need payment
        final cartOrders = cartProvider.items
            .map(
              (cartItem) => {
                'id': 'CART_${cartItem.id}',
                'name': cartItem.product.name,
                'price': cartItem.totalPrice,
                'status': 'Payment Due',
                'quantity': cartItem.quantity,
                'image': cartItem.product.image,
                'category': cartItem.product.category,
              },
            )
            .toList();

        // Also include actual pending payment orders
        final pendingOrders = orderProvider.pendingPaymentOrders
            .map(
              (order) => {
                'id': order.id,
                'name': order.items.length == 1
                    ? order.items.first.productName
                    : '${order.items.length} items',
                'price': order.totalAmount,
                'status': order.status.displayName,
                'orderDate': order.orderDate,
                'items': order.items,
              },
            )
            .toList();

        return {
          'icon': Icons.access_time,
          'orders': [...cartOrders, ...pendingOrders],
        };

      case 'To Ship':
        final toShipOrders = orderProvider.toShipOrders
            .map(
              (order) => {
                'id': order.id,
                'name': order.items.length == 1
                    ? order.items.first.productName
                    : '${order.items.length} items',
                'price': order.totalAmount,
                'status': order.status.displayName,
                'paidAt': order.paidAt,
                'paymentId': order.paymentId,
                'items': order.items,
              },
            )
            .toList();

        return {'icon': Icons.inventory_2, 'orders': toShipOrders};

      case 'Shipping':
        final shippingOrders = orderProvider.shippingOrders
            .map(
              (order) => {
                'id': order.id,
                'name': order.items.length == 1
                    ? order.items.first.productName
                    : '${order.items.length} items',
                'price': order.totalAmount,
                'status': order.status.displayName,
                'shippedAt': order.shippedAt,
                'items': order.items,
              },
            )
            .toList();

        return {'icon': Icons.local_shipping, 'orders': shippingOrders};

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
      case 'Paid':
        return Colors.blue;
      case 'In Transit':
      case 'Out for Delivery':
      case 'Shipped':
        return Colors.green;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
    final isCartItem = order['id'].toString().startsWith('CART_');

    switch (statusType) {
      case 'Pending Payment':
        if (isCartItem) {
          buttonText = 'Checkout';
          buttonColor = Colors.orange;
          onPressed = () => _proceedToCartCheckout();
        } else {
          buttonText = 'Pay Now';
          buttonColor = Colors.orange;
          onPressed = () => _payForOrder(order);
        }
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

  void _proceedToCartCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
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
