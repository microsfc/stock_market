import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/services/stock_service.dart';

import '../models/historical_data_model.dart';

abstract class StockDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockDetailInitial extends StockDetailState {}

class StockDetailLoading extends StockDetailState {}

class StockDetailLoaded extends StockDetailState {
  final List<HistoricalData> historicalData;

  StockDetailLoaded(this.historicalData);
  @override
  List<Object?> get props => [historicalData];
}

class StockDetailError extends StockDetailState {
  final String message;

  StockDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class StockDetailBloc extends Cubit<StockDetailState> {
  final StockService _stockService;

  StockDetailBloc(this._stockService) : super(StockDetailInitial());

  Future<void> fetchHistoricalData(String symbol, String multiplier,
      String timespan, String from, String to) async {
    emit(StockDetailLoading());
    try {
      final historicalData = await _stockService.fetchHistoricalData(
          symbol, multiplier, timespan, from, to);
      emit(StockDetailLoaded(historicalData));
    } catch (e) {
      emit(StockDetailError(e.toString()));
    }
  }
}
