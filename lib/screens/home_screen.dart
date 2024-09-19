import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/screens/stocks_screen.dart';
import 'package:stock_market/screens/wallet_screen.dart';

import '../blocs/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Hi! ${user.email}'),
            actions: [
              InkWell(
                onTap: () {
                  BlocProvider.of<AuthBloc>(context).logOut();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 10),
                  child: Icon(
                    Icons.logout,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                StocksScreen(),
                WalletScreen(),
              ],
            ),
          ),
          bottomNavigationBar: TabBar(
            //padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
            tabs: [
              Tab(icon: Icon(Icons.area_chart), text: 'Stocks'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Wallet'),
            ],
            indicator: BoxDecoration(),
            // labelColor: Colors.black,
            // unselectedLabelColor: Colors.grey.shade400,
            //indicatorSize: TabBarIndicatorSize.label,
            //indicatorWeight: 7.0,
            // indicatorPadding: EdgeInsets.all(10.0),
            // indicatorColor: Colors.black,
          ),
        ));
  }
}
