import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/screens/payment_screens/successfulpayment.dart';
import '/ui/models/product_model.dart';
import '/ui/models/cart_item_model.dart';

class PaymentScreen extends StatefulWidget {
  final ProductModel? product;
  final double? cartTotal;
  final List<CartItemModel>? cartItems;

  const PaymentScreen({
    super.key,
    this.product,
    this.cartTotal,
    this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _showUSSDInstructions = false;

  // Helper method to get the total amount
  double get totalAmount {
    if (widget.cartTotal != null) {
      return widget.cartTotal!;
    }
    return widget.product?.price ?? 15.00;
  }

  // Helper method to get the category/description
  String get paymentDescription {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      if (widget.cartItems!.length == 1) {
        return widget.cartItems!.first.product.category;
      } else {
        return '${widget.cartItems!.length} items in cart';
      }
    }
    return widget.product?.category ?? 'NPK -15';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Mobile payment',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Payment Details Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Price Amount',
                        '\$${totalAmount.toStringAsFixed(2)}',
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow('Category', paymentDescription),
                      SizedBox(height: 16),
                      _buildDetailRow('Delivery', '3 - 4 Day'),
                      SizedBox(height: 16),
                      _buildDetailRow('Seller', 'PlantGuard Store'),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Payment Method Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Momo Pay Code: 0798972441',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFCC00),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'MTN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // USSD Instructions Button
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showUSSDInstructions = !_showUSSDInstructions;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF2196F3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _showUSSDInstructions
                                    ? 'Hide USSD Steps'
                                    : 'Show USSD Payment Steps',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                _showUSSDInstructions
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // USSD Instructions (Collapsible)
                      if (_showUSSDInstructions) ...[
                        SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF4CAF50),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'MTN Mobile Money Payment Steps:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Step 1
                                  _buildUSSDStep(
                                    stepNumber: '1',
                                    instruction: 'Dial *165# on your MTN phone',
                                    actionText: '*165#',
                                    onCopy: () => _copyToClipboard('*165#'),
                                    isDialCode: true,
                                  ),

                                  // Step 2
                                  _buildUSSDStep(
                                    stepNumber: '2',
                                    instruction: 'Select option 1: Send Money',
                                    actionText: 'Press 1',
                                  ),

                                  // Step 3
                                  _buildUSSDStep(
                                    stepNumber: '3',
                                    instruction:
                                        'Enter mobile number: 0798972441',
                                    actionText: '0798972441',
                                    onCopy: () =>
                                        _copyToClipboard('0798972441'),
                                  ),

                                  // Step 4
                                  _buildUSSDStep(
                                    stepNumber: '4',
                                    instruction:
                                        'Enter amount: ${totalAmount.toStringAsFixed(0)}',
                                    actionText: totalAmount.toStringAsFixed(0),
                                    onCopy: () => _copyToClipboard(
                                      totalAmount.toStringAsFixed(0),
                                    ),
                                  ),

                                  // Step 5
                                  _buildUSSDStep(
                                    stepNumber: '5',
                                    instruction:
                                        'Enter your PIN to confirm payment',
                                    actionText: 'Enter PIN',
                                  ),

                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE8F5E8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4CAF50),
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'You will receive an SMS confirmation once payment is successful',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2E7D32),
                                            ),
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
                      ],

                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Total amount : \$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Contact Seller Button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Contact Seller',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.phone, color: Colors.black, size: 20),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Pay Now Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessfulScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Bottom Navigation
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home, 'Home'),
                      _buildNavItem(Icons.favorite_border, 'Wishlist'),
                      _buildNavItem(Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Text(value, style: TextStyle(fontSize: 18, color: Color(0xFF666666))),
      ],
    );
  }

  Widget _buildUSSDStep({
    required String stepNumber,
    required String instruction,
    required String actionText,
    VoidCallback? onCopy,
    bool isDialCode = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          // Instruction and action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDialCode
                            ? Color(0xFFE3F2FD)
                            : Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDialCode
                              ? Color(0xFF2196F3)
                              : Color(0xFF9C27B0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDialCode
                              ? Color(0xFF1976D2)
                              : Color(0xFF7B1FA2),
                        ),
                      ),
                    ),
                    if (onCopy != null)
                      GestureDetector(
                        onTap: onCopy,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF999999), size: 24),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
      ],
    );
  }
}
