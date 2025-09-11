import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/supabase_client.dart';

class VerificationAdminScreen extends StatefulWidget {
  const VerificationAdminScreen({Key? key}) : super(key: key);

  @override
  State<VerificationAdminScreen> createState() => _VerificationAdminScreenState();
}

class _VerificationAdminScreenState extends State<VerificationAdminScreen> {
  List<VerificationRequest> _pendingRequests = [];
  bool _isLoading = true;
  final _rejectionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);
    
    try {
      // This would be a method in VerificationService that is only available to admins
      // For now, we'll just simulate it
      final requests = await VerificationService.getPendingVerificationRequests();
      setState(() => _pendingRequests = requests);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading requests: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(VerificationRequest request) async {
    try {
      await VerificationService.updateVerificationRequestStatus(
        request.id!,
        'approved',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved successfully!')),
      );
      
      _loadPendingRequests(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving request: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectRequest(VerificationRequest request) async {
    // Show rejection reason dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rejection Reason',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: _rejectionReasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _rejectionReasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await VerificationService.updateVerificationRequestStatus(
          request.id!,
          'rejected',
          rejectionReason: reason,
        );
        
        _rejectionReasonController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected successfully!')),
        );
        
        _loadPendingRequests(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verification Requests',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? Center(
                  child: Text(
                    'No pending verification requests',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          request.fullName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Submitted: ${_formatDate(request.createdAt)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Phone Number', request.phoneNumber),
                                _buildInfoRow('Address', request.address),
                                const SizedBox(height: 16),
                                const Text(
                                  'ID Document:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    request.idDocumentUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _rejectRequest(request),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () => _approveRequest(request),
                                      child: const Text('Approve'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}
