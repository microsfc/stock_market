import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/market_cubit.dart';
import '../blocs/stock_detail_cubit.dart';
import '../blocs/user_cubit.dart';
import '../models/stock_model.dart';

class StockDetailScreen extends StatelessWidget {
  final Stock stock;
  final TextEditingController _quantityController = TextEditingController();

  StockDetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    // Create a DateFormat instance
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    // Get the current date
    DateTime now = DateTime.now();
    // Get the date one week before the current date for week slice
    DateTime oneDayBefore = now.subtract(Duration(days: 4));
    DateTime oneWeekBefore = now.subtract(Duration(days: 7));
    DateTime oneMonthBefore = now.subtract(Duration(days: 30));
    DateTime oneYearBefore = now.subtract(Duration(days: 365));

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/stock_icons/${stock.assetName}.png',
                width: 30,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(stock.symbol),
            ],
          ),
        ),
        body: BlocBuilder<StockDetailBloc, StockDetailState>(
          builder: (context, detailState) {
            if (detailState is StockDetailLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (detailState is StockDetailLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                dotData: FlDotData(show: false),
                                isCurved: false,
                                spots: detailState.historicalData
                                    .map((data) => FlSpot(
                                        data.time.millisecondsSinceEpoch
                                            .toDouble(),
                                        data.price))
                                    .toList(),
                                color: Colors.green,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toInt().toString());
                                    }),
                              ),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toInt().toString());
                                      })),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) {
                                      DateTime date =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              value.toInt());
                                      return SideTitleWidget(
                                          angle: 0.5,
                                          axisSide: meta.axisSide,
                                          child: Text(
                                              '${date.year.toString()}-${date.month.toString()}'));
                                    }),
                              ),
                            ),
                            gridData: FlGridData(drawHorizontalLine: false),
                            borderData: FlBorderData(
                              show: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                    stock.symbol,
                                    '1',
                                    'minute',
                                    formatter.format(oneDayBefore),
                                    formatter.format(now),
                                  );
                            },
                            child: Text('1D'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'hour',
                                      formatter.format(oneWeekBefore),
                                      formatter.format(now));
                            },
                            child: Text('1W'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'hour',
                                      formatter.format(oneMonthBefore),
                                      formatter.format(now));
                            },
                            child: Text('1M'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'day',
                                      formatter.format(oneYearBefore),
                                      formatter.format(now));
                            },
                            child: Text('1Y'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final commaToDot =
                                newValue.text.replaceAll(',', '.');

                            print(oldValue.text);
                            print(newValue.text);
                            return newValue.copyWith(text: commaToDot);
                          }),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\.?\d{0,2}')),
                        ],
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        controller: _quantityController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '# of shares',
                        ),
                      ),
                    ),
                    BlocBuilder<MarketBloc, MarketState>(
                      builder: (context, marketState) {
                        if (marketState is MarketLoaded) {
                          final targetedStock =
                              marketState.getLatestStockPrice(stock.symbol);
                          return Column(
                            children: [
                              Text(
                                  'Current stock value: \$${targetedStock.price}'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(150, 40),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white),
                                    onPressed: () async {
                                      final quantity = double.tryParse(
                                          _quantityController.text);
                                      if (quantity != null) {
                                        try {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .buyStock(stock.symbol, quantity,
                                                  targetedStock.price);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Successfully bought $quantity shares of ${stock.symbol}',
                                              ),
                                            ),
                                          );
                                        } on FirebaseException catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to buy shares Firebase Exception: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'An unexpected error occurred: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          _quantityController.clear();
                                        }
                                      }
                                    },
                                    child: Text('Buy Stonks'),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(150, 40),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white),
                                    onPressed: () async {
                                      final quantity = double.tryParse(
                                          _quantityController.text);
                                      if (quantity != null) {
                                        try {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .sellStock(stock.symbol, quantity,
                                                  targetedStock.price);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Successfully sold $quantity shares of ${stock.symbol}',
                                              ),
                                            ),
                                          );
                                        } on FirebaseException catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to buy shares Firebase Exception: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${e.toString()}',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          _quantityController.clear();
                                        }
                                      }
                                    },
                                    child: Text('Sell Stonks'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              );
            } else if (detailState is StockDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      size: 100,
                      color: Colors.red,
                    ),
                    Text(detailState.message),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text('Whats that brother'),
                  ],
                ),
              );
            }
          },
        ));
  }
}
