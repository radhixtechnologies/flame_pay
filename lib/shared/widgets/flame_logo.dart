import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/config/app_config.dart';

enum LogoStyle {
  fullWithTagline,
  fullClean,
  iconOnly,
}

class FlameLogo extends StatelessWidget {
  final LogoStyle style;
  final double size;
  final String? customTagline;

  const FlameLogo({
    super.key,
    this.style = LogoStyle.fullWithTagline,
    this.size = 48,
    this.customTagline,
  });

  @override
  Widget build(BuildContext context) {
    if (style == LogoStyle.iconOnly) {
      return Image.asset(
        'assets/images/flamepay_icon.png',
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _buildVectorIcon(size),
      );
    }

    if (style == LogoStyle.fullClean) {
      return Image.asset(
        'assets/images/flamepay_logo_full.png',
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildVectorFull(false),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/flamepay_logo_full.png',
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildVectorFull(true),
        ),
        if (customTagline != null) ...[
          const SizedBox(height: 6),
          Text(
            customTagline!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVectorIcon(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(s * 0.28),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Center(
        child: Text(
          'F',
          style: GoogleFonts.poppins(
            fontSize: s * 0.6,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildVectorFull(bool showTagline) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVectorIcon(size * 0.8),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Flame',
                  style: GoogleFonts.poppins(
                    fontSize: size * 0.45,
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
                      fontSize: size * 0.45,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (showTagline)
              Text(
                AppConfig.logoTagline,
                style: GoogleFonts.inter(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
