import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignService {
  static const String _tableName = 'campaigns';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Create a new campaign
  static Future<Campaign> createCampaign(Campaign campaign) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(campaign.toMap())
          .select()
          .single();
      
      return Campaign.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get all campaigns
  static Future<List<Campaign>> getAllCampaigns() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get featured campaigns
  static Future<List<Campaign>> getFeaturedCampaigns() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      final campaigns = (response as List).map((item) => Campaign.fromMap(item)).toList();
      
      // If no featured campaigns, return mock data
      if (campaigns.isEmpty) {
        return _getMockCampaigns();
      }
      
      return campaigns;
    } catch (e) {
      print('Error fetching featured campaigns: $e');
      // Return mock data on error
      return _getMockCampaigns();
    }
  }
  
  // Get mock campaigns for testing
  static List<Campaign> _getMockCampaigns() {
    return [
      Campaign(
        id: '1',
        title: 'Help Build a School in Rural Tanzania',
        description: 'We aim to build a primary school in Mwanza region to support 300 children.',
        category: 'Education',
        goalAmount: 15000000,
        currentAmount: 7500000,
        endDate: DateTime.now().add(const Duration(days: 45)),
        imageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
        isFeatured: true,
        donorCount: 32,
      ),
      Campaign(
        id: '2',
        title: 'Clean Water for Arusha Village',
        description: 'Help us bring clean water to over 500 families in Arusha.',
        category: 'Water',
        goalAmount: 8000000,
        currentAmount: 5600000,
        endDate: DateTime.now().add(const Duration(days: 30)),
        imageUrl: 'https://images.unsplash.com/photo-1594398901394-4e34939a4fd0',
        isFeatured: true,
        donorCount: 48,
      ),
      Campaign(
        id: '3',
        title: 'Medical Supplies for Rural Clinic',
        description: 'Support our efforts to provide essential medical supplies to rural health centers in Tanzania.',
        category: 'Health',
        goalAmount: 12000000,
        currentAmount: 3400000,
        endDate: DateTime.now().add(const Duration(days: 60)),
        imageUrl: 'https://images.unsplash.com/photo-1530482817083-29ae4b92ff15',
        isFeatured: true,
        donorCount: 21,
      ),
    ];
  }

  // Get campaigns by category
  static Future<List<Campaign>> getCampaignsByCategory(String category) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get campaigns by user
  static Future<List<Campaign>> getCampaignsByUser(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get campaign by id
  static Future<Campaign> getCampaignById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return Campaign.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update campaign
  static Future<Campaign> updateCampaign(Campaign campaign) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(campaign.toMap())
          .eq('id', campaign.id)
          .select()
          .single();
      
      return Campaign.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update campaign donation amount
  static Future<Campaign> updateCampaignDonation(
      String campaignId, int amount, bool incrementDonorCount) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  // Delete campaign
  static Future<void> deleteCampaign(String id) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // Search campaigns by title or description
  static Future<List<Campaign>> searchCampaigns(String query) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
