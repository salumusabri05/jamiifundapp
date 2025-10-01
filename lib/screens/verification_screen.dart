import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/unified_verification.dart';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/models/verification_member.dart';
import 'package:jamiifund/services/unified_verification_service.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/widgets/verification/input_field.dart';
import 'package:jamiifund/widgets/verification/status_badge.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _organizationRegNumberController = TextEditingController();
  final _organizationTypeController = TextEditingController();
  final _organizationDescriptionController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Payment method fields
  final _lipaNambaController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  String _selectedPaymentType = 'mobile_money'; // Default value
  
  bool _isLoading = false;
  bool _isOrganization = false;
  VerificationRequest? _existingRequest;
  UnifiedVerification? _existingUnifiedVerification;
  List<VerificationMember> _members = [];

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
    _checkRequiredBuckets();
  }
  
  // Check and create required storage buckets
  Future<void> _checkRequiredBuckets() async {
    try {
      final results = await SupabaseService.ensureRequiredBuckets();
      // Check if verification_documents bucket exists
      final verificationBucketExists = results['verification_documents'] ?? false;
      
      if (!verificationBucketExists && mounted) {
        // Show a prompt to create the bucket if it doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification document storage not available. Some features may not work.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fix',
              onPressed: _showDiagnosticsOptions,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error checking required buckets: $e');
    }
  }
  
  // Show diagnostics options dialog - removed duplicate
        // Removed duplicate method

  // Check if user already has a verification request
  Future<void> _checkExistingRequest() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      
      // Check for UnifiedVerification first
      final unifiedVerification = await UnifiedVerificationService.getVerificationByUserId(userId);
      
      if (unifiedVerification != null) {
        setState(() {
          _existingUnifiedVerification = unifiedVerification;
          _isOrganization = unifiedVerification.isOrganization;
          
          // Pre-fill form data from UnifiedVerification
          _fullNameController.text = unifiedVerification.fullName ?? '';
          _phoneController.text = unifiedVerification.phone ?? '';
          _addressController.text = unifiedVerification.address ?? '';
          // Organization info
          if (unifiedVerification.isOrganization) {
            _organizationNameController.text = unifiedVerification.organizationName ?? '';
            _organizationRegNumberController.text = unifiedVerification.organizationRegNumber ?? '';
            // Bank account info
            _bankAccountNumberController.text = unifiedVerification.organizationBankAccount ?? '';
          }
          
          // Bank account
          if (unifiedVerification.bankAccount?.isNotEmpty ?? false) {
            _selectedPaymentType = 'bank_account';
            _bankAccountNumberController.text = unifiedVerification.bankAccount ?? '';
          }
        });
        return; // Stop here since we have UnifiedVerification data
      }
      
      // Fall back to older VerificationRequest approach
      final request = await VerificationService.getVerificationRequestByUserId(userId);
      
      if (request != null) {
        setState(() {
          _existingRequest = request;
          // Pre-fill from VerificationRequest
          _fullNameController.text = request.fullName ?? '';
          _phoneController.text = request.phoneNumber ?? '';
          _addressController.text = request.address ?? '';
        });

        // Also get the user's profile data to pre-fill additional fields
        final profileData = await SupabaseService.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
            
        setState(() {
          _fullNameController.text = profileData['full_name'] ?? '';
          _phoneController.text = profileData['phone'] ?? '';
          _addressController.text = profileData['address'] ?? '';
          _cityController.text = profileData['city'] ?? '';
          _regionController.text = profileData['region'] ?? '';
          _postalCodeController.text = profileData['postal_code'] ?? '';
          _websiteController.text = profileData['website'] ?? '';
          _isOrganization = profileData['is_organization'] ?? false;
          _organizationNameController.text = profileData['organization_name'] ?? '';
          _organizationRegNumberController.text = profileData['organization_reg_number'] ?? '';
          _organizationTypeController.text = profileData['organization_type'] ?? '';
          _organizationDescriptionController.text = profileData['organization_description'] ?? '';
          _bioController.text = profileData['bio'] ?? '';
          _locationController.text = profileData['location'] ?? '';
          _lipaNambaController.text = profileData['lipa_namba']?.toString() ?? '';
          _bankAccountNumberController.text = profileData['bank_account_number']?.toString() ?? '';
        });
      }
    } catch (e) {
      // Ignore error, user may not have a request yet
      print('Error checking existing request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Submit verification request using the appropriate model
  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // No need to check for ID document as we're asking users to email it
    // Just show a reminder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remember to email your required documents to jamiifund@gmail.com'),
        duration: Duration(seconds: 5),
      ),
    );

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      String? idUrl;
      
      // Determine which approach to use based on what we have
      final useUnifiedVerification = _existingUnifiedVerification != null || 
                                     (_isOrganization && _members.isNotEmpty);
      
      // No document upload needed as users will email their documents
      // Just use existing URL if available or set to null
      idUrl = _existingUnifiedVerification?.idDocumentUrl ?? _existingRequest?.idUrl;
      print("Using existing document URL if available: $idUrl");
      
      if (useUnifiedVerification) {
        // Create/update using UnifiedVerification model
        await _submitUnifiedVerification(userId, idUrl);
      } else {
        // Use the legacy verification submission method
        await VerificationService.submitVerificationDetails(
          userId: userId,
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          region: _regionController.text,
          postalCode: _postalCodeController.text,
          website: _websiteController.text,
          isOrganization: _isOrganization,
          organizationName: _isOrganization ? _organizationNameController.text : null,
          organizationRegNumber: _isOrganization ? _organizationRegNumberController.text : null,
          organizationType: _isOrganization ? _organizationTypeController.text : null,
          organizationDescription: _isOrganization ? _organizationDescriptionController.text : null,
          bio: _bioController.text,
          location: _locationController.text,
          idUrl: idUrl,
          lipaNamba: _lipaNambaController.text.isNotEmpty ? _lipaNambaController.text : null,
          bankAccountNumber: _bankAccountNumberController.text.isNotEmpty ? _bankAccountNumberController.text : null,
          documentType: 'ID',
          additionalNotes: 'Submitted via app',
        );
      }

      if (mounted) {
        // Show a success dialog with the processing message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Request Submitted',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your request is being processed. You\'ll be notified shortly.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Important:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Don\'t forget to email your required documents to jamiifund@gmail.com within 48 hours to complete your verification.',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Verification typically takes 1-3 business days after receiving all documents.',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to previous screen
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Show a more detailed error with action options
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error Submitting Request', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('An error occurred:', style: GoogleFonts.poppins()),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    e.toString(),
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                Text('What would you like to do?', style: GoogleFonts.poppins()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDiagnosticsOptions();
                },
                child: Text('Troubleshoot', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Helper method to submit using UnifiedVerification model
  Future<void> _submitUnifiedVerification(String userId, String? idUrl) async {
    // Create a UnifiedVerification object
    final verification = UnifiedVerification(
      id: _existingUnifiedVerification?.id,
      userId: userId,
      status: _existingUnifiedVerification?.status ?? 'pending',
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      idDocumentUrl: idUrl,
      bankAccount: _selectedPaymentType == 'bank_account' ? _bankAccountNumberController.text : null,
      bankName: _selectedPaymentType == 'bank_account' ? 'Bank Account' : null,
      isOrganization: _isOrganization,
      organizationName: _isOrganization ? _organizationNameController.text : null,
      organizationRegNumber: _isOrganization ? _organizationRegNumberController.text : null,
      organizationAddress: _isOrganization ? _addressController.text : null,
      organizationBankAccount: _isOrganization ? _bankAccountNumberController.text : null,
      members: _members,
      // Keep the original timestamps if they exist
      createdAt: _existingUnifiedVerification?.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Save using UnifiedVerificationService
    await UnifiedVerificationService.saveVerification(verification);
  }
  
  // Upload ID document for UnifiedVerification - Direct method that works for both web and mobile
  // Document upload method removed since users will email their documents
  // instead of uploading them directly
  
  // Build the members list UI
  List<Widget> _buildMembersList() {
    if (_members.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: Text('No members added yet. Click "Add Member" to add organization members.'),
          ),
        ),
      ];
    }
    
    return _members.map((member) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Role: ${member.role}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_existingUnifiedVerification?.status != 'approved')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeMember(member),
                  ),
              ],
            ),
            if (member.idDocumentUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'ID Document Uploaded',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
  
  // Add a new member
  void _addMember() {
    // Show dialog to add member
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final roleController = TextEditingController();
        
        return AlertDialog(
          title: Text(
            'Add Organization Member',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name*',
                    hintText: 'Enter member\'s full name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: 'Role*',
                    hintText: 'E.g., Director, Secretary, Treasurer',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || roleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Role are required')),
                  );
                  return;
                }
                
                setState(() {
                  _members.add(VerificationMember(
                    fullName: nameController.text,
                    role: roleController.text,
                  ));
                });
                
                Navigator.of(context).pop();
              },
              child: const Text('Add Member'),
            ),
          ],
        );
      },
    );
  }
  
  // Remove a member
  void _removeMember(VerificationMember member) {
    setState(() {
      _members.removeWhere((m) => 
        m.fullName == member.fullName && m.role == member.role
      );
    });
  }
  
  // Get the current verification status from either UnifiedVerification or VerificationRequest
  String _getVerificationStatus() {
    if (_existingUnifiedVerification != null) {
      return _existingUnifiedVerification!.status;
    } else if (_existingRequest != null) {
      return _existingRequest!.status;
    } else {
      return 'pending';
    }
  }
  
  // Helper method to check if fields should be enabled
  bool _isFieldEnabled() {
    return _getVerificationStatus() != 'approved';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _websiteController.dispose();
    _organizationNameController.dispose();
    _organizationRegNumberController.dispose();
    _organizationTypeController.dispose();
    _organizationDescriptionController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _lipaNambaController.dispose();
    _bankAccountNumberController.dispose();
    super.dispose();
  }
  
  // Show diagnostics options for troubleshooting upload issues
  // Empty placeholder method to avoid breaking references
  void _showDiagnosticsOptions() {
    // Show a simple message that this feature is no longer available
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature has been removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Verification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Add diagnostic button
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Diagnostics',
            onPressed: _showDiagnosticsOptions,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Diagnose Upload Issues',
            onPressed: () {
              _showDiagnosticsOptions();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Verified',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verification helps establish trust and allows you to receive donations.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_existingUnifiedVerification != null || _existingRequest != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getVerificationStatus() == 'approved'
                            ? Colors.green[50]
                            : _getVerificationStatus() == 'rejected'
                                ? Colors.red[50]
                                : Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getVerificationStatus() == 'approved'
                              ? Colors.green
                              : _getVerificationStatus() == 'rejected'
                                  ? Colors.red
                                  : Colors.amber,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge(status: _getVerificationStatus()),
                              const SizedBox(width: 8),
                            ],
                          ),
                          if (_getVerificationStatus() == 'rejected') ...[
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${_existingRequest?.rejectionReason ?? 'Your verification was not approved.'}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                          if (_getVerificationStatus() == 'approved') ...[
                            const SizedBox(height: 8),
                            Text(
                              'You are now verified and can receive donations.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ] else if (_getVerificationStatus() == 'pending') ...[
                            const SizedBox(height: 8),
                            Text(
                              'Your verification is being reviewed. This usually takes 1-3 business days.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        VerificationInputField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          isRequired: true,
                          enabled: _isFieldEnabled(),
                        ),
                        const SizedBox(height: 16),
                        VerificationInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          isRequired: true,
                          keyboardType: TextInputType.phone,
                          enabled: _isFieldEnabled(),
                        ),
                        const SizedBox(height: 24),

                        // Address Section
                        Text(
                          'Address Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        VerificationInputField(
                          controller: _addressController,
                          label: 'Street Address',
                          icon: Icons.home,
                          isRequired: true,
                          enabled: _isFieldEnabled(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                enabled: _existingRequest?.status != 'approved',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _regionController,
                                decoration: InputDecoration(
                                  labelText: 'Region/State',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                enabled: _existingRequest?.status != 'approved',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _existingRequest?.status != 'approved',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _existingRequest?.status != 'approved',
                        ),
                        const SizedBox(height: 24),

                        // Organization Information
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Organization Information',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text('Organization?'),
                            Switch(
                              value: _isOrganization,
                              onChanged: _existingRequest?.status == 'approved'
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _isOrganization = value;
                                      });
                                    },
                            ),
                          ],
                        ),
                        
                        if (_isOrganization) ...[
                          const SizedBox(height: 16),
                          VerificationInputField(
                            controller: _organizationNameController,
                            label: 'Organization Name',
                            icon: Icons.business,
                            isRequired: _isOrganization,
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          VerificationInputField(
                            controller: _organizationRegNumberController,
                            label: 'Registration Number',
                            icon: Icons.numbers,
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          VerificationInputField(
                            controller: _organizationTypeController,
                            label: 'Organization Type',
                            icon: Icons.category,
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          VerificationInputField(
                            controller: _organizationDescriptionController,
                            label: 'Organization Description',
                            icon: Icons.description,
                            maxLines: 3,
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          
                          // Organization Members Section
                          const SizedBox(height: 24),
                          Text(
                            'Organization Members',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add key members of your organization',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Members list
                          ..._buildMembersList(),
                          
                          // Add member button
                          if (_isFieldEnabled())
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: _addMember,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF8A2BE2),
                                  side: const BorderSide(color: Color(0xFF8A2BE2)),
                                ),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add Member'),
                              ),
                            ),
                        ],
                        const SizedBox(height: 24),
                        
                        // Additional Information
                        Text(
                          'Additional Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _websiteController,
                          decoration: InputDecoration(
                            labelText: 'Website',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _existingRequest?.status != 'approved',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                          enabled: _existingRequest?.status != 'approved',
                        ),
                        const SizedBox(height: 24),
                        
                        // ID Document Upload
                        Text(
                          'Required Documentation',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade300)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.email_outlined, color: Colors.blue.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email Required Documents',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Email address
                              Text(
                                'Please email all required documents to:',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                'jamiifund@gmail.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // For Individuals section
                              if (!_isOrganization) ...[
                                Text(
                                  '1. Personal Users (Individuals)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Required Documents:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Government-issued ID (choose one):',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    '- National ID card\n- Passport\n- Driver\'s license',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Optional Documents:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    '- Proof of address (utility bill, bank statement)\n- Tax Identification Number (TIN)',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              ],
                              
                              // For Organizations section
                              if (_isOrganization) ...[
                                Text(
                                  '2. Organizational Users (Companies, NGOs, Groups)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Required Documents:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '• Certificate of registration or incorporation\n'
                                    '• Tax Identification Number (TIN)\n'
                                    '• Organizational by-laws or constitution\n'
                                    '• Proof of authorized representative:\n'
                                    '  - ID of director/CEO/authorized person\n'
                                    '  - Board resolution or authorization letter\n'
                                    '• Bank account details of the organization',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Optional Documents:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    '• Organizational logo (for profile display)\n'
                                    '• Annual reports or financial statements',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                              // Email information section
                              Text(
                                'In your email, please include:',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '• Your full name as registered in this app\n'
                                  '• Phone number used during registration\n'
                                  '• Type of verification request (Personal/Organization)\n'
                                  '• Subject line: "JamiiiFund Verification - [Your Name]"',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'After submitting this form, please email your documents within 48 hours to complete your verification request.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Hidden placeholder to maintain form structure
                        SizedBox(
                          height: 0,
                          child: Opacity(
                            opacity: 0,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Container(); // Empty placeholder
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Payment Methods
                        Text(
                          'Payment Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your payment details to receive donations',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Mobile Money'),
                                value: 'mobile_money',
                                groupValue: _selectedPaymentType,
                                onChanged: _existingRequest?.status != 'approved'
                                    ? (String? value) {
                                        setState(() {
                                          _selectedPaymentType = value!;
                                        });
                                      }
                                    : null,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Bank Account'),
                                value: 'bank_account',
                                groupValue: _selectedPaymentType,
                                onChanged: _existingRequest?.status != 'approved'
                                    ? (String? value) {
                                        setState(() {
                                          _selectedPaymentType = value!;
                                        });
                                      }
                                    : null,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_selectedPaymentType == 'mobile_money')
                          TextFormField(
                            controller: _lipaNambaController,
                            decoration: InputDecoration(
                              labelText: 'Lipa Namba',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _existingRequest?.status != 'approved',
                          )
                        else
                          TextFormField(
                            controller: _bankAccountNumberController,
                            decoration: InputDecoration(
                              labelText: 'Bank Account Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _existingRequest?.status != 'approved',
                          ),
                        const SizedBox(height: 32),

                        // Submit button
                        if (_isFieldEnabled())
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitVerificationRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A2BE2),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _existingRequest == null ? 'Submit for Verification' : 'Update Verification Details',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}