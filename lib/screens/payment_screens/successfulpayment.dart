import 'package:flutter/material.dart';

class SuccessfulScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'How to use the product',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            size: 80,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Success Message
                      Text(
                        'On All Orders Over Rs.5000.00',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Success Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.0),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Payment Success !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    );
  }
  
  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFF999999),
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
