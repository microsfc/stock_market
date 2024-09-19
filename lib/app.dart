import 'package:flutter/material.dart';
import 'package:stock_market/screens/auth_gate.dart';

class StonksApp extends StatelessWidget {
  const StonksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StonksApp',
      home: AuthGate(),
    );
  }
}
