import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();
  
  // Static variables to store environment values as fallback for web
  static String _stripePublishableKey = 'pk_test_51PzukK07ZQAB5YVEf02lLIHUY7Vp1KOk0OHSpHLcxanWT657PzoeeqrHZqn12VDucL4r0r7vcKtz22cB7AhkCcWj00uGuOdh8S';
  static String _stripeSecretKey = ''; // Don't include secret key in web builds
  static String _clickpesaClientId = 'IDlbaXUTdf5NN9sf3lZicLgReu2YfxBs';
  static String _clickpesaApiKey = 'SKkYuA3NB3CkKDwgqXZd1zZdFdTSwQf1EidlrgdA0H';
  static String _clickpesaSecretKey = 'SK_5e6e9e7e-e378-4d4e-bb41-cf3132a67041';
  static bool _isInitialized = false;
  
  // Initialize and load environment variables
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // For web platforms, we'll rely on embedded constants to avoid .env file issues
      if (!kIsWeb) {
        await dotenv.load(fileName: '.env').then((_) {
          _stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? _stripePublishableKey;
          _stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? _stripeSecretKey;
          _clickpesaClientId = dotenv.env['CLICKPESA_CLIENT_ID'] ?? _clickpesaClientId;
          _clickpesaApiKey = dotenv.env['CLICKPESA_API_KEY'] ?? _clickpesaApiKey;
          _clickpesaSecretKey = dotenv.env['CLICKPESA_SECRET_KEY'] ?? _clickpesaSecretKey;
        });
      }
      
      _isInitialized = true;
      debugPrint('Environment configuration initialized successfully');
    } catch (e) {
      debugPrint('Failed to load environment variables: $e');
      // Continue with default values
      _isInitialized = true;
    }
  }

  // Stripe API Keys
  static String get stripePublishableKey => _stripePublishableKey;
  
  static String get stripeSecretKey => _stripeSecretKey;
      
  // ClickPesa API Keys
  static String get clickpesaClientId => _clickpesaClientId;
      
  static String get clickpesaApiKey => _clickpesaApiKey;
      
  // ClickPesa Secret Key for checksum generation
  static String get clickpesaSecretKey => _clickpesaSecretKey;
}
