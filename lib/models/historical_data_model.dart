import 'package:equatable/equatable.dart';

class HistoricalData extends Equatable {
  final DateTime time;
  final double price;

  HistoricalData({required this.time, required this.price});

  @override
  List<Object?> get props => [time, price];

  factory HistoricalData.fromJson(Map<String, dynamic> data) {
    //print(DateTime.fromMillisecondsSinceEpoch(data['t']));
    return HistoricalData(
      time: DateTime.fromMillisecondsSinceEpoch(data['t']),
      price: (data['c'] as num).toDouble(),
    );
  }
}
