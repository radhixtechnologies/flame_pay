import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static const double compactMax = 359;
  static const double phoneMax = 599;
  static const double tabletMax = 1023;
  static const double maxContentWidth = 520;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isPhone(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 360 && w < 600;
  }

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static int serviceGridColumns(BuildContext context) {
    final w = width(context);
    if (w < 350) return 3;
    if (w < 600) return 4;
    if (w < 900) return 6;
    return 8;
  }

  static double scaledFont(BuildContext context, double baseFontSize) {
    final w = width(context);
    if (w < 360) return baseFontSize * 0.9;
    if (w > 600) return baseFontSize * 1.1;
    return baseFontSize;
  }

  static double scaledSpacing(BuildContext context, double baseSpacing) {
    final w = width(context);
    if (w < 360) return baseSpacing * 0.85;
    if (w > 600) return baseSpacing * 1.2;
    return baseSpacing;
  }

  /// Clamps text scale factor between 0.9 and 1.2
  static double clampTextScale(BuildContext context) {
    final factor = MediaQuery.textScalerOf(context).scale(1.0);
    return factor.clamp(0.9, 1.2);
  }
}

/// A responsive wrapper that prevents wide screen stretching (tablets/desktops)
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveHelper.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) {
      return child;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
