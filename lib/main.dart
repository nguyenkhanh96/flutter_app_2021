import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_2021/packages/quote/quote.dart';
import 'package:flutter_app_2021/packages/quote/quote_model.dart';
import 'package:flutter_app_2021/pages/landing_page.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Quotes().getAll();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LandingPage(),
    );
  }
}
