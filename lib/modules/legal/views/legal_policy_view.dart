import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';

class LegalPolicyView extends StatefulWidget {
  final int initialTabIndex;
  const LegalPolicyView({super.key, this.initialTabIndex = 0});

  @override
  State<LegalPolicyView> createState() => _LegalPolicyViewState();
}

class _LegalPolicyViewState extends State<LegalPolicyView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Legal & Compliance', style: AppTypography.title.copyWith(color: AppColors.navyText)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyText),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelStyle: AppTypography.bodyBold.copyWith(fontSize: 13),
          tabs: const [
            Tab(text: 'Terms'),
            Tab(text: 'Privacy'),
            Tab(text: 'Refunds'),
          ],
        ),
      ),
      body: ResponsiveContainer(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTermsTab(),
            _buildPrivacyTab(),
            _buildRefundsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildComplianceBadge(),
        const SizedBox(height: 16),
        _buildSectionCard(
          number: '1',
          title: 'Acceptance of Terms',
          content: 'By accessing or using FlamePay ("FlamePay SuperApp"), you agree to be bound by these Terms and Conditions and our Privacy Policy. If you do not agree, do not use the application.',
        ),
        _buildSectionCard(
          number: '2',
          title: 'Wallet Limits & KYC',
          content: 'In accordance with RBI Master Directions on PPIs (Prepaid Payment Instruments), minimum KYC accounts have a monthly load and transaction limit of ₹10,000. Completing Full Video/Biometric KYC raises your monthly limit to ₹2,00,000.',
        ),
        _buildSectionCard(
          number: '3',
          title: 'Security & MPIN Protection',
          content: 'You are exclusively responsible for maintaining the confidentiality of your 6-digit MPIN, biometric credentials, and OTPs. FlamePay will never ask for your MPIN or full card CVV over phone, SMS, or email.',
        ),
        _buildSectionCard(
          number: '4',
          title: 'Prohibited Usage & AML',
          content: 'FlamePay strictly prohibits any fraudulent transactions, commercial cross-border laundering, or unauthorized peer payments. Accounts exhibiting suspicious activity are flagged and reported to FIU-IND.',
        ),
        _buildSectionCard(
          number: '5',
          title: 'Governing Law & Jurisdiction',
          content: 'These terms are governed by the laws of India. Any disputes arising out of the use of FlamePay services shall be subject to the exclusive jurisdiction of the courts of Mumbai/New Delhi.',
        ),
      ],
    );
  }

  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSecurityBadge(),
        const SizedBox(height: 16),
        _buildSectionCard(
          number: '1',
          title: 'Data Collection & Purpose',
          content: 'We collect your mobile number, legal name, PAN/Aadhaar information for KYC, and transaction history solely to provide seamless financial, recharge, and payment services.',
        ),
        _buildSectionCard(
          number: '2',
          title: 'RBI Data Localization Mandate',
          content: '100% of your financial and personal data is hosted in ISO 27001-certified Tier-4 data centers located within the territorial borders of India in strict adherence to RBI data localization guidelines.',
        ),
        _buildSectionCard(
          number: '3',
          title: 'Bank-Grade 256-bit AES Encryption',
          content: 'All communication between your device and FlamePay servers is encrypted via TLS 1.3 with AES-256 cipher suites. We are PCI-DSS Level 1 certified.',
        ),
        _buildSectionCard(
          number: '4',
          title: 'Zero Third-Party Data Selling',
          content: 'FlamePay does not sell, rent, or trade your personal or financial data to any unauthorized third-party advertisers. Data is shared strictly with regulated banking and credit bureau partners to process your requested services.',
        ),
      ],
    );
  }

  Widget _buildRefundsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRefundBadge(),
        const SizedBox(height: 16),
        _buildSectionCard(
          number: '1',
          title: 'Instant Mobile & DTH Recharge Refunds',
          content: 'If your recharge fails or is rejected by the operator (Jio, Airtel, Vi, BSNL, Tata Play), the entire deducted amount is instantly refunded to your FlamePay Wallet within 5 minutes.',
        ),
        _buildSectionCard(
          number: '2',
          title: 'Utility Bill Payment Reversal SLA',
          content: 'For Electricity, Gas, and Water bill payments, BBPS (Bharat Bill Payment System) reconciles within 2 hours. If the biller rejects payment, money is credited back automatically.',
        ),
        _buildSectionCard(
          number: '3',
          title: 'Bank Account Top-up Auto-Refund',
          content: 'If funds were deducted from your bank via UPI or Netbanking but failed to reflect in your FlamePay Wallet, NPCI auto-reversal guarantees refund into your originating bank within T+1 working days.',
        ),
        _buildSectionCard(
          number: '4',
          title: '24x7 Grievance Redressal Desk',
          content: 'Contact our Grievance Officer at grievance@flamepay.com or call 1800-FLAME-PAY (Toll-Free). Ticket SLA is 2 hours for urgent disputes.',
        ),
      ],
    );
  }

  Widget _buildComplianceBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D7FE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RBI Regulated Entity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyText)),
                SizedBox(height: 2),
                Text('Licensed PPI Issuer • NPCI & BBPS Compliant', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA6F4C5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.success, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PCI-DSS Level 1 & ISO 27001', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyText)),
                SizedBox(height: 2),
                Text('256-bit bank-grade encryption with 100% data localization in India', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD6AE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.currency_rupee_rounded, color: AppColors.accentOrange, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('100% Instant Refund Guarantee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyText)),
                SizedBox(height: 2),
                Text('Failed recharges credited within 5 minutes directly to wallet', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyBold.copyWith(fontSize: 13.5, color: AppColors.navyText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTypography.caption.copyWith(fontSize: 12.5, height: 1.5, color: const Color(0xFF344054)),
          ),
        ],
      ),
    );
  }
}
