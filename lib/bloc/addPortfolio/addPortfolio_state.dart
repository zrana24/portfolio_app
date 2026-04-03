import 'package:flutter/material.dart';
import '../../services/commodity_services.dart';

abstract class AddPortfolioState {}

class AddPortfolioInitial extends AddPortfolioState {}

class AddPortfolioLoading extends AddPortfolioState {}

class AddPortfolioLoaded extends AddPortfolioState {
  final List<PortfolioType> portfolioTypes;
  final List<CommodityItem> allCommodities;

  AddPortfolioLoaded({
    required this.portfolioTypes,
    required this.allCommodities,
  });
}

class AddPortfolioTypeSelected extends AddPortfolioState {
  final List<PortfolioType> portfolioTypes;
  final PortfolioType selectedType;
  final List<CommodityItem> filteredCommodities;
  final List<CommodityItem> allCommodities;

  AddPortfolioTypeSelected({
    required this.portfolioTypes,
    required this.selectedType,
    required this.filteredCommodities,
    required this.allCommodities,
  });
}

class AddPortfolioError extends AddPortfolioState {
  final String message;

  AddPortfolioError({required this.message});
}

class PortfolioType {
  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;
  final String category;
  final int itemCount;

  PortfolioType({
    required this.title,
    this.subtitle,
    required this.color,
    required this.icon,
    required this.category,
    required this.itemCount,
  });
}