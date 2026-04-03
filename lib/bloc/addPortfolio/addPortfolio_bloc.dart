import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'addPortfolio_event.dart';
import 'addPortfolio_state.dart';
import '../../services/commodity_services.dart';

class AddPortfolioBloc extends Bloc<AddPortfolioEvent, AddPortfolioState> {
  final CommodityService _commodityService;

  AddPortfolioBloc({CommodityService? commodityService})
      : _commodityService = commodityService ?? CommodityService(),
        super(AddPortfolioInitial()) {
    on<LoadPortfolioTypes>(_onLoadPortfolioTypes);
    on<SelectPortfolioType>(_onSelectPortfolioType);
  }

  Future<void> _onLoadPortfolioTypes(
      LoadPortfolioTypes event,
      Emitter<AddPortfolioState> emit,
      ) async {
    emit(AddPortfolioLoading());

    try {
      final commodities = await _commodityService.fetchCommodities();

      emit(AddPortfolioLoaded(
        portfolioTypes: [],
        allCommodities: commodities,
      ));
    } catch (e) {
      emit(AddPortfolioError(message: e.toString()));
    }
  }

  Future<void> _onSelectPortfolioType(
      SelectPortfolioType event,
      Emitter<AddPortfolioState> emit,
      ) async {
    if (state is AddPortfolioLoaded) {
      final currentState = state as AddPortfolioLoaded;

      emit(AddPortfolioTypeSelected(
        portfolioTypes: currentState.portfolioTypes,
        selectedType: event.type,
        filteredCommodities: [],
        allCommodities: currentState.allCommodities,
      ));
    }
  }

  @override
  Future<void> close() {
    _commodityService.dispose();
    return super.close();
  }
}