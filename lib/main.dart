import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env variables
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(name:'stocketMarketApp', options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    StonksApp(),
  );
}
