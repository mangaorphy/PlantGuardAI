import 'package:flutter/foundation.dart';
import 'package:currency_converter_pro/currency_converter_pro.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrency = 'RWF';
  bool _isLoading = false;
  String? _errorMessage;

  final CurrencyConverterPro _currencyConverter = CurrencyConverterPro();

  String get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Currency symbols mapping
  final Map<String, String> _currencySymbols = {
    'RWF': 'RWF',
    'USD': '\$',
    'EUR': '€',
    'KES': 'KSh',
    'UGX': 'USh',
  };

  // Cache for exchange rates to avoid frequent API calls
  final Map<String, double> _cachedExchangeRates = {};
  DateTime? _lastUpdated;

  void updateCurrency(String currency) {
    _selectedCurrency = currency;
    _errorMessage = null;
    // Clear cached rates for the new currency to force fresh conversion
    _cachedExchangeRates.clear();
    _lastUpdated = null;
    notifyListeners();
  }

  // Format price based on selected currency with real-time conversion
  Future<String> formatPrice(double priceInRWF) async {
    if (_selectedCurrency == 'RWF') {
      return 'RWF ${priceInRWF.toStringAsFixed(0)}';
    }

    try {
      // Check if we have cached rates that are less than 1 hour old
      if (_lastUpdated != null &&
          DateTime.now().difference(_lastUpdated!).inHours < 1 &&
          _cachedExchangeRates.containsKey(_selectedCurrency)) {
        final convertedPrice =
            priceInRWF * _cachedExchangeRates[_selectedCurrency]!;
        return _formatCurrencyDisplay(convertedPrice, _selectedCurrency);
      }

      // Use real-time conversion
      final convertedPrice = await _currencyConverter.convertCurrency(
        amount: priceInRWF,
        fromCurrency: 'rwf', // Package uses lowercase
        toCurrency: _selectedCurrency.toLowerCase(),
      );

      // Cache the exchange rate
      _cachedExchangeRates[_selectedCurrency] = convertedPrice / priceInRWF;
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      return _formatCurrencyDisplay(convertedPrice, _selectedCurrency);
    } catch (e) {
      // Fall back to hardcoded rates if API fails
      _errorMessage = 'Using offline rates';
      final fallbackRates = {
        'USD': 0.00082,
        'EUR': 0.00075,
        'KES': 0.11,
        'UGX': 3.0,
      };

      final rate = fallbackRates[_selectedCurrency] ?? 1.0;
      final convertedPrice = priceInRWF * rate;
      return _formatCurrencyDisplay(convertedPrice, _selectedCurrency);
    }
  }

  // Synchronous version for immediate display with cached rates
  String formatPriceSync(double priceInRWF) {
    if (_selectedCurrency == 'RWF') {
      return 'RWF ${priceInRWF.toStringAsFixed(0)}';
    }

    // Use cached rate if available
    if (_cachedExchangeRates.containsKey(_selectedCurrency)) {
      final convertedPrice =
          priceInRWF * _cachedExchangeRates[_selectedCurrency]!;
      return _formatCurrencyDisplay(convertedPrice, _selectedCurrency);
    }

    // Fall back to hardcoded rates for immediate display
    final fallbackRates = {
      'USD': 0.00082,
      'EUR': 0.00075,
      'KES': 0.11,
      'UGX': 3.0,
    };

    final rate = fallbackRates[_selectedCurrency] ?? 1.0;
    final convertedPrice = priceInRWF * rate;
    return _formatCurrencyDisplay(convertedPrice, _selectedCurrency);
  }

  // Format currency display based on currency type
  String _formatCurrencyDisplay(double amount, String currency) {
    String symbol = _currencySymbols[currency] ?? currency;

    switch (currency) {
      case 'RWF':
        return '$symbol ${amount.toStringAsFixed(0)}';
      case 'USD':
      case 'EUR':
        return '$symbol${amount.toStringAsFixed(2)}';
      case 'KES':
      case 'UGX':
        return '$symbol ${amount.toStringAsFixed(0)}';
      default:
        return '$symbol ${amount.toStringAsFixed(2)}';
    }
  }

  // Get currency symbol
  String getCurrencySymbol() {
    return _currencySymbols[_selectedCurrency] ?? _selectedCurrency;
  }

  // Update exchange rates manually
  Future<void> updateExchangeRates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Test conversion to update rates
      await _currencyConverter.convertCurrency(
        amount: 1000.0,
        fromCurrency: 'rwf',
        toCurrency: _selectedCurrency.toLowerCase(),
      );

      _lastUpdated = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update rates: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if rates are fresh (less than 1 hour old)
  bool get areRatesFresh {
    return _lastUpdated != null &&
        DateTime.now().difference(_lastUpdated!).inHours < 1;
  }

  // Clear cached rates
  Future<void> clearCache() async {
    _cachedExchangeRates.clear();
    _lastUpdated = null;
    notifyListeners();
  }
}
