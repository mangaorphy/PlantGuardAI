// PlantGuardAI focused functionality tests
// Testing core providers and business logic without Firebase dependencies

import 'package:flutter_test/flutter_test.dart';
import 'package:plantguard_ai/providers/cart_provider.dart';
import 'package:plantguard_ai/providers/wishlist_provider.dart';
import 'package:plantguard_ai/providers/order_provider.dart';
import 'package:plantguard_ai/providers/image_history_provider.dart';
import 'package:plantguard_ai/providers/theme_provider.dart';

void main() {
  group('PlantGuardAI Provider Tests', () {
    test('CartProvider initializes correctly', () {
      final cartProvider = CartProvider();

      // Test initial state
      expect(cartProvider.items.length, 0);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.isEmpty, true);
      expect(cartProvider.subtotal, 0.0);
      // Note: total includes shipping fee even when cart is empty
      expect(cartProvider.total, 5000.0); // 0 + 5000 shipping + 0 tax
    });

    test('WishlistProvider initializes correctly', () {
      final wishlistProvider = WishlistProvider();

      // Test initial state
      expect(wishlistProvider.items.length, 0);
      expect(wishlistProvider.itemCount, 0);
      expect(wishlistProvider.isEmpty, true);
    });

    test('OrderProvider demo data management works', () {
      final orderProvider = OrderProvider();

      // Test initial state (should start empty due to constructor removing demos)
      expect(orderProvider.orders.length, 0);

      // Test adding demo orders
      orderProvider.initializeDemoOrders();
      expect(orderProvider.orders.length, greaterThan(0));

      // Test removing demo orders
      orderProvider.removeDemoOrders();
      expect(orderProvider.orders.length, 0);
    });

    test('ImageHistoryProvider manages image history correctly', () {
      final imageHistoryProvider = ImageHistoryProvider();

      // Test initial state
      expect(imageHistoryProvider.imageHistory.length, 0);
      expect(imageHistoryProvider.healthyImages.length, 0);
      expect(imageHistoryProvider.isLoading, false);
    });

    test('ThemeProvider initializes with default settings', () {
      final themeProvider = ThemeProvider();

      // Test initial state
      expect(themeProvider.themeMode, isNotNull);
      expect(themeProvider.lightTheme, isNotNull);
      expect(themeProvider.darkTheme, isNotNull);
    });
  });

  group('PlantGuardAI Business Logic Tests', () {
    test('Cart calculates totals correctly', () {
      final cartProvider = CartProvider();

      // Test empty cart calculations
      expect(cartProvider.subtotal, 0.0);
      expect(
        cartProvider.shipping,
        5000.0,
      ); // Shipping fee for orders under 100000
      expect(cartProvider.tax, 0.0); // 18% of 0
      expect(cartProvider.total, 5000.0); // 0 + 5000 + 0
    });

    test('Order provider handles pending payments correctly', () {
      final orderProvider = OrderProvider();

      // Initially should have no orders (static NPK removed)
      expect(orderProvider.orders.length, 0);

      // Test that pending orders filtering works
      final pendingOrders = orderProvider.pendingPaymentOrders;
      expect(pendingOrders.length, 0);
    });

    test('Image history provider filters work correctly', () {
      final imageHistoryProvider = ImageHistoryProvider();

      // Test filtering methods
      final healthyImages = imageHistoryProvider.getImagesByStatus('Healthy');
      expect(healthyImages.length, 0);

      final diseasedImages = imageHistoryProvider.getImagesByStatus(
        'Disease Detected',
      );
      expect(diseasedImages.length, 0);

      // Test convenience getter
      expect(imageHistoryProvider.healthyImages.length, 0);
    });
  });

  group('PlantGuardAI Integration Tests', () {
    test('All providers can be instantiated without errors', () {
      expect(() => CartProvider(), returnsNormally);
      expect(() => WishlistProvider(), returnsNormally);
      expect(() => OrderProvider(), returnsNormally);
      expect(() => ImageHistoryProvider(), returnsNormally);
      expect(() => ThemeProvider(), returnsNormally);
    });

    test('OrderProvider constructor removes demo data', () {
      // Create a new instance to test constructor behavior
      final orderProvider = OrderProvider();

      // Should start with no orders due to removeDemoOrders() call in constructor
      expect(orderProvider.orders.length, 0);

      // Verify that adding and removing demo data works
      orderProvider.initializeDemoOrders();
      final orderCountAfterInit = orderProvider.orders.length;
      expect(orderCountAfterInit, greaterThan(0));

      orderProvider.removeDemoOrders();
      expect(orderProvider.orders.length, 0);
    });
  });
}
