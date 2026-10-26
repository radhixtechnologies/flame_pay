import 'package:flutter/material.dart';

enum ServiceCategory {
  rechargeAndBills,
  insurance,
  financialServices,
}

class ServiceItemModel {
  final String id;
  final String title;
  final IconData icon;
  final Color tintColor;
  final Color iconColor;
  final String route;
  final ServiceCategory category;
  final bool isPopular;

  const ServiceItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.tintColor,
    required this.iconColor,
    required this.route,
    required this.category,
    this.isPopular = false,
  });
}
