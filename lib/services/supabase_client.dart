import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Create a client that can be accessed by other services
  static late final SupabaseClient client;
  static bool _isInitialized = false;
  static const String _supabaseUrl = 'https://mavaujxjkzyuhphpgtue.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdmF1anhqa3p5dWhwaHBndHVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mjc3NTIsImV4cCI6MjA2NTIwMzc1Mn0.gT90RdhPzgFQ7jfY6T0yB-Cb2ccpSTxUPfHoAyob2L4';
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check connection to Supabase before initializing
      final connectionStatus = await checkConnection();
      if (!connectionStatus.isConnected) {
        throw Exception('Cannot connect to Supabase: ${connectionStatus.message}');
      }
      
      // Initialize Supabase with real credentials
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
        debug: kDebugMode,
      );
      
      // Get the client instance
      client = Supabase.instance.client;
      _isInitialized = true;
      
      print('Supabase initialized successfully');
    } catch (e) {
      print('Supabase initialization error: $e');
      rethrow;
    }
  }
  
  // Check if we can connect to Supabase
  static Future<ConnectionStatus> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_supabaseUrl/rest/v1/?apikey=$_supabaseAnonKey'),
        headers: {
          'apikey': _supabaseAnonKey,
          'Authorization': 'Bearer $_supabaseAnonKey',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ConnectionStatus(isConnected: true, message: 'Connected to Supabase');
      } else {
        return ConnectionStatus(
          isConnected: false, 
          message: 'Failed to connect to Supabase. Status: ${response.statusCode}'
        );
      }
    } on TimeoutException {
      return ConnectionStatus(
        isConnected: false, 
        message: 'Connection timeout. Check your internet connection.'
      );
    } catch (e) {
      return ConnectionStatus(
        isConnected: false, 
        message: 'Connection error: ${e.toString()}'
      );
    }
  }
  
  // Reset client for retry
  static Future<void> reset() async {
    _isInitialized = false;
    await initialize();
  }
}

class ConnectionStatus {
  final bool isConnected;
  final String message;
  
  ConnectionStatus({required this.isConnected, required this.message});
}
