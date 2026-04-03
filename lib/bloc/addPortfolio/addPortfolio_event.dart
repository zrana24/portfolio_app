import 'addPortfolio_state.dart';

abstract class AddPortfolioEvent {}

class LoadPortfolioTypes extends AddPortfolioEvent {}

class SelectPortfolioType extends AddPortfolioEvent {
  final PortfolioType type;

  SelectPortfolioType({required this.type});
}