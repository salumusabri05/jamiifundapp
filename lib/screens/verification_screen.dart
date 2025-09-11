import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamiifund/models/verification_request.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:path/path.dart' as path;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Payment method fields
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _selectedPaymentType = 'mobile_money'; // Default value
  
  File? _idDocument;
  bool _isLoading = false;
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
          _fullNameController.text = request.fullName;
          _phoneController.text = request.phoneNumber;
          _addressController.text = request.address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking verification status: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickIdDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _idDocument = File(image.path);
      });
    }
  }

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
      String idDocumentUrl = _existingRequest?.idDocumentUrl ?? '';

      // Upload ID document if a new one was selected
      if (_idDocument != null) {
        idDocumentUrl = await VerificationService.uploadIdDocument(_idDocument!.path, userId);
      }

      // Create or update verification request
      final request = VerificationRequest(
        id: _existingRequest?.id,
        userId: userId,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        idDocumentUrl: idDocumentUrl,
        status: _existingRequest?.status ?? 'pending',
        createdAt: _existingRequest?.createdAt,
      );

      final savedRequest = await VerificationService.createVerificationRequest(request);
      
      // Save payment method
      await VerificationService.addPaymentMethod(
        userId, 
        _selectedPaymentType, 
        _accountNumberController.text, 
        _accountNameController.text
      );

      setState(() => _existingRequest = savedRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification request submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting verification request: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatusBanner() {
    if (_existingRequest == null) return const SizedBox.shrink();
    
    Color backgroundColor;
    IconData iconData;
    String message;
    
    switch (_existingRequest!.status) {
      case 'pending':
        backgroundColor = Colors.amber.shade700;
        iconData = Icons.hourglass_empty;
        message = 'Your verification is pending review';
        break;
      case 'approved':
        backgroundColor = Colors.green.shade700;
        iconData = Icons.check_circle;
        message = 'You are verified! You can now create campaigns';
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade700;
        iconData = Icons.cancel;
        message = 'Your verification was rejected: ${_existingRequest!.rejectionReason ?? 'No reason provided'}';
        break;
      default:
        backgroundColor = Colors.grey.shade700;
        iconData = Icons.info;
        message = 'Unknown status';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(iconData, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = _existingRequest == null || _existingRequest!.status == 'rejected';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campaign Creator Verification',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'To create campaigns on JamiiFund, we need to verify your identity and payment details. This helps ensure trust in our platform.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
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
                                enabled: isEditable,
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
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                                enabled: isEditable,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Home Address',
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
                                enabled: isEditable,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Payment Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedPaymentType,
                                decoration: InputDecoration(
                                  labelText: 'Payment Method',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'mobile_money',
                                    child: Text('Mobile Money'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'bank',
                                    child: Text('Bank Account'),
                                  ),
                                ],
                                onChanged: isEditable
                                    ? (value) {
                                        setState(() {
                                          _selectedPaymentType = value!;
                                        });
                                      }
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _accountNumberController,
                                decoration: InputDecoration(
                                  labelText: _selectedPaymentType == 'mobile_money'
                                      ? 'Mobile Money Number (LIPA NAMBA)'
                                      : 'Bank Account Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your account number';
                                  }
                                  return null;
                                },
                                enabled: isEditable,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _accountNameController,
                                decoration: InputDecoration(
                                  labelText: _selectedPaymentType == 'mobile_money'
                                      ? 'Mobile Money Account Name'
                                      : 'Bank Account Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your account name';
                                  }
                                  return null;
                                },
                                enabled: isEditable,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'ID Verification',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: isEditable ? _pickIdDocument : null,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _idDocument != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            _idDocument!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : _existingRequest != null && _existingRequest!.idDocumentUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                _existingRequest!.idDocumentUrl,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const Center(child: CircularProgressIndicator());
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(child: Text('Error loading image'));
                                                },
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.upload_file, size: 48, color: Colors.grey),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Upload National ID or Passport',
                                                  style: TextStyle(color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              if (isEditable)
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitVerificationRequest,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            'Submit for Verification',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                            ],
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }
}
