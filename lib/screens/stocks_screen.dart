import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stock_market/blocs/stock_detail_cubit.dart';
import 'package:stock_market/screens/stock_detail_screen.dart';

import '../blocs/market_cubit.dart';
import '../blocs/user_cubit.dart';

class StocksScreen extends StatelessWidget {
  const StocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, marketState) {
          final currencyFormatter = NumberFormat.currency(
            locale: 'en_US',
            symbol: '\$',
          );
          if (marketState is MarketLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: LinearProgressIndicator(
                      value: marketState.progressValue,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  if (marketState.stockBeingFetched.isNotEmpty)
                    Column(
                      children: [
                        Text('Fetched data for...'),
                        Text(marketState.stockBeingFetched),
                      ],
                    )
                  else
                    Text('Market data is being fetched'),
                ],
              ),
            );
          } else if (marketState is MarketLoaded) {
            return ListView.separated(
              itemCount: marketState.market.length,
              itemBuilder: (marketContext, index) {
                final stock = marketState.market[index];
                final double percentChange =
                    (stock.price - stock.previousClose) /
                        stock.previousClose *
                        100;
                return ListTile(
                  onTap: () {
                    print(BlocProvider.of<UserBloc>(context).state.balance);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context2) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => StockDetailBloc(
                                          marketContext
                                              .read<MarketBloc>()
                                              .stockService)
                                        ..fetchHistoricalData(stock.symbol, '1',
                                            'day', '2023-07-20', '2024-07-20'),
                                    ),
                                    BlocProvider.value(
                                      value: BlocProvider.of<UserBloc>(context),
                                    ),
                                    BlocProvider.value(
                                      value:
                                          BlocProvider.of<MarketBloc>(context),
                                    ),
                                  ],
                                  child: StockDetailScreen(stock: stock),
                                )));
                  },
                  leading: Container(
                    width: 40,
                    child: Image.asset(
                      'assets/stock_icons/${stock.assetName}.png',
                      width: 50,
                      height: 40,
                    ),
                  ),
                  title: Text(stock.symbol),
                  subtitle: Text(stock.fullName),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(stock.price),
                        style: TextStyle(
                            fontSize: 15.0,
                            color: percentChange >= 0.0
                                ? Colors.green
                                : Colors.red),
                      ),
                      Text('${percentChange.toStringAsFixed(2)}%')
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 0.0,
                );
              },
            );
          } else if (marketState is MarketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    size: 100,
                    color: Colors.red,
                  ),
                  Text(marketState.message),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
