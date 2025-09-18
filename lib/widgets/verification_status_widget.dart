import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/screens/verification_screen.dart';

class VerificationStatusWidget extends StatefulWidget {
  final bool showButton;
  final bool compact;
  
  const VerificationStatusWidget({
    super.key, 
    this.showButton = true,
    this.compact = false,
  });

  @override
  State<VerificationStatusWidget> createState() => _VerificationStatusWidgetState();
}

class _VerificationStatusWidgetState extends State<VerificationStatusWidget> {
  bool _isVerified = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final user = UserService.getCurrentUser();
      if (user != null) {
        final isVerified = await VerificationService.isUserVerified(user.id);
        setState(() => _isVerified = isVerified);
      }
    } catch (e) {
      // Silently handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToVerificationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificationScreen(),
      ),
    ).then((_) {
      // Refresh verification status when returning from verification screen
      _checkVerificationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.compact
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Center(child: CircularProgressIndicator());
    }

    if (widget.compact) {
      // Compact version (just an icon)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isVerified ? Icons.verified_user : Icons.pending,
            color: _isVerified ? Colors.green : Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              color: _isVerified ? Colors.green : Colors.amber,
            ),
          ),
        ],
      );
    }

    // Full version with button
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Creator Status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isVerified ? Icons.check_circle : Icons.info,
                  color: _isVerified ? Colors.green : Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isVerified
                        ? 'Verified - You can create campaigns'
                        : 'Verification required to create campaigns',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _isVerified ? Colors.green : Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToVerificationScreen(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _isVerified
                        ? 'View Verification Details'
                        : 'Complete Verification',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
