import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://mavaujxjkzyuhphpgtue.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdmF1anhqa3p5dWhwaHBndHVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mjc3NTIsImV4cCI6MjA2NTIwMzc1Mn0.gT90RdhPzgFQ7jfY6T0yB-Cb2ccpSTxUPfHoAyob2L4';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
