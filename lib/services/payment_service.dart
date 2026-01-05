import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PaymentService {
  // TODO: Replace with your actual credentials from Easypaisa
  final String _storeId = "YOUR_STORE_ID";
  final String _hashKey = "YOUR_HASH_KEY";
  final String _baseUrl =
      "https://easypay.easypaisa.com.pk/easypay/Index.jsf"; // Production
  // final String _baseUrl = "https://easypay.easypaisa.com.pk/easypay-service/rest/v4/initiate-ma-transaction"; // MA Transaction Endpoint

  /// Initiates an Easypaisa Mobile Account (MA) payment
  Future<Map<String, dynamic>> initiateEasypaisaPayment({
    required String amount,
    required String mobileNumber,
    required String email,
    required String orderId,
  }) async {
    try {
      // 1. Structure the Request
      // Note: Actual parameters depend on the specific API version (Redirect vs MA)
      // This is a standard structure for MA transaction initiation

      final DateTime now = DateTime.now();
      final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final Map<String, dynamic> payload = {
        "storeId": _storeId,
        "orderId": orderId,
        "transactionAmount": amount,
        "mobileAccountNo": mobileNumber,
        "emailAddress": email,
        "transactionType": "MA",
        "tokenExpiry": "", // Optional
        "bankIdentificationNumber": "", // Optional
      };

      debugPrint('Initiating Easypaisa Payment: $payload');

      // 2. Simulate API Call (Since we don't have live credentials)
      // In a real scenario, you would uncomment the http call below.

      /*
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: payload,
        // headers: {'Content-Type': 'application/x-www-form-urlencoded'}, // or json
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to initiate payment: ${response.statusCode}');
      }
      */

      // -- SIMULATION BLOCK START --
      // Simulating a network call and successful response
      await Future.delayed(const Duration(seconds: 3));

      // Validate mobile number format for simulation
      if (mobileNumber.length < 11) {
        throw Exception('Invalid Mobile Number');
      }

      return {
        "responseCode": "0000",
        "responseMessage": "Success",
        "transactionId": "TXN_${DateTime.now().millisecondsSinceEpoch}",
      };
      // -- SIMULATION BLOCK END --
    } catch (e) {
      debugPrint('Payment Exception: $e');
      rethrow;
    }
  }

  String generateOrderId() {
    return "ORD-${DateTime.now().millisecondsSinceEpoch}";
  }
}
