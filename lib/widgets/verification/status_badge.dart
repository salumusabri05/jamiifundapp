import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57C00);
        label = 'Pending';
        icon = Icons.hourglass_top;
        break;
      case 'primary':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        label = 'Primary';
        icon = Icons.star;
        break;
      case 'draft':
        backgroundColor = const Color(0xFFE0F2F1);
        textColor = const Color(0xFF00796B);
        label = 'Draft';
        icon = Icons.edit_note;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = _capitalizeFirstLetter(status);
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
