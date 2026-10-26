import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (_, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
