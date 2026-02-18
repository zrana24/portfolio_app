import 'package:flutter/material.dart';

abstract class AddPortfolioState {}

class AddPortfolioInitial extends AddPortfolioState {}

class AddPortfolioLoading extends AddPortfolioState {}

class AddPortfolioLoaded extends AddPortfolioState {
  final List<PortfolioType> portfolioTypes;
  AddPortfolioLoaded({required this.portfolioTypes});
}

class PortfolioType {
  final String title;
  final Color color;
  final IconData icon;

  PortfolioType({
    required this.title,
    required this.color,
    required this.icon,
  });
}