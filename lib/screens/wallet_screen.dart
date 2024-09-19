import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stock_market/screens/stock_detail_screen.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/market_cubit.dart';
import '../blocs/stock_detail_cubit.dart';
import '../blocs/user_cubit.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final authState = BlocProvider.of<AuthBloc>(context).state;
          if (authState is Authenticated) {
            final currencyFormatter = NumberFormat.currency(
              locale: 'en_US',
              symbol: '\$',
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your current USD balance:'),
                      Text(
                        currencyFormatter.format(userState.balance),
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Stonks 🤑',
                        style: TextStyle(fontSize: 32),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Asset worth',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('shares')
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<MarketBloc, MarketState>(
                    builder: (marketContext, marketState) {
                      if (marketState is MarketLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text('Please wait while fetching market data...')
                            ],
                          ),
                        );
                      } else if (marketState is MarketLoaded) {
                        return ListView.builder(
                            itemCount: userState.assetList.length,
                            itemBuilder: (context, index) {
                              final userAsset = userState.assetList[index];
                              final stockDetails =
                                  marketState.market.firstWhere((stock) {
                                return stock.symbol == userAsset.symbol;
                              });
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context2) =>
                                              MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                        StockDetailBloc(
                                                            marketContext
                                                                .read<
                                                                    MarketBloc>()
                                                                .stockService)
                                                          ..fetchHistoricalData(
                                                              userAsset.symbol,
                                                              '1',
                                                              'day',
                                                              '2023-07-20',
                                                              '2024-07-20'),
                                                  ),
                                                  BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        UserBloc>(context),
                                                  ),
                                                  BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        MarketBloc>(context),
                                                  )
                                                ],
                                                child: StockDetailScreen(
                                                    stock: stockDetails),
                                              )));
                                },
                                leading: Container(
                                  width: 40,
                                  child: Image.asset(
                                    'assets/stock_icons/${stockDetails.assetName}.png',
                                    width: 50,
                                    height: 40,
                                  ),
                                ),
                                title: Text(stockDetails.symbol),
                                subtitle: Text(stockDetails.fullName),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormatter.format(
                                          userAsset.shares *
                                              stockDetails.price),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(userAsset.shares.toString())
                                  ],
                                ),
                              );
                            });
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
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
