import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/payment_processing_screen.dart';

class StripePaymentScreen extends StatefulWidget {
  final Campaign campaign;
  final double amount;

  const StripePaymentScreen({
    Key? key,
    required this.campaign,
    required this.amount,
  }) : super(key: key);

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Format the card number as user types
  String _formatCardNumber(String input) {
    // Remove all non-digit characters
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    
    // Format with spaces every 4 digits
    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }
    
    return buffer.toString();
  }

  // Format the expiry date as MM/YY
  String _formatExpiry(String input) {
    // Remove all non-digit characters
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length > 2) {
      return '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    } else {
      return digitsOnly;
    }
  }

  Future<void> _processStripePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // In a real app, you'd create a donation object and process the credit card payment with Stripe
      // This is where you would:
      // 1. Create a payment method using the card details
      // 2. Create a payment intent for the amount
      // 3. Confirm the payment intent
      
      // For demo purposes, we'll just simulate a successful payment
      await Future.delayed(const Duration(seconds: 2));
      
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
            amount: widget.amount,
            phoneNumber: 'N/A (Card payment)',
            paymentMethod: 'Credit Card',
            donorName: _isAnonymous ? null : _nameController.text,
            donorEmail: _isAnonymous ? null : _emailController.text,
            message: _messageController.text.isEmpty ? null : _messageController.text,
            anonymous: _isAnonymous,
          ),
        ),
      );
      
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Payment failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card Payment',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment amount card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Donation Amount',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TSh ${widget.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8A2BE2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'for ${widget.campaign.title}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Card payment section title
                  Text(
                    'Payment Details',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Card number field
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    onChanged: (value) {
                      final formatted = _formatCardNumber(value);
                      if (formatted != value) {
                        _cardNumberController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your card number';
                      }
                      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                      if (digitsOnly.length < 16) {
                        return 'Please enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Expiry date and CVV row
                  Row(
                    children: [
                      // Expiry date field
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onChanged: (value) {
                            final formatted = _formatExpiry(value);
                            if (formatted != value) {
                              _expiryController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            // Simple validation for MM/YY format
                            final parts = value.split('/');
                            if (parts.length != 2) {
                              return 'Invalid format';
                            }
                            
                            final month = int.tryParse(parts[0]);
                            final year = int.tryParse(parts[1]);
                            
                            if (month == null || year == null || month < 1 || month > 12) {
                              return 'Invalid date';
                            }
                            
                            // Check if card is expired
                            final now = DateTime.now();
                            final cardYear = 2000 + year; // Convert YY to 20YY
                            
                            if (cardYear < now.year || (cardYear == now.year && month < now.month)) {
                              return 'Card expired';
                            }
                            
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // CVV field
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 3) {
                              return 'Invalid CVV';
                            }
                            return null;
                          },
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Donor information section
                  Text(
                    'Donor Information',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Anonymous switch
                  SwitchListTile(
                    title: Text(
                      'Donate Anonymously',
                      style: GoogleFonts.nunito(),
                    ),
                    subtitle: Text(
                      'Your name will not be displayed publicly',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    value: _isAnonymous,
                    activeColor: const Color(0xFF8A2BE2),
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  
                  // Donor name field (unless anonymous)
                  if (!_isAnonymous) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (!_isAnonymous && (value == null || value.isEmpty)) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email field (unless anonymous)
                  if (!_isAnonymous) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (!_isAnonymous && (value == null || value.isEmpty)) {
                          return 'Please enter your email';
                        }
                        if (!_isAnonymous && value != null && !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Message field (optional)
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message (Optional)',
                      hintText: 'Add a message of support...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.nunito(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Payment button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processStripePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2BE2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : Text(
                              'Make Payment',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Secure payment notice
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure payment via Stripe',
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
