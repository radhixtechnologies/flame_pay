import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ContentSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const ContentSheet({
    super.key,
    required this.child,
    this.padding,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        boxShadow: const [AppColors.softBlueShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
