import 'dart:math';

/// MTN Mobile Money Service for Rwanda
///
/// This service integrates with MTN Rwanda's Mobile Money API to process payments.
/// Currently configured for simulation/testing mode.
///
/// TO ENABLE REAL PAYMENTS:
/// 1. Register with MTN Rwanda Developer Portal: https://momodeveloper.mtn.com
/// 2. Get your API credentials (Subscription Key, API User, API Key)
/// 3. Replace the commented API calls with real HTTP requests
/// 4. Update the base URL to production: https://api.mtnrwanda.com
/// 5. Add proper error handling and retry logic
///
/// MERCHANT ACCOUNT: 0798972441 (PlantGuard Store)
/// All payments will be directed to this account.
class MTNMoMoService {
  // MTN MoMo API Configuration for Rwanda
  // static const String _baseUrl = 'https://sandbox-api.mtnrwanda.com'; // Use sandbox for testing
  // static const String _subscriptionKey = 'YOUR_SUBSCRIPTION_KEY'; // Replace with your subscription key
  // static const String _merchantId = 'YOUR_MERCHANT_ID'; // Replace with your merchant ID
  static const String _merchantAccount =
      '0798972441'; // The account where money should land

  // For production, change to: https://api.mtnrwanda.com
  // Note: You'll need to register with MTN Rwanda to get actual API credentials

  /// Generate a unique external ID for each transaction
  String _generateExternalId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'PG_${timestamp}_$randomNum';
  }

  /// Generate a unique request ID for each API call (for production use)
  /*
  String _generateRequestId() {
    final random = Random();
    final chars = 'abcdef0123456789';
    return List.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) {
        return '-';
      }
      return chars[random.nextInt(chars.length)];
    }).join();
  }
  */

  /// Simulate MTN MoMo API call for development/testing
  Future<Map<String, dynamic>> _simulatePaymentRequest({
    required String customerPhoneNumber,
    required double amount,
    required String currency,
    required String externalId,
    required String payeeNote,
    required String payerMessage,
  }) async {
    // Simulate API processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different response scenarios
    final random = Random();
    final success = random.nextDouble() > 0.1; // 90% success rate for testing

    if (success) {
      return {
        'status': 'success',
        'transactionId': _generateExternalId(),
        'externalId': externalId,
        'amount': amount.toString(),
        'currency': currency,
        'payer': {'partyIdType': 'MSISDN', 'partyId': customerPhoneNumber},
        'payee': {'partyIdType': 'MSISDN', 'partyId': _merchantAccount},
        'status_reason': 'Payment request sent successfully',
        'message':
            'Please check your phone for the payment request and enter your PIN to complete the transaction.',
      };
    } else {
      return {
        'status': 'failed',
        'error': 'PAYMENT_REQUEST_FAILED',
        'message': 'Failed to send payment request. Please try again.',
      };
    }
  }

  /// Send a payment request to customer's phone
  /// This would integrate with actual MTN MoMo API in production
  Future<Map<String, dynamic>> requestPayment({
    required String customerPhoneNumber,
    required double amount,
    required String currency,
    required String productName,
  }) async {
    try {
      // Clean phone number (remove any spaces, dashes, etc.)
      final cleanPhoneNumber = customerPhoneNumber.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      // Validate phone number
      if (!_isValidMTNNumber(cleanPhoneNumber)) {
        return {
          'status': 'failed',
          'error': 'INVALID_PHONE_NUMBER',
          'message':
              'Please enter a valid MTN phone number (078xxxxxxx or 079xxxxxxx)',
        };
      }

      // Generate unique transaction ID
      final externalId = _generateExternalId();

      // For now, use simulation - replace this with actual API call in production
      final response = await _simulatePaymentRequest(
        customerPhoneNumber: cleanPhoneNumber,
        amount: amount,
        currency: currency,
        externalId: externalId,
        payeeNote: 'Payment for $productName from PlantGuard AI',
        payerMessage: 'Complete your purchase of $productName',
      );

      return response;

      /* 
      // This is how you would implement the actual MTN MoMo API call:
      
      final headers = {
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        'X-Reference-Id': requestId,
        'X-Target-Environment': 'sandbox', // Change to 'production' for live
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
        'Content-Type': 'application/json',
      };
      
      final body = {
        'amount': formattedAmount,
        'currency': currency,
        'externalId': externalId,
        'payer': {
          'partyIdType': 'MSISDN',
          'partyId': cleanPhoneNumber,
        },
        'payerMessage': 'Complete your purchase of $productName',
        'payeeNote': 'Payment for $productName from PlantGuard AI',
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/collection/v1_0/requesttopay'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 202) {
        // Payment request accepted
        return {
          'status': 'success',
          'transactionId': requestId,
          'externalId': externalId,
          'message': 'Payment request sent successfully. Please check your phone.',
        };
      } else {
        // Handle error
        final errorData = jsonDecode(response.body);
        return {
          'status': 'failed',
          'error': errorData['code'] ?? 'UNKNOWN_ERROR',
          'message': errorData['message'] ?? 'Payment request failed',
        };
      }
      */
    } catch (e) {
      return {
        'status': 'failed',
        'error': 'NETWORK_ERROR',
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }

  /// Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(
    String transactionId,
  ) async {
    try {
      // For simulation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final random = Random();
      final statuses = ['PENDING', 'SUCCESSFUL', 'FAILED'];
      final status = statuses[random.nextInt(statuses.length)];

      return {
        'status': status,
        'transactionId': transactionId,
        'message': _getStatusMessage(status),
      };

      /*
      // Actual API implementation would be:
      final headers = {
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        'X-Target-Environment': 'sandbox',
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      };
      
      final response = await http.get(
        Uri.parse('$_baseUrl/collection/v1_0/requesttopay/$transactionId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': data['status'],
          'transactionId': transactionId,
          'amount': data['amount'],
          'currency': data['currency'],
          'message': _getStatusMessage(data['status']),
        };
      } else {
        return {
          'status': 'FAILED',
          'message': 'Unable to check transaction status',
        };
      }
      */
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Error checking transaction status',
      };
    }
  }

  /// Validate MTN Rwanda phone numbers
  bool _isValidMTNNumber(String phoneNumber) {
    // Remove any leading zeros or country codes
    String cleanNumber = phoneNumber;
    if (cleanNumber.startsWith('250')) {
      cleanNumber = cleanNumber.substring(3);
    }
    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // MTN Rwanda numbers start with 78 or 79
    return cleanNumber.length == 9 &&
        (cleanNumber.startsWith('78') || cleanNumber.startsWith('79'));
  }

  /// Get user-friendly status messages
  String _getStatusMessage(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Payment is being processed. Please complete the transaction on your phone.';
      case 'SUCCESSFUL':
        return 'Payment completed successfully!';
      case 'FAILED':
        return 'Payment failed. Please try again.';
      case 'CANCELLED':
        return 'Payment was cancelled.';
      case 'TIMEOUT':
        return 'Payment request timed out. Please try again.';
      default:
        return 'Unknown payment status.';
    }
  }
}
