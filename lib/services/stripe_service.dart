import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _apiBase = 'https://api.stripe.com/v1';
  
  // TODO: Replace with your Stripe publishable key
  static const String _publishableKey = 'pk_test_51PzukK07ZQAB5YVEf02lLIHUY7Vp1KOk0OHSpHLcxanWT657PzoeeqrHZqn12VDucL4r0r7vcKtz22cB7AhkCcWj00uGuOdh8S';
  
  // This will be initialized in the main.dart file with your actual secret key
  static String _secretKey = 'sk_test_51PzukK07ZQAB5YVE06wH8Hj51ZYbNgPwSD997sGVKJQ9rSDdWqph6ZnkXJbxifxonsHsO0EhgrPZRae5nDOFU0xU00Ky2eRnSK';

  // Initialize the service with your secret key (from server environment)
  static void init(String secretKey) {
    _secretKey = secretKey;
  }

  // Create a payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    String? description,
  }) async {
    try {
      // Convert amount to cents (Stripe requires integer amount in smallest currency unit)
      final amountInCents = (amount * 100).toInt();
      
      // Create the request body
      final Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'description': description,
        // Add payment_method_types for cards
        'payment_method_types[]': 'card',
      };
      
      // Add customer if provided
      if (customerId != null) {
        body['customer'] = customerId;
      }
      
      // Make the request to create a payment intent
      final response = await http.post(
        Uri.parse('$_apiBase/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      
      // Check response
      if (response.statusCode != 200) {
        throw Exception('Error creating payment intent: ${response.body}');
      }
      
      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  // Create a customer
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      // Create the request body
      final Map<String, dynamic> body = {
        'email': email,
        'name': name,
      };
      
      // Add phone if provided
      if (phone != null) {
        body['phone'] = phone;
      }
      
      // Make the request to create a customer
      final response = await http.post(
        Uri.parse('$_apiBase/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      
      // Check response
      if (response.statusCode != 200) {
        throw Exception('Error creating customer: ${response.body}');
      }
      
      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // Add a payment method to a customer
  static Future<Map<String, dynamic>> attachPaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      // Make the request to attach payment method
      final response = await http.post(
        Uri.parse('$_apiBase/payment_methods/$paymentMethodId/attach'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
        },
      );
      
      // Check response
      if (response.statusCode != 200) {
        throw Exception('Error attaching payment method: ${response.body}');
      }
      
      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to attach payment method: $e');
    }
  }

  // Confirm a payment intent
  static Future<Map<String, dynamic>> confirmPaymentIntent({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      // Make the request to confirm payment intent
      final response = await http.post(
        Uri.parse('$_apiBase/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method': paymentMethodId,
        },
      );
      
      // Check response
      if (response.statusCode != 200) {
        throw Exception('Error confirming payment intent: ${response.body}');
      }
      
      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to confirm payment intent: $e');
    }
  }
  
  // Get the payment intent status
  static Future<Map<String, dynamic>> getPaymentIntent(String paymentIntentId) async {
    try {
      // Make the request to get payment intent
      final response = await http.get(
        Uri.parse('$_apiBase/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      );
      
      // Check response
      if (response.statusCode != 200) {
        throw Exception('Error getting payment intent: ${response.body}');
      }
      
      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get payment intent: $e');
    }
  }
}
