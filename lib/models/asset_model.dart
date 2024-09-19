import 'package:equatable/equatable.dart';

class Asset extends Equatable {
  final String symbol;
  final num shares;

  const Asset({required this.symbol, required this.shares});

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      symbol: map['symbol'] ?? '',
      shares: map['shares'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'shares': shares,
    };
  }

  @override
  List<Object?> get props => [symbol, shares];
}
