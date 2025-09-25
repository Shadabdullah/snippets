import 'package:flutter/material.dart';
import 'package:games/shoots/shoot_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(backgroundColor: Colors.red, body: ShootApp()),
      ),
    );
  }
}
