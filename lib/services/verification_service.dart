import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationService {
  static const String _tableName = 'verification_requests';
  static const String _paymentMethodsTable = 'payment_methods';
  
  // Get Supabase client
  static SupabaseClient get _client => SupabaseService.client;

  // Create a new verification request
  static Future<VerificationRequest> createVerificationRequest(VerificationRequest request) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(request.toMap())
          .select()
          .single();
      
      return VerificationRequest.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get verification request by user ID
  static Future<VerificationRequest?> getVerificationRequestByUserId(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return VerificationRequest.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is verified
  static Future<bool> isUserVerified(String userId) async {
    try {
      final request = await getVerificationRequestByUserId(userId);
      return request != null && request.status == 'approved';
    } catch (e) {
      return false;
    }
  }

  // Upload ID document
  static Future<String> uploadIdDocument(String filePath, String userId) async {
    try {
      final fileExt = filePath.split('.').last;
      final fileName = 'id_document_$userId.$fileExt';
      final storageResponse = await _client
          .storage
          .from('verification_documents')
          .upload(fileName, filePath);
      
      // Get the public URL of the uploaded file
      final fileUrl = _client
          .storage
          .from('verification_documents')
          .getPublicUrl(fileName);
          
      return fileUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Add payment method
  static Future<void> addPaymentMethod(String userId, String type, String accountNumber, String accountName) async {
    try {
      await _client.from(_paymentMethodsTable).insert({
        'user_id': userId,
        'type': type,
        'account_number': accountNumber,
        'account_name': accountName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get payment methods by user ID
  static Future<List<Map<String, dynamic>>> getPaymentMethodsByUserId(String userId) async {
    try {
      final response = await _client
          .from(_paymentMethodsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
  
  // Admin Methods
  
  // Get all pending verification requests
  static Future<List<VerificationRequest>> getPendingVerificationRequests() async {
    try {
      // This would normally check if the current user is an admin
      // For now, we'll just return the data
      final response = await _client
          .from(_tableName)
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((map) => VerificationRequest.fromMap(map))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update verification request status (approve/reject)
  static Future<void> updateVerificationRequestStatus(
    String requestId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      // This would normally check if the current user is an admin
      await _client.from(_tableName).update({
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all verification requests
  static Future<List<VerificationRequest>> getAllVerificationRequests() async {
    try {
      // This would normally check if the current user is an admin
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((map) => VerificationRequest.fromMap(map))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
