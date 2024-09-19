import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/asset_model.dart';

class UserState extends Equatable {
  final num balance;
  final List<Asset> assetList;

  UserState({required this.balance, required this.assetList});

  @override
  List<Object?> get props => [balance, assetList];
}

class UserBloc extends Cubit<UserState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBloc() : super(UserState(assetList: [], balance: 0)) {
    _initialize();
  }

  void _initialize() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          //print('something changed');
          final data = snapshot.data()!;
          final balance = data['balance'];
          if (data['stocks'] != null) {
            final List<dynamic> stocksDynamic = data['stocks'] ?? [];
            final List<Asset> assetList = stocksDynamic.map((asset) {
              return Asset.fromMap(Map<String, dynamic>.from(asset));
            }).toList();
            emit(UserState(balance: balance, assetList: assetList));
          } else {
            emit(UserState(balance: balance, assetList: []));
          }
        }
      });
    }
  }

  double roundTheDecimal(double value, int decimals) {
    num mod = pow(10.0, decimals);
    return ((value * mod).round().toDouble() / mod);
  }

  Future<void> sellStock(String symbol, double quantity, double price) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final worthOfSale = quantity * price;

      final userDocRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (!snapshot.exists) {
          throw Exception("User document does not exist");
        }

        final data = snapshot.data();

        if (data == null || data.isEmpty) {
          throw Exception("User document exists but contains no data");
        }

        final currentBalance = data['balance'] as double;
        final stocks = List<Map<String, dynamic>>.from(data['stocks']);

        final stockIndex =
            stocks.indexWhere((asset) => asset['symbol'] == symbol);
        if (stockIndex == -1) {
          throw Exception('Asset not found');
        }

        final asset = stocks[stockIndex];
        final remainingShares = roundTheDecimal(asset['shares'] - quantity, 2);

        if (remainingShares < 0) {
          throw Exception('Tried to sell more shares than you own');
        } else {
          if (remainingShares == 0) {
            stocks.removeAt(stockIndex);
          } else {
            stocks[stockIndex] = {
              'symbol': symbol,
              'shares': remainingShares,
            };
          }
          final updatedBalance =
              roundTheDecimal(currentBalance + worthOfSale, 2);

          transaction.update(userDocRef, {
            'balance': updatedBalance,
            'stocks': stocks,
          });

          emit(UserState(
              balance: updatedBalance,
              assetList: stocks.map((asset) => Asset.fromMap(asset)).toList()));
        }
      });

      // final currentState = state;
      // final assetToBeSold =
      //     currentState.assetList.firstWhere((asset) => asset.symbol == symbol);

      // if (assetToBeSold.shares < quantity) {
      //   print('${assetToBeSold.shares} is less than $quantity');
      //   throw Exception('Insufficient shares');
      // } else {
      //   print('and I get here');
      //   final updatedBalance = currentState.balance + worthOfSale;
      //   final List<Asset> updatedAssets = List.from(currentState.assetList);
      //   final assetToBeSoldIndex =
      //       updatedAssets.indexWhere((asset) => asset.symbol == symbol);
      //   if (assetToBeSoldIndex != -1) {
      //     double remainingShares = assetToBeSold.shares - quantity;
      //     updatedAssets[assetToBeSoldIndex] = Asset(
      //         symbol: assetToBeSold.symbol,
      //         shares: roundTheDecimal(remainingShares, 2));
      //     if (updatedAssets[assetToBeSoldIndex].shares == 0) {
      //       updatedAssets.removeAt(assetToBeSoldIndex);
      //     }
      //   } else {
      //     throw Exception('Can\'t sell asset that does not exist');
      //   }
      //   await _firestore.collection('users').doc(user.uid).set({
      //     'balance': roundTheDecimal(updatedBalance, 2),
      //     'stocks': updatedAssets.map((asset) => asset.toMap()).toList(),
      //   });
      //   emit(UserState(balance: updatedBalance, assetList: updatedAssets));
      // }
    }
  }

  Future<void> buyStock(String symbol, double quantity, double price) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final totalCost = quantity * price;
      final userDocRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("User document does not exist");
        }

        final data = snapshot.data();
        if (data == null || data.isEmpty) {
          throw Exception("User document exists but contains no data");
        }

        final currentBalance = data['balance'] as double;
        final stocks = List<Map<String, dynamic>>.from(data['stocks']);

        if (currentBalance < totalCost) {
          throw Exception('Insufficient balance');
        }

        final stockIndex =
            stocks.indexWhere((asset) => asset['symbol'] == symbol);
        if (stockIndex != -1) {
          stocks[stockIndex]['shares'] += quantity;
        } else {
          stocks.add({'symbol': symbol, 'shares': quantity});
        }

        final updatedBalance = roundTheDecimal(currentBalance - totalCost, 2);

        transaction.update(userDocRef, {
          'balance': updatedBalance,
          'stocks': stocks,
        });

        emit(UserState(
            balance: updatedBalance,
            assetList: stocks.map((asset) => Asset.fromMap(asset)).toList()));
      });
      // final currentState = state;
      // if (currentState.balance >= totalCost) {
      //   final updatedBalance = currentState.balance - totalCost;
      //   final List<Asset> updatedAssets = List.from(currentState.assetList);
      //   final existingAssetIndex =
      //       updatedAssets.indexWhere((asset) => asset.symbol == symbol);
      //   if (existingAssetIndex != -1) {
      //     final existingAsset = updatedAssets[existingAssetIndex];
      //     updatedAssets[existingAssetIndex] = Asset(
      //         symbol: existingAsset.symbol,
      //         shares: existingAsset.shares + quantity);
      //   } else {
      //     updatedAssets.add(Asset(symbol: symbol, shares: quantity));
      //   }
      //   await _firestore.collection('users').doc(user.uid).set({
      //     'balance': roundTheDecimal(updatedBalance, 2),
      //     'stocks': updatedAssets.map((asset) => asset.toMap()).toList(),
      //   });
      //   emit(UserState(balance: updatedBalance, assetList: updatedAssets));
      // } else {
      //   throw Exception('Insufficient funds');
      // }
    }
  }
}
