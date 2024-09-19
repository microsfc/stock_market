import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../models/historical_data_model.dart';
import '../models/stock_model.dart';

class StockService {
  final String finnhubApiKey = dotenv.env['FINNHUB_API_KEY'] ?? '';
  final String polygonApiKey = dotenv.env['POLYGON_API_KEY'] ?? '';
  final String polygonApiUrl = dotenv.env['POLYGON_API_URL'] ?? '';
  WebSocketChannel? _channel;

  StockService();

  Future<List<HistoricalData>> fetchHistoricalData(String symbol,
      String multiplier, String timespan, String from, String to) async {
    try {
      final Uri uri = new Uri(
        scheme: 'https',
        host: polygonApiUrl,
        path: 'v2/aggs/ticker/$symbol/range/$multiplier/$timespan/$from/$to',
        queryParameters: {
          'adjusted': 'true',
          'sort': 'asc',
          'apiKey': polygonApiKey,
        },
      );

      final response = await http.get(uri);
      print('do you even get here?');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print(data);
        return (data['results'] as List)
            .map((point) => HistoricalData.fromJson(point))
            .toList();
      } else {
        print('polygon api returned ${response.statusCode} instead 200');
        throw Exception(
            'polygon api returned ${response.statusCode} instead 200');
      }
    } catch (e) {
      print('Heree??? ${e.toString()}');
      throw Exception(e);
    }
  }

  Stream<Map<String, dynamic>> getWebSocketStream() {
    //_initializeWebSocket(); // Ensures the WebSocket is initialized
    return _channel!.stream.map((data) {
      return json.decode(data);
    });
  }

  Future<void> _initializeWebSocket() async {
    if (_channel == null) {
      _channel = WebSocketChannel.connect(
          Uri.parse('wss://ws.finnhub.io?token=$finnhubApiKey'));

      try {
        await _channel?.ready;
        print('WebSocket Sink ready');
      } on SocketException catch (e) {
        print('SocketException: ${e.toString()}');
        throw Exception(e);
      } on WebSocketChannelException catch (e) {
        print('WSChannelException: ${e.toString()}');
        throw Exception(e);
      }
    }
  }

  Future<void> subscribeToSymbols(List<String> symbolList) async {
    await _initializeWebSocket();
    for (final symbol in symbolList) {
      final message = json.encode({'type': 'subscribe', 'symbol': symbol});
      _channel!.sink.add(message);
    }
  }

  void dispose() {
    _channel?.sink.close();
  }

  Future<Stock> fetchStockQuote(String symbol) async {
    final Uri url = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finnhubApiKey');

    final Uri uri = Uri(
      scheme: 'https',
      host: 'finnhub.io',
      path: 'api/v1/quote',
      queryParameters: {
        'symbol': symbol,
        'token': finnhubApiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return Stock.fromQuoteJson(symbol, data);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Future<String> fetchCompanyName(String symbol) async {
    final Uri uri = new Uri(
      scheme: 'https',
      host: 'finnhub.io',
      path: 'api/v1/stock/profile2',
      queryParameters: {
        'symbol': symbol,
        'token': finnhubApiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      throw Exception('Failed to fetch company name');
    }
  }
}
