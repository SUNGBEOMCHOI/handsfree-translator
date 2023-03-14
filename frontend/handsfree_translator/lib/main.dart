import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handsfree_translator/screen/first_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        home: const FirstScreen(),
        theme: ThemeData(
          backgroundColor: const Color(0xff7E81EB),
          primaryColorDark: const Color(0xff444444),
          primaryColorLight: const Color(0xffffffff),
          textTheme: const TextTheme(
            subtitle1: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff444444),
            ),
            subtitle2: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
            bodyText1: TextStyle(
              fontSize: 24.0,
              color: Color(0xff444444),
            ),
            bodyText2: TextStyle(
              fontSize: 24.0,
              color: Color(0xffffffff),
            ),
          ),
        ));
  }
}
