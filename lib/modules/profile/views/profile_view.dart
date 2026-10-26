import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../app/routes/app_routes.dart';
import '../profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.title.copyWith(color: AppColors.navyText)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryBlue),
            tooltip: 'My QR Code',
            onPressed: () => controller.showQrCodeModal(context),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // User Card with Avatar & Verified Badge (Reactive to AuthService)
              _buildUserHeaderCard(),

              const SizedBox(height: 16),

              // Section: Account & Security
              _buildSectionCard(
                title: 'Account & Security',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.manage_accounts_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Edit Profile & Name',
                    subtitle: 'Update your name, email and details',
                    onTap: () => controller.showEditProfileDialog(context),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.verified_user_rounded,
                    iconColor: AppColors.success,
                    title: 'KYC Verification',
                    subtitle: 'Tier 2 • Limit ₹2,00,000/month',
                    onTap: () => Get.toNamed(AppRoutes.kyc),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Wallet & Limits',
                    subtitle: 'View balance, statements and limits',
                    onTap: () => Get.toNamed(AppRoutes.wallet),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.pin_rounded,
                    iconColor: AppColors.accentOrange,
                    title: 'Change MPIN',
                    subtitle: 'Manage your 6-digit payment MPIN',
                    onTap: () => Get.toNamed(AppRoutes.mpinSetup),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.tintBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Biometric Authentication', style: AppTypography.bodyBold.copyWith(fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Fingerprint / Face ID unlock', style: AppTypography.caption),
                            ],
                          ),
                        ),
                        Obx(() => Switch(
                              value: controller.biometricEnabled.value,
                              onChanged: controller.toggleBiometrics,
                              activeThumbColor: AppColors.primaryBlue,
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section: Support & Legal
              _buildSectionCard(
                title: 'Support & Legal',
                items: [
                  _ProfileMenuItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'Help & 24x7 Support',
                    subtitle: 'FAQs, contact us, raise a ticket',
                    onTap: () => Get.toNamed(AppRoutes.support),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.primaryBlue,
                    title: 'All Transactions',
                    subtitle: 'Download statements & invoices',
                    onTap: () => Get.toNamed(AppRoutes.history),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.textSecondary,
                    title: 'Terms & Conditions',
                    subtitle: 'Usage guidelines and policy',
                    onTap: () => Get.toNamed(AppRoutes.terms),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.textSecondary,
                    title: 'Privacy Policy',
                    subtitle: 'Data protection and RBI compliance',
                    onTap: () => Get.toNamed(AppRoutes.privacy),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.currency_rupee_rounded,
                    iconColor: AppColors.accentOrange,
                    title: 'Refund Policy & SLA',
                    subtitle: 'Instant wallet reversal guarantee',
                    onTap: () => Get.toNamed(AppRoutes.refundPolicy),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // App Version & Logout Button
              _buildLogoutButton(context),

              const SizedBox(height: 12),
              Text(
                'FlamePay SuperApp v2.4.0 (Build 120)',
                style: AppTypography.micro.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard() {
    return Obx(() {
      final user = controller.authService.currentUser.value;
      final name = (user != null && user.name.isNotEmpty) ? user.name : 'Rahul Sharma';
      final phone = (user != null && user.phone.isNotEmpty) ? user.phone : '+91 98765 43210';
      final isVerified = user?.kycStatus == 'verified';

      // Compute Initials
      final parts = name.trim().split(' ');
      String initials = 'FP';
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Dynamic Avatar Initials
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppColors.blueGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTypography.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                        color: isVerified ? AppColors.primaryBlue : AppColors.accentOrange,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(phone, style: AppTypography.caption),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isVerified ? AppColors.success : AppColors.accentOrange).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isVerified ? 'Full KYC Verified' : 'KYC Pending',
                      style: AppTypography.micro.copyWith(
                        color: isVerified ? AppColors.success : AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          ...items,
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return AppButton(
      text: 'Log Out',
      type: ButtonType.outline,
      onPressed: () => controller.confirmLogout(context),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
