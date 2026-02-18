import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'addPortfolio_event.dart';
import 'addPortfolio_state.dart';

class AddPortfolioBloc extends Bloc<AddPortfolioEvent, AddPortfolioState> {
  AddPortfolioBloc() : super(AddPortfolioInitial()) {
    on<LoadPortfolioTypes>((event, emit) async {
      emit(AddPortfolioLoading());

      await Future.delayed(const Duration(seconds: 2));

      emit(AddPortfolioLoaded(
        portfolioTypes: [
          PortfolioType(title: "TL",       color: const Color(0xFFE53935), icon: Icons.currency_lira),
          PortfolioType(title: "BIST",     color: const Color(0xFF8E24AA), icon: Icons.bar_chart),
          PortfolioType(title: "Emtia",    color: const Color(0xFFFB8C00), icon: Icons.grain),
          PortfolioType(title: "Döviz",    color: const Color(0xFF43A047), icon: Icons.euro),
          PortfolioType(title: "Fon",      color: const Color(0xFF5C9CE5), icon: Icons.description_outlined),
          PortfolioType(title: "Eurobond", color: const Color(0xFFF9C61F), icon: Icons.blur_on),
          PortfolioType(title: "Kripto",   color: const Color(0xFFF9A825), icon: Icons.currency_bitcoin),
          PortfolioType(title: "ABD",      color: const Color(0xFFE53935), icon: Icons.scatter_plot),
        ],
      ));
    });
  }
}