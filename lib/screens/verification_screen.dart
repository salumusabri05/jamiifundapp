import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/supabase_client.dart';

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
  
  File? _idDocument;
  Uint8List? _idImageBytes;
  bool _isLoading = false;
  bool _isOrganization = false;
  VerificationRequest? _existingRequest;

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  // Check if user already has a verification request
  Future<void> _checkExistingRequest() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      final request = await VerificationService.getVerificationRequestByUserId(userId);
      
      if (request != null) {
        setState(() {
          _existingRequest = request;
          // No need to pre-fill form data for existing requests as we'll use the profile data
        });

        // Also get the user's profile data to pre-fill the form
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

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (image != null) {
      final imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      
      setState(() {
        _idDocument = imageFile;
        _idImageBytes = imageBytes;
      });
    }
  }

  // Submit verification request
  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_idDocument == null && _existingRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your ID document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      String? idUrl = _existingRequest?.idUrl;

      // Upload ID document if a new one was selected
      if (_idDocument != null) {
        idUrl = await VerificationService.uploadIdDocument(_idDocument!.path, userId);
      }

      // Use the new comprehensive verification submission method
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification request submitted successfully! We will review your information.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  if (_existingRequest != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _existingRequest!.status == 'approved'
                            ? Colors.green[50]
                            : _existingRequest!.status == 'rejected'
                                ? Colors.red[50]
                                : Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _existingRequest!.status == 'approved'
                              ? Colors.green
                              : _existingRequest!.status == 'rejected'
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
                              Icon(
                                _existingRequest!.status == 'approved'
                                    ? Icons.check_circle
                                    : _existingRequest!.status == 'rejected'
                                        ? Icons.cancel
                                        : Icons.pending,
                                color: _existingRequest!.status == 'approved'
                                    ? Colors.green
                                    : _existingRequest!.status == 'rejected'
                                        ? Colors.red
                                        : Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _existingRequest!.status == 'approved'
                                    ? 'Verified'
                                    : _existingRequest!.status == 'rejected'
                                        ? 'Verification Rejected'
                                        : 'Verification Pending',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: _existingRequest!.status == 'approved'
                                      ? Colors.green
                                      : _existingRequest!.status == 'rejected'
                                          ? Colors.red
                                          : Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                          if (_existingRequest!.status == 'rejected' && _existingRequest!.rejectionReason != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${_existingRequest!.rejectionReason}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                          if (_existingRequest!.status == 'approved') ...[
                            const SizedBox(height: 8),
                            Text(
                              'You are now verified and can receive donations.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ] else if (_existingRequest!.status == 'pending') ...[
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
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                          enabled: _existingRequest?.status != 'approved',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          enabled: _existingRequest?.status != 'approved',
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
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Street Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                          enabled: _existingRequest?.status != 'approved',
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
                          TextFormField(
                            controller: _organizationNameController,
                            decoration: InputDecoration(
                              labelText: 'Organization Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (_isOrganization && (value == null || value.isEmpty)) {
                                return 'Please enter organization name';
                              }
                              return null;
                            },
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _organizationRegNumberController,
                            decoration: InputDecoration(
                              labelText: 'Registration Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _organizationTypeController,
                            decoration: InputDecoration(
                              labelText: 'Organization Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _existingRequest?.status != 'approved',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _organizationDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Organization Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 3,
                            enabled: _existingRequest?.status != 'approved',
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
                          'ID Document',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a clear image of your ID card or passport',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _existingRequest?.status != 'approved'
                              ? _pickImage
                              : null,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: _idImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _idImageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _existingRequest != null && _existingRequest!.idUrl != null && _existingRequest!.idUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _existingRequest!.idUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Error loading image',
                                                    style: GoogleFonts.poppins(color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap to upload ID document',
                                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
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
                        if (_existingRequest?.status != 'approved')
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