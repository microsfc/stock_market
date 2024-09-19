import 'package:equatable/equatable.dart';
import 'package:stock_market/services/stock_service.dart';

class Stock extends Equatable {
  final String fullName;
  final String symbol;
  final String assetName;
  final double price;
  final double previousClose;
  final int timestamp;

  const Stock(
      {this.fullName = '',
      required this.symbol,
      this.assetName = '',
      required this.price,
      this.previousClose = 0.0,
      required this.timestamp});

  // factory Stock.fromJson(Map<String, dynamic> json) {
  //   return Stock(
  //     symbol: json['s'],
  //     price: (json['p'] is int) ? (json['p'] as int).toDouble() : json['p'],
  //     percentChange:
  //         (json['p'] is int) ? (json['p'] as int).toDouble() : json['p'],
  //     timestamp: DateTime.now().millisecondsSinceEpoch,
  //   );
  // }

  factory Stock.fromWebSocketJson(Map<String, dynamic> data) {
    double updatedPrice;
    if (data['p'] is int) {
      updatedPrice = (data['p'] as int).toDouble();
    } else {
      updatedPrice = data['p'];
    }
    return Stock(
      symbol: data['s'],
      price: updatedPrice,
      timestamp: data['t'],
    );
  }

  static Future<Stock> fromQuoteJson(
      String symbol, Map<String, dynamic> data) async {
    try {
      final StockService _stockService = StockService();

      String fullName;
      if (symbol.contains('BINANCE')) {
        fullName = 'BINANCE';
      } else {
        fullName = await _stockService.fetchCompanyName(symbol);
      }
      print(symbol);
      return Stock(
        fullName: fullName,
        symbol: symbol,
        assetName: symbol.replaceAll('.', '-').replaceAll(':', '-'),
        price: (data['c'] is int) ? (data['c'] as int).toDouble() : data['c'],
        previousClose:
            (data['pc'] is int) ? (data['pc'] as int).toDouble() : data['pc'],
        timestamp: (data['t'] as int) * 1000,
      );
    } catch (e) {
      print('$symbol | fromQuoteJson Err: ${e.toString()} ');
      return Stock(
        fullName: 'ERROR Inc.',
        symbol: 'ERR',
        assetName: symbol.replaceAll('.', '-'),
        price: 0.0,
        previousClose: 0.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Stock copyWith({
    String? fullName,
    String? symbol,
    String? assetName,
    double? price,
    double? previousClose,
    int? timestamp,
  }) {
    return Stock(
      fullName: fullName ?? this.fullName,
      symbol: symbol ?? this.symbol,
      assetName: assetName ?? this.assetName,
      price: price ?? this.price,
      previousClose: previousClose ?? this.previousClose,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props =>
      [symbol, price, timestamp, fullName, assetName, previousClose];
}
