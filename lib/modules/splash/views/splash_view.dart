import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/config/app_config.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/flame_logo.dart';
import '../splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveContainer(
        child: Stack(
          children: [
            // Bottom Blue Wave Curve (matching reference image)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.height * 0.38,
              child: CustomPaint(
                painter: _SplashWavePainter(),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Center FlamePay Logo & Tagline
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FlameLogo(
                          style: LogoStyle.iconOnly,
                          size: 130,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Flame',
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: AppColors.navyText,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.flameWordmarkGradient.createShader(bounds),
                              child: Text(
                                'Pay',
                                style: GoogleFonts.poppins(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppConfig.appTagline,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.5,
                            color: AppColors.navyText.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Footer: "Your Financial Super App" & Animated Dots
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConfig.splashFooter,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                final isActive = controller.activeDot.value == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.flameYellow
                                        : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            )),
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
}

class _SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintOrange = Paint()
      ..shader = AppColors.orangeGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final pathOrange = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(pathOrange, paintOrange);

    final paintBlue = Paint()
      ..shader = AppColors.headerGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final pathBlue = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.05,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(pathBlue, paintBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
