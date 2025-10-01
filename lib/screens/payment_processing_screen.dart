import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/donation_service.dart';
import 'package:jamiifund/services/click_pesa_service.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final Campaign campaign;
  final double amount;
  final String phoneNumber;
  final String paymentMethod;
  final String? donorName;
  final String? donorEmail;
  final String? message;
  final bool anonymous;

  const PaymentProcessingScreen({
    super.key,
    required this.campaign,
    required this.amount,
    required this.phoneNumber,
    required this.paymentMethod,
    this.donorName,
    this.donorEmail,
    this.message,
    this.anonymous = false,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = true;
  bool _isSuccess = false;
  String _message = 'Processing your payment...';
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _processPayment() async {
    try {
      // Create donation data
      final donation = {
        'campaign_id': widget.campaign.id,
        'amount': widget.amount,
        'donor_name': widget.donorName,
        'donor_email': widget.donorEmail,
        'message': widget.message,
        'anonymous': widget.anonymous,
        'payment_method': widget.paymentMethod,
        'phone_number': widget.phoneNumber, // Add phone number to store in donor_payment_number
      };
      
      // Handle payment based on payment method
      if (widget.paymentMethod.toLowerCase().contains('mobile') || 
          widget.paymentMethod.toLowerCase().contains('click') ||
          widget.paymentMethod.toLowerCase().contains('ussd')) {
        
        // Process mobile payment using ClickPesa
        // Only proceed if payment is successfully initiated
        final paymentInitiated = await _processClickPesaPayment(
          widget.phoneNumber, 
          widget.amount.toString()
        );
        
        // Only create the donation record if the payment was initiated successfully
        if (paymentInitiated) {
          // Add payment status to the donation
          donation['payment_status'] = 'pending';
          
          // Create donation in database
          await DonationService.createDonation(donation);
          
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _isSuccess = true;
              _message = 'USSD Push sent! Check your phone to complete payment.';
              _startCountdown();
            });
          }
        } else {
          // This should not happen as _processClickPesaPayment throws exceptions on failure
          // But adding as a safety check
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _isSuccess = false;
              _message = 'Failed to initiate payment. Please try again.';
            });
          }
        }
      } else {
        // For other payment methods (like credit card)
        // Add payment status to the donation
        donation['payment_status'] = 'completed';
        
        // Create the donation in Supabase directly
        await DonationService.createDonation(donation);
        
        // Consider the payment successful
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
            _message = 'Payment successful!';
            _startCountdown();
          });
        }
      }
    } catch (e) {
      // Handle payment failure
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = 'Payment failed: ${e.toString()}';
        });
      }
    }
    
    // In a real scenario, you'd handle different payment results:
    // - Success: Update database, show confirmation
    // - Pending: Show instructions for completing the payment
    // - Failed: Show error and retry options
  }

  /// Process payment using ClickPesa USSD Push
  /// 
  /// Generates a token, then optionally previews and initiates a USSD push payment request
  /// to the provided phone number for the specified amount
  /// 
  /// Returns true only if payment was successfully initiated
  /// Throws an exception if the payment fails
  Future<bool> _processClickPesaPayment(String phoneNumber, String amount) async {
    try {
      // Update UI to show we're processing
      if (mounted) {
        setState(() {
          _message = 'Initiating mobile payment...';
        });
      }
      
      // Use the simplified makePayment method which handles all payment logic
      // including phone number validation, payment initiation, and status confirmation
      final response = await ClickPesaService.makePayment(
        phoneNumber: phoneNumber,  // The service will handle formatting internally
        amount: amount,
      );
      
      // Store transaction details for future reference
      final transactionId = response.transactionId;
      if (transactionId != null) {
        await _storeTransactionDetails(
          transactionId, 
          response.orderReference,
          networkProvider: response.networkProvider,
        );
      }
      
      // Handle different payment states
      if (response.success) {
        if (response.isPending) {
          // Payment is pending user action on their phone
          if (mounted) {
            setState(() {
              _message = 'Please check your phone to complete the payment. '
                  'A USSD prompt should appear shortly.';
            });
          }
          return true;
        } else if (response.isCompleted) {
          // Payment completed successfully
          if (mounted) {
            setState(() {
              _message = 'Payment completed successfully!';
            });
          }
          return true;
        } else {
          // Other successful states
          return true;
        }
      } else {
        // Payment initiation failed
        throw Exception(response.message);
      }
    } catch (e) {
      debugPrint('ClickPesa payment error: $e');
      rethrow; // Re-throw to be caught by the caller
    }
  }

  /// Stores transaction details for later reference or verification
  Future<void> _storeTransactionDetails(
    String transactionId, 
    String? orderReference, {
    String? networkProvider,
  }) async {
    try {
      // This could store the transaction ID in shared preferences or a local database
      // For simplicity, we'll just log it for now
      debugPrint('Transaction initiated: ID=$transactionId, Reference=$orderReference, Network=$networkProvider');
      
      // In a full implementation, you might want to:
      // 1. Store this in the donation record in your database
      // 2. Create a local reference for tracking
      // 3. Set up a webhook or background task to check the status later
    } catch (e) {
      debugPrint('Failed to store transaction details: $e');
    }
  }
  
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            Navigator.of(context).pop(true); // Return to previous screen
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button when processing
        return !_isProcessing;
      },
      child: Scaffold(
        appBar: _isProcessing
            ? null // No app bar during processing
            : AppBar(
                title: Text(
                  'Payment Complete',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF8A2BE2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Extra top padding
                  const SizedBox(height: 20.0),
                  
                  // Payment status icon
                  if (_isProcessing)
                    const CircularProgressIndicator(
                      color: Color(0xFF8A2BE2),
                      strokeWidth: 3,
                    )
                  else if (_isSuccess)
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    )
                  else
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 80,
                    ),
                    
                  const SizedBox(height: 24.0),
                  
                  // Status message
                  Text(
                    _message,
                    style: GoogleFonts.nunito(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _isProcessing
                          ? Colors.black87
                          : (_isSuccess ? Colors.green : Colors.red),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16.0),
                  
                  // Payment details
                  if (_isSuccess) ...[
                    const Divider(),
                    const SizedBox(height: 16.0),
                    
                    // Campaign name
                    Text(
                      'Campaign:',
                      style: GoogleFonts.nunito(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.campaign.title,
                      style: GoogleFonts.nunito(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    // Amount and payment method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount:',
                              style: GoogleFonts.nunito(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'TSh ${widget.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.nunito(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8A2BE2),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Payment Method:',
                              style: GoogleFonts.nunito(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              widget.paymentMethod,
                              style: GoogleFonts.nunito(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    // Phone number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Phone Number:',
                              style: GoogleFonts.nunito(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              widget.phoneNumber,
                              style: GoogleFonts.nunito(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 16.0),
                    
                    // Transaction reference
                    Text(
                      'Transaction Reference:',
                      style: GoogleFonts.nunito(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      style: GoogleFonts.nunito(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    Text(
                      'Thank you for your generous contribution!',
                      style: GoogleFonts.nunito(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A2BE2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    // Auto redirect message
                    Text(
                      'You will be redirected back in $_countdown seconds',
                      style: GoogleFonts.nunito(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.of(context).pop(true); // Return with success
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A2BE2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  if (_isProcessing) ...[
                    const SizedBox(height: 24.0),
                    Text(
                      'Please wait while we process your payment...',
                      style: GoogleFonts.nunito(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Do not close this page or press back',
                      style: GoogleFonts.nunito(
                        fontSize: 14.0,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Extra bottom padding to ensure content is fully scrollable
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
