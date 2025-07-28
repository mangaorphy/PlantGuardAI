// Extension to ProductListingPage for specific category navigation
// This file contains helper widgets and navigation methods for categorized product browsing

import 'package:flutter/material.dart';
import '../product_listing_page_optimized.dart';

class ProductCategoryHelper {
  // Navigate to pesticides category
  static void navigateToPesticides(
    BuildContext context, {
    String? searchQuery,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingPage(
          category: 'pesticides',
          searchQuery: searchQuery,
        ),
      ),
    );
  }

  // Navigate to fertilizers category
  static void navigateToFertilizers(
    BuildContext context, {
    String? searchQuery,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingPage(
          category: 'fertilizers',
          searchQuery: searchQuery,
        ),
      ),
    );
  }

  // Navigate to all products (pesticides and fertilizers)
  static void navigateToAllProducts(
    BuildContext context, {
    String? searchQuery,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingPage(searchQuery: searchQuery),
      ),
    );
  }

  // Create category navigation buttons
  static Widget buildCategoryButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop by Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  context,
                  'Pesticides',
                  'Protect your plants from diseases and pests',
                  Icons.bug_report,
                  () => navigateToPesticides(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryCard(
                  context,
                  'Fertilizers',
                  'Boost your plant growth and health',
                  Icons.grass,
                  () => navigateToFertilizers(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
