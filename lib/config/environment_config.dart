import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();
  
  // Initialize and load environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  // Stripe API Keys
  static String get stripePublishableKey => 
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  
  static String get stripeSecretKey => 
      dotenv.env['STRIPE_SECRET_KEY'] ?? '';
      
  // ClickPesa API Keys
  static String get clickpesaClientId =>
      dotenv.env['CLICKPESA_CLIENT_ID'] ?? '';
      
  static String get clickpesaApiKey =>
      dotenv.env['CLICKPESA_API_KEY'] ?? '';
}
