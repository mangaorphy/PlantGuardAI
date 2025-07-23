import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/theme_provider.dart';
import 'models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.isEmpty) {
        cartProvider.initializeCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: themeProvider.backgroundColor,
              appBar: AppBar(
                backgroundColor: themeProvider.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Cart (${cartProvider.itemCount})',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: themeProvider.textColor,
                    ),
                    onPressed: () => _clearCart(cartProvider, themeProvider),
                  ),
                ],
              ),
              body:
                  cartProvider.isEmpty
                      ? _buildEmptyCart(themeProvider)
                      : _buildCartContent(cartProvider, themeProvider),
              bottomNavigationBar:
                  cartProvider.isEmpty
                      ? null
                      : _buildCheckoutButton(cartProvider, themeProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyCart(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              return _buildCartItem(
                cartProvider.items[index],
                cartProvider,
                themeProvider,
              );
            },
          ),
        ),
        _buildCartSummary(cartProvider, themeProvider),
      ],
    );
  }

  Widget _buildCartItem(
    CartItemModel item,
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.product.image,
                fit: BoxFit.cover,
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
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.category,
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) {
                    return Text(
                      currencyProvider.formatPriceSync(item.product.price),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed:
                        item.quantity > 1
                            ? () => cartProvider.updateQuantity(
                              item.id,
                              item.quantity - 1,
                            )
                            : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color:
                          item.quantity > 1
                              ? Colors.green
                              : themeProvider.secondaryTextColor,
                    ),
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => cartProvider.updateQuantity(
                          item.id,
                          item.quantity + 1,
                        ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => cartProvider.removeItem(item.id),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<CurrencyProvider>(
            builder: (context, currencyProvider, child) {
              return Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    currencyProvider.formatPriceSync(cartProvider.subtotal),
                    themeProvider,
                  ),
                  _buildSummaryRow(
                    'Shipping',
                    currencyProvider.formatPriceSync(cartProvider.shipping),
                    themeProvider,
                  ),
                  _buildSummaryRow(
                    'Tax',
                    currencyProvider.formatPriceSync(cartProvider.tax),
                    themeProvider,
                  ),
                  const Divider(color: Colors.green),
                  _buildSummaryRow(
                    'Total',
                    currencyProvider.formatPriceSync(cartProvider.total),
                    themeProvider,
                    isTotal: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeProvider themeProvider, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  isTotal
                      ? themeProvider.textColor
                      : themeProvider.secondaryTextColor,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.green : themeProvider.textColor,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        border: Border(top: BorderSide(color: themeProvider.borderColor)),
      ),
      child: ElevatedButton(
        onPressed: () => _proceedToCheckout(cartProvider, themeProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Consumer<CurrencyProvider>(
          builder: (context, currencyProvider, child) {
            return Text(
              'Checkout • ${currencyProvider.formatPriceSync(cartProvider.total)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  void _clearCart(CartProvider cartProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Clear Cart',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Are you sure you want to remove all items from your cart?',
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
                  cartProvider.clearCart();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _proceedToCheckout(
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Proceed to Checkout',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'This will redirect you to the checkout process.',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proceeding to checkout...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Proceed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
