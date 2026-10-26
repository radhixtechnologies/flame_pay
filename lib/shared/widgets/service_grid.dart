import 'package:flutter/material.dart';
import '../../data/models/service_item_model.dart';
import 'service_tile.dart';

class ServiceGrid extends StatelessWidget {
  final List<ServiceItemModel> services;
  final ValueChanged<ServiceItemModel> onServiceTap;
  final int crossAxisCount;

  const ServiceGrid({
    super.key,
    required this.services,
    required this.onServiceTap,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = services[index];
        return ServiceTile(
          service: item,
          onTap: () => onServiceTap(item),
        );
      },
    );
  }
}
