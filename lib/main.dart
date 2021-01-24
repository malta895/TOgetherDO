import 'package:flutter/material.dart';
import 'home_lists.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.cyan[700],
            accentColor: Colors.pinkAccent[700],
            appBarTheme: AppBarTheme(
              centerTitle: true,
            )),
        home: ListHomePage());
  }
}
