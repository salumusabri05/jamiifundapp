import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonationService {
  static const String _tableName = 'donations';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Create a new donation
  static Future<Map<String, dynamic>> createDonation(Map<String, dynamic> donation) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert({
            'campaign_id': donation['campaign_id'],
            'amount': donation['amount'],
            'donor_name': donation['donor_name'],
            'donor_email': donation['donor_email'],
            'message': donation['message'],
            'anonymous': donation['anonymous'],
            // Note: phone_number is not in the schema, but we'll store it for demonstration
            // In a real app, you'd add this column to the table or use a separate table
            // for payment processing details
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
}
