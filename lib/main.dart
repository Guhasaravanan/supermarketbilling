import 'package:billing_app/Provider/cart.dart';
import 'package:billing_app/View/BillingScreen.dart';
import 'package:billing_app/View/InitialScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(),
      child: MyApp(),
    ),
  );
}

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Supermarket Billing',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: InitialScreen(),
      );
    }
  }