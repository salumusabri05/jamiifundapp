import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/services/campaign_service.dart';

class DonationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> donation;

  const DonationDetailsScreen({
    Key? key, 
    required this.donation,
  }) : super(key: key);

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _campaignDetails;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCampaignDetails();
  }

  Future<void> _loadCampaignDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final campaignId = widget.donation['campaign_id'] as String;
      final campaign = await CampaignService.getCampaignDetailsById(campaignId);
      
      if (mounted) {
        setState(() {
          _campaignDetails = campaign;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load campaign details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;
    final donationDate = donation['date'] as DateTime;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donation Details',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Color(0xFF8A2BE2),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campaign Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campaign',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                donation['campaign_title'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to campaign details
                                  Navigator.pushNamed(
                                    context,
                                    '/campaign-details',
                                    arguments: {'id': donation['campaign_id']},
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text('View Campaign'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8A2BE2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Donation Details Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Donation Details',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildDetailRow('Amount', '\$${donation['amount']}', true),
                              _buildDetailRow('Payment Method', donation['payment_method'] as String),
                              _buildDetailRow('Status', donation['status'] as String),
                              _buildDetailRow('Date', '${donationDate.day}/${donationDate.month}/${donationDate.year}'),
                              if (donation['donor_name'] != null)
                                _buildDetailRow('Donor Name', donation['donor_name'] as String),
                              if (donation['donor_email'] != null)
                                _buildDetailRow('Donor Email', donation['donor_email'] as String),
                              
                              if (donation['message'] != null && donation['message'].toString().isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 24),
                                    Text(
                                      'Your Message',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      donation['message'] as String,
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              
                              const Divider(height: 24),
                              _buildDetailRow(
                                'Anonymity', 
                                donation['anonymous'] == true ? 'Anonymous donation' : 'Public donation'
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Receipt Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Receipt',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Download or share receipt functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Receipt download feature coming soon'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.receipt_long_outlined),
                                  label: const Text('Download Receipt'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF8A2BE2),
                                    side: const BorderSide(color: Color(0xFF8A2BE2)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, [bool highlight = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? const Color(0xFF8A2BE2) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
