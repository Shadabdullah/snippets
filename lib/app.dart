import 'package:flutter/material.dart';
import 'package:games/breaker/base_app.dart';
import 'package:get/get.dart';

import 'breaker/game_state_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GameStateController());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(backgroundColor: Colors.red, body: ShootApp()),
      ),
    );
  }
}
