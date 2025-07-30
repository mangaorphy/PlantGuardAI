import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/payment_screens/successfulpayment.dart';
import '/ui/models/product_model.dart';
import '/ui/models/cart_item_model.dart';
import '/providers/currency_provider.dart';
import '/services/mtn_momo_service.dart';
import '/providers/theme_provider.dart';

import '/wishlist_page.dart';
import '/screens/profile/profile_page.dart';
import '/screens/home_page.dart';

class RwandaPaymentScreen extends StatefulWidget {
  final ProductModel? product;
  final List<CartItemModel>? cartItems;
  final double? cartTotal;

  const RwandaPaymentScreen({
    super.key,
    this.product,
    this.cartItems,
    this.cartTotal,
  });

  @override
  State<RwandaPaymentScreen> createState() => _RwandaPaymentScreenState();
}

class _RwandaPaymentScreenState extends State<RwandaPaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final MTNMoMoService _momoService = MTNMoMoService();
  bool _isPhoneEntered = false;
  bool _isProcessingPayment = false;
  String _userPhoneNumber = '';
  String? _transactionId;
  String? _paymentMessage;
  final int _currentIndex = 0;

  // Helper method to get the total amount
  double get totalAmount {
    if (widget.cartTotal != null) {
      return widget.cartTotal!;
    }
    return widget.product?.price ?? 0.0;
  }

  // Helper method to get the product name/description
  String get paymentDescription {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      if (widget.cartItems!.length == 1) {
        return widget.cartItems!.first.product.name;
      } else {
        return 'Cart Order (${widget.cartItems!.length} items)';
      }
    }
    return widget.product?.name ?? 'Unknown Product';
  }

  // Helper method to get category description
  String get categoryDescription {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      if (widget.cartItems!.length == 1) {
        return widget.cartItems!.first.product.category;
      } else {
        return '${widget.cartItems!.length} items in cart';
      }
    }
    return widget.product?.category ?? 'Product';
  }

  // Helper method to get the first image for display
  String get displayImage {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      return widget.cartItems!.first.product.image;
    }
    return widget.product?.image ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhoneNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && _isValidPhoneNumber(phone)) {
      setState(() {
        _userPhoneNumber = phone;
        _isProcessingPayment = true;
        _paymentMessage = null;
      });

      try {
        // Get currency provider to get price in RWF
        final currencyProvider = Provider.of<CurrencyProvider>(
          context,
          listen: false,
        );

        // Convert price to RWF if it's in a different currency
        double priceInRWF = totalAmount;

        // If the selected currency is not RWF, we need to convert back to RWF for the API
        if (currencyProvider.selectedCurrency != 'RWF') {
          // Convert back to RWF (reverse the conversion)
          double rate = currencyProvider.getCurrentRate(
            currencyProvider.selectedCurrency,
          );
          priceInRWF = totalAmount / rate;
        }

        // Call MTN MoMo API
        final paymentResult = await _momoService.requestPayment(
          customerPhoneNumber: phone,
          amount: priceInRWF,
          currency: 'RWF',
          productName: paymentDescription,
        );

        setState(() {
          _isProcessingPayment = false;
          _paymentMessage = paymentResult['message'];
          _transactionId = paymentResult['transactionId'];
        });

        if (paymentResult['status'] == 'success') {
          setState(() {
            _isPhoneEntered = true;
          });
          _showPaymentRequestDialog();
        } else {
          // Show error message
          _showErrorDialog(
            paymentResult['message'] ?? 'Payment request failed',
          );
        }
      } catch (e) {
        setState(() {
          _isProcessingPayment = false;
          _paymentMessage = 'An error occurred. Please try again.';
        });
        _showErrorDialog('An error occurred. Please try again.');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid MTN phone number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCategory(String category) {
    // Capitalize first letter of each word and make it more readable
    return category
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  bool _isValidPhoneNumber(String phone) {
    // Rwanda MTN numbers start with 078 or 079
    return phone.length >= 9 &&
        (phone.startsWith('078') || phone.startsWith('079'));
  }

  void _editPhoneNumber() {
    setState(() {
      _isPhoneEntered = false;
    });
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Payment Error'),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentRequestDialog() {
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.phone_android, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Payment Request Sent!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Information
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      paymentDescription,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: currencyProvider.formatPrice(totalAmount),
                      builder: (context, snapshot) {
                        return Text(
                          'Amount: ${snapshot.data ?? currencyProvider.formatPriceSync(totalAmount)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Transaction ID (if available)
              if (_transactionId != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Transaction ID:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _transactionId!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1976D2),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16),
              Text(
                'Mobile Money payment request sent to:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                _userPhoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFF9800)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.phone_android,
                      color: Color(0xFFFF9800),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '📱 Check Your Phone Now!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You should receive an MTN Mobile Money notification. Enter your PIN to complete the payment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFFBF360C)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Payment message from API
              if (_paymentMessage != null)
                Text(
                  _paymentMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK, I understand',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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

                // Product Preview Section
                if (widget.product != null ||
                    (widget.cartItems != null && widget.cartItems!.isNotEmpty))
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              displayImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                paymentDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              FutureBuilder<String>(
                                future: currencyProvider.formatPrice(
                                  totalAmount,
                                ),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ??
                                        currencyProvider.formatPriceSync(
                                          totalAmount,
                                        ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  );
                                },
                              ),
                            ],
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
                      // Product Name
                      _buildDetailRow('Product', paymentDescription),
                      SizedBox(height: 16),
                      FutureBuilder<String>(
                        future: currencyProvider.formatPrice(totalAmount),
                        builder: (context, snapshot) {
                          return _buildDetailRow(
                            'Price Amount',
                            snapshot.data ??
                                currencyProvider.formatPriceSync(totalAmount),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        'Category',
                        _formatCategory(categoryDescription),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        'Rating',
                        widget.cartItems != null && widget.cartItems!.isNotEmpty
                            ? widget.cartItems!.length == 1
                                  ? '${widget.cartItems!.first.product.rating.toStringAsFixed(1)} ⭐'
                                  : 'Mixed ratings'
                            : '${widget.product?.rating.toStringAsFixed(1) ?? '0.0'} ⭐',
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow('Delivery', '3 - 4 Days'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with MTN badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mobile Money Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
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

                      SizedBox(height: 20),

                      // Phone Number Input Section
                      if (!_isPhoneEntered) ...[
                        Text(
                          'Enter your MTN Mobile Money number:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '0789726360',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFF4CAF50),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Only MTN numbers (078xxxxxxx or 079xxxxxxx) are supported',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessingPayment
                                ? null
                                : _submitPhoneNumber,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isProcessingPayment
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Processing Payment...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Send Payment Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],

                      // Payment Instructions Section
                      if (_isPhoneEntered) ...[
                        // Confirmed phone number
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment request sent to:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      _userPhoneNumber,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _editPhoneNumber,
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Payment Instructions
                        Container(
                          padding: EdgeInsets.all(16),
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
                                    color: Color(0xFF2196F3),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Complete payment on your phone:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              _buildPaymentStep(
                                stepNumber: '1',
                                instruction:
                                    'Check your phone for an MTN Mobile Money payment request',
                                icon: Icons.phone_android,
                              ),

                              _buildPaymentStep(
                                stepNumber: '2',
                                instruction:
                                    'Confirm the amount shown on your phone',
                                icon: Icons.payments,
                              ),

                              _buildPaymentStep(
                                stepNumber: '3',
                                instruction:
                                    'Enter your PIN to confirm the payment',
                                icon: Icons.lock,
                              ),

                              _buildPaymentStep(
                                stepNumber: '4',
                                instruction:
                                    'You will receive an SMS confirmation once payment is complete',
                                icon: Icons.message,
                              ),

                              SizedBox(height: 8),

                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFF4CAF50),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: Color(0xFF2E7D32),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Payment will be sent to PlantGuard Store\'s verified merchant account',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Color(0xFF1976D2),
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'This payment request will expire in 5 minutes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          child: FutureBuilder<String>(
                            future: currencyProvider.formatPrice(totalAmount),
                            builder: (context, snapshot) {
                              return Text(
                                'Total amount : ${snapshot.data ?? currencyProvider.formatPriceSync(totalAmount)}',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              );
                            },
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

                // Pay Now Button (only show if payment is complete)
                if (_isPhoneEntered)
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
                          'Payment Completed',
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
              ],
            ),
          ),
        ),
      ),
      // Move bottomNavigationBar here
      bottomNavigationBar: _buildBottomNavigationBar(
        Provider.of<ThemeProvider>(context),
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

  Widget _buildPaymentStep({
    required String stepNumber,
    required String instruction,
    required IconData icon,
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

          // Icon
          Icon(icon, color: Color(0xFF4CAF50), size: 20),
          SizedBox(width: 12),

          // Instruction
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
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
}
