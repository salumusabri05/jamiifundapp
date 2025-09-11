import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final Campaign campaign;
  final double amount;
  final String phoneNumber;
  final String paymentMethod;

  const PaymentProcessingScreen({
    Key? key,
    required this.campaign,
    required this.amount,
    required this.phoneNumber,
    required this.paymentMethod,
  }) : super(key: key);

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
    // In a real app, you'd integrate with a payment gateway here
    // For this demo, we'll simulate a payment process
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Simulate successful payment
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _message = 'Payment successful!';
        _startCountdown();
      });
    }
    
    // In a real scenario, you'd handle different payment results:
    // - Success: Update database, show confirmation
    // - Pending: Show instructions for completing the payment
    // - Failed: Show error and retry options
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
