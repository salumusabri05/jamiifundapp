import 'dart:async';
import 'dart:io';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignService {
  static const String _tableName = 'campaigns';
  static const int _maxRetries = 3;
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Helper method to retry operations
  static Future<T> _withRetry<T>(Future<T> Function() operation, {int maxRetries = _maxRetries}) async {
    int attempts = 0;
    
    while (true) {
      try {
        attempts++;
        
        // Before each attempt, check connection
        if (attempts > 1) {
          final connectionStatus = await SupabaseService.checkConnection();
          if (!connectionStatus.isConnected) {
            print('Connection check failed: ${connectionStatus.message}. Attempt $attempts of $maxRetries');
            if (attempts >= maxRetries) {
              throw Exception('Network error: ${connectionStatus.message}. Please check your internet connection and try again.');
            }
            // Wait a moment before retrying
            await Future.delayed(Duration(seconds: attempts));
            continue;
          }
        }
        
        // Try the operation
        return await operation();
      } on TimeoutException {
        print('Operation timed out. Attempt $attempts of $maxRetries');
        if (attempts >= maxRetries) {
          throw Exception('Operation timed out. Please try again later.');
        }
      } catch (e) {
        print('Error during operation: $e. Attempt $attempts of $maxRetries');
        if (attempts >= maxRetries) {
          throw Exception('Failed after $maxRetries attempts: ${e.toString()}');
        }
        // If Supabase client error, try to reset it
        if (e is PostgrestException || e is SocketException || e.toString().contains('ClientException')) {
          try {
            await SupabaseService.reset();
          } catch (_) {
            // Ignore reset errors, just continue with retry
          }
        }
      }
      
      // Wait between retries with increasing duration
      await Future.delayed(Duration(seconds: attempts));
    }
  }

  // Create a new campaign
  static Future<Campaign> createCampaign(Campaign campaign) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .insert(campaign.toMap())
          .select()
          .single();
      
      return Campaign.fromMap(response);
    });
  }

  // Get featured campaigns
  static Future<List<Campaign>> getFeaturedCampaigns() async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    });
  }
  
  // Get all campaigns
  static Future<List<Campaign>> getAllCampaigns() async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    });
  }
  
  // Get campaigns by category
  static Future<List<Campaign>> getCampaignsByCategory(String category) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    });
  }
  
  // Get campaigns by user
  static Future<List<Campaign>> getCampaignsByUser(String userId) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    });
  }
  
  // Get campaign by ID
  static Future<Campaign> getCampaignById(String id) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return Campaign.fromMap(response);
    }, maxRetries: 2);
  }
  
  // Get campaign details by ID as a map
  static Future<Map<String, dynamic>> getCampaignDetailsById(String id) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return response;
    }, maxRetries: 2);
  }
  
  // Update campaign
  static Future<Campaign> updateCampaign(Campaign campaign) async {
    return _withRetry(() async {
      final response = await _client
          .from(_tableName)
          .update(campaign.toMap())
          .eq('id', campaign.id)
          .select()
          .single();
      
      return Campaign.fromMap(response);
    });
  }
  
  // Update campaign donation
  static Future<Campaign> updateCampaignDonation(
      String campaignId, int amount, bool incrementDonorCount) async {
    return _withRetry(() async {
      // Get current campaign data
      final currentData = await getCampaignById(campaignId);
      
      // Calculate new values
      final newAmount = currentData.currentAmount + amount;
      final newDonorCount = incrementDonorCount 
          ? currentData.donorCount + 1 
          : currentData.donorCount;
      
      // Update campaign
      final response = await _client
          .from(_tableName)
          .update({
            'current_amount': newAmount,
            'donor_count': newDonorCount,
          })
          .eq('id', campaignId)
          .select()
          .single();
      
      return Campaign.fromMap(response);
    });
  }

  // Delete campaign
  static Future<void> deleteCampaign(String id) async {
    return _withRetry(() async {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id);
    });
  }

  // Search campaigns by title or description
  static Future<List<Campaign>> searchCampaigns(String query) async {
    return _withRetry(() async {
      if (query.isEmpty) {
        return await getAllCampaigns();
      }
      
      final response = await _client
          .from(_tableName)
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    });
  }
}
