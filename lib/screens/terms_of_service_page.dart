import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8A2BE2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JamiiFund Terms of Service',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: September 15, 2025',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'Welcome to JamiiFund, a crowdfunding platform designed to help individuals and organizations in Tanzania raise funds for meaningful causes. By accessing or using JamiiFund ("the Platform"), you agree to be bound by these Terms of Service. Please read them carefully.',
            ),
            _buildSection(
              'Acceptance of Terms',
              'By creating an account, launching a campaign, or using any part of the Platform, you acknowledge that you have read, understood, and agree to be bound by these terms. If you do not agree with any part of these terms, you should not use the Platform.',
            ),
            _buildSection(
              'Account Registration',
              'To use certain features of the Platform, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete.\n\nYou are responsible for safeguarding your password and for all activities that occur under your account. JamiiFund will not be liable for any loss or damage arising from your failure to comply with this section.',
            ),
            _buildSection(
              'Campaign Creation and Fundraising',
              'When you create a campaign on JamiiFund, you represent and warrant that:\n\n• All information provided is accurate, complete, and not misleading\n• You have the right to create the campaign and solicit funds for the stated purpose\n• The funds raised will be used for the purpose described in your campaign\n• You will provide regular updates to your donors about the campaign\'s progress\n• You will comply with all applicable laws and regulations regarding fundraising',
            ),
            _buildSection(
              'Platform Fees',
              'JamiiFund charges a platform fee on funds raised through the Platform. The current fee structure is:\n\n• 5% platform fee on all funds raised\n• Payment processing fees (varies by payment method)\n\nThese fees are automatically deducted from the funds raised. JamiiFund reserves the right to change the fee structure at any time with notice to users.',
            ),
            _buildSection(
              'Prohibited Activities',
              'You agree not to use the Platform for:\n\n• Fraudulent purposes or misrepresentation of campaigns\n• Fundraising for illegal activities or materials\n• Campaigns that promote violence, discrimination, or hatred\n• Collection of personal data for unauthorized purposes\n• Any activity that violates local, national, or international laws\n• Any activity that infringes upon the rights of others',
            ),
            _buildSection(
              'Termination',
              'JamiiFund reserves the right, in its sole discretion, to terminate your access to and use of the Platform, including the right to remove your campaigns, if we believe you have violated these Terms or engaged in any prohibited activities.',
            ),
            _buildSection(
              'Limitation of Liability',
              'To the maximum extent permitted by law, JamiiFund shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or goodwill, service interruption, or damages related to campaign outcomes.',
            ),
            _buildSection(
              'Changes to Terms',
              'JamiiFund reserves the right to modify these Terms at any time. We will notify users of material changes through the Platform or via email. Your continued use of the Platform after such changes constitutes your acceptance of the revised Terms.',
            ),
            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms of Service, please contact us at support@jamiifund.co.tz',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '© 2025 JamiiFund. All Rights Reserved.',
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8A2BE2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

