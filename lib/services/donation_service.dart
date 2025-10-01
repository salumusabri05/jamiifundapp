import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamiifund/services/user_service.dart';

class DonationService {
  static const String _tableName = 'donations';
  static const String _campaignsTable = 'campaigns';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Create a new donation
  static Future<Map<String, dynamic>> createDonation(Map<String, dynamic> donation) async {
    try {
      // Get the current user ID
      final currentUser = UserService.getCurrentUser();
      final userId = currentUser?.id;
      
      final response = await _client
          .from(_tableName)
          .insert({
            'campaign_id': donation['campaign_id'],
            'amount': donation['amount'],
            'donor_name': donation['donor_name'],
            'donor_email': donation['donor_email'],
            'message': donation['message'],
            'anonymous': donation['anonymous'],
            'user_id': userId, // Add the user_id field
            'donor_payment_number': donation['phone_number'], // Store phone number in donor_payment_number column
            'payment_method': donation['payment_method'],
          })
          .select()
          .single();
      
      // In a real implementation, here you would:
      // 1. Call the mobile money API or payment gateway
      // 2. Update the campaign's current amount and donor count
      
      // Mock update of campaign's current amount and donor count
      await _updateCampaignStats(
        donation['campaign_id'],
        donation['amount'],
      );
      
      // Return the created donation
      return response;
    } catch (e) {
      // Handle any specific errors
      throw 'Failed to process donation: $e';
    }
  }
  
  // Update campaign stats (current amount and donor count)
  static Future<void> _updateCampaignStats(String campaignId, double amount) async {
    try {
      // First get the current campaign data
      final campaign = await _client
          .from('campaigns')
          .select('current_amount, donor_count')
          .eq('id', campaignId)
          .single();
      
      // Update the campaign with new amount and donor count
      await _client
          .from('campaigns')
          .update({
            'current_amount': (campaign['current_amount'] ?? 0) + amount,
            'donor_count': (campaign['donor_count'] ?? 0) + 1,
          })
          .eq('id', campaignId);
    } catch (e) {
      // Just log the error but don't interrupt the donation process
      print('Error updating campaign stats: $e');
    }
  }
  
  // Get donations by campaign
  static Future<List<Map<String, dynamic>>> getDonationsByCampaign(String campaignId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('campaign_id', campaignId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch donations: $e';
    }
  }
  
  // Get donation stats for a campaign
  static Future<Map<String, dynamic>> getDonationStats(String campaignId) async {
    try {
      final response = await _client
          .rpc('get_donation_stats', params: {'campaign_id_param': campaignId});
      
      return response as Map<String, dynamic>;
    } catch (e) {
      throw 'Failed to fetch donation stats: $e';
    }
  }
  
  // Get donations by user ID
  static Future<List<Map<String, dynamic>>> getDonationsByUserId(String userId) async {
    try {
      print('Getting donations for user: $userId');
      
      // Check if user_id column exists in the donations table
      try {
        // First, let's debug what's in the donations table
        final allDonations = await _client
            .from(_tableName)
            .select('id, user_id, campaign_id')
            .limit(5);
            
        print('Sample donations: $allDonations');
      } catch (e) {
        print('Debug query error: $e');
      }
      
      // Get donations made by the user
      final donations = await _client
          .from(_tableName)
          .select('''
            id,
            campaign_id,
            user_id,
            amount,
            donor_name,
            donor_email,
            message,
            anonymous,
            created_at,
            payment_method,
            campaigns!donations_campaign_id_fkey (
              id,
              title,
              description,
              category,
              goal_amount,
              current_amount,
              end_date,
              image_url,
              created_by,
              is_featured,
              donor_count,
              created_by_name,
              video_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      // Transform the data for easier consumption in the UI
      final result = (donations as List).map((donation) {
        final campaign = donation['campaigns'] as Map<String, dynamic>;
        
        return {
          'id': donation['id'],
          'campaign_id': donation['campaign_id'],
          'campaign_title': campaign['title'],
          'campaign_image': campaign['image_url'],
          'amount': donation['amount'],
          'date': DateTime.parse(donation['created_at']),
          'message': donation['message'],
          'anonymous': donation['anonymous'],
          'donor_name': donation['donor_name'],
          'donor_email': donation['donor_email'],
          'payment_method': donation['payment_method'] ?? 'Unknown',
          'status': 'Completed', // Assuming all donations in the DB are completed
        };
      }).toList();
      
      return result;
    } catch (e) {
      print('Error getting donations: $e');
      return [];
    }
  }

  // Get campaigns created by user
  static Future<List<Campaign>> getCampaignsByUserId(String userId) async {
    try {
      final response = await _client
          .from(_campaignsTable)
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false);
          
      return (response as List).map((item) => Campaign.fromMap(item)).toList();
    } catch (e) {
      print('Error getting user campaigns: $e');
      return [];
    }
  }
}
