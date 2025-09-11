import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/payment_processing_screen.dart';
import 'package:jamiifund/services/donation_service.dart';

class DonationScreen extends StatefulWidget {
  final Campaign campaign;

  const DonationScreen({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for the form fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Payment methods
  final List<String> _paymentMethods = [
    'M-Pesa',
    'AirtelMoney',
    'Halopesa',
    'T-Pesa',
    'Credit Card',
    'Bank Transfer'
  ];
  
  String _selectedPaymentMethod = 'M-Pesa';
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Predefined amounts
  final List<int> _predefinedAmounts = [5000, 10000, 20000, 50000, 100000];

  @override
  void dispose() {
    _amountController.dispose();
    _phoneNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Create donation data
      final donation = {
        'campaign_id': widget.campaign.id,
        'amount': double.parse(_amountController.text),
        'phone_number': _phoneNumberController.text,
        'donor_name': _isAnonymous ? null : _nameController.text,
        'donor_email': _isAnonymous ? null : _emailController.text,
        'message': _messageController.text.isEmpty ? null : _messageController.text,
        'anonymous': _isAnonymous,
        'payment_method': _selectedPaymentMethod,
      };
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      // Show payment processing screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentProcessingScreen(
            campaign: widget.campaign,
            amount: double.parse(_amountController.text),
            phoneNumber: _phoneNumberController.text,
            paymentMethod: _selectedPaymentMethod,
          ),
        ),
      );
      
      // If payment was successful (result is true), process the donation in Supabase
      if (result == true) {
        // Process donation in database
        await DonationService.createDonation(donation);
        
        if (!mounted) return;
        
        // Navigate back to campaign details
        Navigator.of(context).pop(true); // Return true to indicate successful donation
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error processing donation: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donate',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign info section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donation to:',
                          style: GoogleFonts.nunito(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.campaign.title,
                          style: GoogleFonts.nunito(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: widget.campaign.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8A2BE2),
                          ),
                          minHeight: 6.0,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TSh ${widget.campaign.currentAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Goal: TSh ${widget.campaign.goalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24.0),
                
                // Amount section
                Text(
                  'Select or enter amount *',
                  style: GoogleFonts.nunito(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: _predefinedAmounts.map((amount) {
                    return InkWell(
                      onTap: () => _selectAmount(amount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: _amountController.text == amount.toString()
                              ? const Color(0xFF8A2BE2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'TSh ${amount.toStringAsFixed(0)}',
                          style: GoogleFonts.nunito(
                            color: _amountController.text == amount.toString()
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Custom Amount (TSh)',
                    prefixText: 'TSh ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24.0),
                
                // Phone number (required)
                Text(
                  'Contact information',
                  style: GoogleFonts.nunito(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter your mobile money number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Validate Tanzania phone number format
                    // Supports formats: 0712345678, 255712345678, +255712345678
                    final phoneRegExp = RegExp(
                      r'^(\+?255|0)[67]\d{8}$',
                    );
                    if (!phoneRegExp.hasMatch(value)) {
                      return 'Please enter a valid Tanzania phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24.0),
                
                // Anonymous donation option
                CheckboxListTile(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                  title: Text(
                    'Make my donation anonymous',
                    style: GoogleFonts.nunito(),
                  ),
                  subtitle: Text(
                    'Your name will not be displayed publicly',
                    style: GoogleFonts.nunito(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                
                if (!_isAnonymous) ...[
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegExp = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 24.0),
                
                // Message (optional)
                Text(
                  'Leave a message (Optional)',
                  style: GoogleFonts.nunito(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Your message of support...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24.0),
                
                // Payment method selection
                Text(
                  'Payment Method *',
                  style: GoogleFonts.nunito(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      items: _paymentMethods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPaymentMethod = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 32.0),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.nunito(
                        color: Colors.red[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16.0),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        )
                      : Text(
                          'Donate Now',
                          style: GoogleFonts.nunito(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
